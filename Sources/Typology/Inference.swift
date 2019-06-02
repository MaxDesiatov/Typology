//
//  Inference.swift
//  Typology
//
//  Created by Max Desiatov on 27/04/2019.
//

enum Constraint {
  case equal(Type, Type)
  case member(Type, member: Identifier, memberType: Type)
}

typealias Environment = [Identifier: Scheme]
typealias Members = [TypeIdentifier: Environment]

struct Inference {
  private var typeVariableCount = 0
  private var environment: Environment
  private let members: Members
  private(set) var constraints = [Constraint]()

  init(_ environment: Environment, members: Members) {
    self.environment = environment
    self.members = members
  }

  /// Temporarily injects `scheme` for `id` in the current environment to
  /// infer the type of `inferred` expression. Is used to infer
  /// type of an expression evaluated in a lambda.
  private mutating func infer(
    inExtendedEnvironment extendedEnvironment: [(Identifier, Scheme)],
    _ inferred: Expr
  ) throws -> Type {
    // preserve old environment to be restored after inference in extended
    // environment has finished
    var old = environment

    defer { environment = old }

    for (id, scheme) in extendedEnvironment {
      environment[id] = scheme
    }
    return try infer(inferred)
  }

  private mutating func fresh() -> Type {
    defer { typeVariableCount += 1 }

    return .variable("T\(typeVariableCount)")
  }

  private mutating func lookup(_ id: Identifier) throws -> Type {
    guard let scheme = environment[id] else { throw TypeError.unbound(id) }

    return instantiate(scheme)
  }

  private mutating func lookup(
    _ member: Identifier,
    in typeID: TypeIdentifier
  ) throws -> Type {
    guard let scheme = members[typeID]?[member] else {
      throw TypeError.unknownMember(typeID, member)
    }

    return instantiate(scheme)
  }

  /// Converting a σ type into a τ type by creating fresh names for each type
  /// variable that does not appear in the current typing environment.
  private mutating func instantiate(_ scheme: Scheme) -> Type {
    let substitution = scheme.variables.map { ($0, fresh()) }
    return scheme.type.apply(Dictionary(uniqueKeysWithValues: substitution))
  }

  mutating func infer(_ expr: Expr) throws -> Type {
    switch expr {
    case let .literal(literal):
      return literal.defaultType

    case let .identifier(id):
      return try lookup(id)

    case let .lambda(id, expr):
      let typeVariable = fresh()
      let localScheme = Scheme(typeVariable)
      return .arrow(
        typeVariable,
        try infer(inExtendedEnvironment: [(id, localScheme)], expr)
      )

    case let .application(callable, arguments):
      let callableType = try infer(callable)
      let argumentsType = try infer(arguments)
      let typeVariable = fresh()
      constraints.append(.equal(
        callableType,
        .arrow(argumentsType, typeVariable)
      ))
      return typeVariable

    case let .ternary(cond, expr1, expr2):
      let result = try infer(expr1)
      try constraints.append(contentsOf: [
        .equal(infer(cond), .bool),
        .equal(result, infer(expr2)),
      ])
      return result

    case let .member(expr, id):
      switch try infer(expr) {
      case .arrow:
        throw TypeError.arrowMember(id)
      case let .constructor(typeID, _):
        return try lookup(id, in: typeID)
      case let .variable(v):
        let memberType = fresh()
        constraints.append(
          .member(.variable(v), member: id, memberType: memberType)
        )
        return memberType
      case let .tuple(types):
        guard let idx = Int(id) else {
          throw TypeError.unknownTupleMember(id)
        }

        guard (0..<types.count).contains(idx) else {
          throw TypeError.tupleIndexOutOfRange(
            total: types.count,
            addressed: idx
          )
        }

        return types[idx]
      }

    case let .tuple(expressions):
      return try .tuple(expressions.map { try infer($0) })
    }
  }
}
