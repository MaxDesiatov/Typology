//
//  Expr.swift
//  Typology
//
//  Created by Max Desiatov on 12/05/2019.
//

indirect enum Expr {
  case identifier(Identifier)
  case application(Expr, Expr)
  case lambda(Identifier, Expr)
  case literal(Literal)
  case ternary(Expr, Expr, Expr)
  case member(Expr, Identifier)
  case tuple([Expr])

  func infer(
    in environment: Environment = [:],
    with declarations: TypeDeclarations = [:]
  ) throws -> Type {
    var inference = Inference(environment, declarations)
    let type = try inference.infer(self)

    let solver = Solver(
      substitution: [:],
      constraints: inference.constraints
    )
    return try type.apply(solver.solve())
  }
}

extension Expr: ExpressibleByStringLiteral {
  init(stringLiteral value: String) {
    self = .identifier(value)
  }
}
