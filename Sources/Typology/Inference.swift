//
//  Inference.swift
//  Typology
//
//  Created by Max Desiatov on 27/04/2019.
//

enum Constraint {
  case equal(Type, Type)
  case member(Type, Identifier, Type)
}

struct Scheme {
  /// Variables bound in this scheme
  let variables: [TypeVariable]

  let type: Type

  init(variables: [TypeVariable], type: Type) {
    self.variables = variables
    self.type = type
  }

  init(_ type: Type) {
    self.variables = []
    self.type = type
  }
}

typealias Environment = [Identifier: Scheme]
typealias TypeDeclarations = [TypeIdentifier: Environment]

enum TypeError: Error {
  case infiniteType(TypeVariable, Type)
  case unificationFailure(Type, Type)
  case arrowMember(Identifier)
  case unknownMember(TypeIdentifier, Identifier)
  case unbound(Identifier)
}

struct Inference {
  private var typeVariableCount = 0
  private var environment: Environment
  var constraints = [Constraint]()

  init(environment: Environment) {
    self.environment = environment
  }

  private mutating func inferInExtendedEnvironment(
    _ id: Identifier,
    _ scheme: Scheme,
    _ inferred: Expr
  ) throws -> Type {
    // preserve old environment to be restored after inference in extended
    // environment has finished
    var old = environment

    defer { environment = old }

    environment[id] = scheme
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

  /// Converting a σ type into a τ type by creating fresh names for each type
  /// variable that does not appear in the current typing environment.
  private mutating func instantiate(_ scheme: Scheme) -> Type {
    let substitution = scheme.variables.map { ($0, fresh()) }
    return scheme.type.apply(Dictionary(uniqueKeysWithValues: substitution))
  }

  /// Converting a τ type into a σ type by closing over all free type variables
  /// in a type scheme.
  private func generalize(type: Type, in env: Environment) -> Scheme {
    let variables = type.freeTypeVariables.subtracting(env.freeTypeVariables)
    return Scheme(variables: Array(variables), type: type)
  }

  mutating func infer(_ expr: Expr) throws -> Type {
    switch expr {
    case let .literal(literal):
      return literal.defaultType

    case let .identifier(id):
      return try lookup(id)

    case let .lambda(id, expr):
      let typeVariable = fresh()
      let localScheme = Scheme(variables: [], type: typeVariable)
      return .arrow(
        typeVariable,
        try inferInExtendedEnvironment(id, localScheme, expr)
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
        .equal(result, infer(expr2))
      ])
      return result

    case let .member(expr, id):
      let typeVariable = fresh()
      try constraints.append(.member(infer(expr), id, typeVariable))
      return typeVariable
    }
  }
}
