//
//  ConstraintSystem.swift
//  Typology
//
//  Created by Max Desiatov on 27/04/2019.
//

enum Constraint {
  /// Type equality constraint
  case equal(Type, Type)

  /** Constraint used to resolve function overloads. This constraint is valid
   if `assumption` can be unified with any of the types passed as
   `alternatives`.
   */
  case disjunction(Identifier, assumption: Type, alternatives: [Type])

  /** Member constraint representing members of type declarations: functions and
   properties.
   */
  case member(Type, member: Identifier, memberType: Type)
}

/** Environment of possible overloads for `Identifier`. There's an assumption
 that `[Scheme]` array can't be empty, since an empty array of overloads is
 meaningless. If no overloads are available for `Identifier`, it shouldn't be
 in the `Environoment` dictionary as a key in the first place.
 */
typealias Environment = [Identifier: [Scheme]]
typealias Members = [TypeIdentifier: Environment]

struct ConstraintSystem {
  private var typeVariableCount = 0
  private(set) var constraints = [Constraint]()

  private(set) var environment: Environment
  let members: Members

  init(_ environment: Environment, members: Members) {
    self.environment = environment
    self.members = members
  }

  mutating func removeFirst() -> Constraint? {
    return constraints.count > 0 ? constraints.removeFirst() : nil
  }

  mutating func prepend(_ constraint: Constraint) {
    constraints.insert(constraint, at: 0)
  }

  func appending(_ constraints: [Constraint]) -> ConstraintSystem {
    var result = self
    result.constraints.append(contentsOf: constraints)
    return result
  }

  mutating func apply(_ sub: Substitution) {
    constraints = constraints.apply(sub)
  }

  /// Temporarily extends the current `self.environment` with `environment` to
  /// infer the type of `inferred` expression. Is used to infer
  /// type of an expression evaluated in a lambda.
  private mutating func infer<T>(
    inExtended environment: T,
    _ inferred: Expr
  ) throws -> Type where T: Sequence, T.Element == (Identifier, Scheme) {
    // preserve old environment to be restored after inference in extended
    // environment has finished
    var old = self.environment

    defer { self.environment = old }

    for (id, scheme) in environment {
      self.environment[id] = [scheme]
    }
    return try infer(inferred)
  }

  /** Generate a new type variable that can be stored in `constraints`. If
   constraints are consistent and a single solution ca be found, this
   type variable will be resolved to a concrete type with a substitution created
   by a `Solver`.
   */
  private mutating func fresh() -> Type {
    defer { typeVariableCount += 1 }

    return .variable("T\(typeVariableCount)")
  }

  mutating func lookup(
    _ member: Identifier,
    in typeID: TypeIdentifier
  ) throws -> Type {
    guard let environment = members[typeID] else {
      throw TypeError.unknownType(typeID)
    }

    return try lookup(
      member,
      in: environment,
      orThrow: .unknownMember(typeID, member)
    )
  }

  private mutating func lookup(
    _ id: Identifier,
    in environment: Environment,
    orThrow error: TypeError
  ) throws -> Type {
    guard let schemes = environment[id] else { throw error }

    let results = schemes.map { instantiate($0) }

    assert(results.count > 0)
    guard results.count > 1 else { return results[0] }

    let typeVariable = fresh()

    constraints.append(
      .disjunction(id, assumption: typeVariable, alternatives: results)
    )
    return typeVariable
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
      return try lookup(id, in: environment, orThrow: .unbound(id))

    case let .lambda(ids, expr):
      let parameters = ids.map { _ in fresh() }
      return try .arrow(
        parameters,
        infer(inExtended: zip(ids, parameters.map { Scheme($0) }), expr)
      )

    case let .application(callable, arguments):
      let callableType = try infer(callable)
      let typeVariable = fresh()
      constraints.append(.equal(
        callableType,
        .arrow(try arguments.map { try infer($0) }, typeVariable)
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

      case let .namedTuple(elements):
        if let idx = Int(id) {
          guard (0..<elements.count).contains(idx) else {
            throw TypeError.tupleIndexOutOfRange(
              total: elements.count,
              addressed: idx
            )
          }

          return elements[idx].1
        } else if let idx = elements.firstIndex(where: { $0.0 == id }) {
          return elements[idx].1
        } else {
          throw TypeError.unknownTupleMember(id)
        }
      }

    case let .namedTuple(expressions):
      return try .namedTuple(expressions.map { ($0.0, try infer($0.1)) })
    }
  }
}
