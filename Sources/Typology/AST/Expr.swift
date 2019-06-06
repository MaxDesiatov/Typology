//
//  Expr.swift
//  Typology
//
//  Created by Max Desiatov on 12/05/2019.
//

indirect enum Expr: Statement {
  case identifier(Identifier)
  case application(Expr, [Expr])
  case lambda([Identifier], Expr)
  case literal(Literal)
  case ternary(Expr, Expr, Expr)
  case member(Expr, Identifier)
  case namedTuple([(Identifier?, Expr)])

  static func tuple(_ expressions: [Expr]) -> Expr {
    return .namedTuple(expressions.enumerated().map {
      (nil, $0.1)
    })
  }

  func infer(
    environment: Environment = [:],
    members: Members = [:]
  ) throws -> Type {
    var system = ConstraintSystem(
      environment,
      members: members
    )
    let type = try system.infer(self)

    let solver = Solver(
      substitution: [:],
      system: system
    )
    return try type.apply(solver.solve())
  }
}

extension Expr: ExpressibleByStringLiteral {
  init(stringLiteral value: String) {
    self = .identifier(value)
  }
}
