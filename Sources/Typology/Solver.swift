//
//  Solver.swift
//  Typology
//
//  Created by Max Desiatov on 27/04/2019.
//

struct Solver {
  private let substitution: Substitution
  private let constraints: [Constraint]

  init(substitution: Substitution = [:], constraints: [Constraint] = []) {
    self.substitution = substitution
    self.constraints = constraints
  }

  private func bind(type: Type, to variable: TypeVariable) throws -> Solver {
    if type == .variable(variable) {
      return Solver()
    } else if type.occurs(variable) {
      throw TypeError.infiniteType(variable, type)
    }

    return Solver(substitution: [variable: type])
  }

  private func unify(_ t1: Type, _ t2: Type) throws -> Solver {
    switch (t1, t2) {
    case let (.arrow(i1, o1), .arrow(i2, o2)):
      let s1 = try unify(i1, i2)
      let s2 = try unify(o1.apply(s1.substitution), o2.apply(s1.substitution))
      return Solver(
        substitution: s2.substitution.compose(s1.substitution),
        constraints: s1.constraints + s2.constraints
      )
    case let (.variable(v), t):
      return try bind(type: t, to: v)
    case let (t, .variable(v)):
      return try bind(type: t, to: v)
    case let (.constructor(a), .constructor(b)) where a == b:
      return Solver()
    case let (.tuple(t1), .tuple(t2)) where t1.count == t2.count:
      return try zip(t1, t2).map { try unify($0, $1) }.reduce(Solver()) {
        Solver(
          substitution: $0.substitution.compose($1.substitution),
          constraints: $0.constraints + $1.constraints
        )
      }
    case let (a, b):
      throw TypeError.unificationFailure(a, b)
    }
  }

  func solve() throws -> Substitution {
    guard let constraint = constraints.first else { return substitution }

    let rest = Array(constraints.dropFirst())

    switch constraint {
    case let .equal(t1, t2):
      let s = try unify(t1, t2)

      return try Solver(
        substitution: s.substitution.compose(substitution),
        constraints: s.constraints + rest.apply(s.substitution)
      ).solve()
    }
  }
}
