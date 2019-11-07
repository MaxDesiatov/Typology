//
//  Expr.swift
//  Typology
//
//  Created by Max Desiatov on 12/05/2019.
//

import Foundation
import SwiftSyntax

struct ExprNode: Statement {
  let expr: Expr
  let range: SourceRange
}

extension ExprNode {
  init(_ syntax: ExprSyntax, _ converter: SourceLocationConverter) throws {
    self.init(
      expr: try Expr(syntax, converter),
      range: syntax.sourceRange(converter: converter)
    )
  }
}

indirect enum Expr {
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

extension Expr {
  init(_ expr: ExprSyntax, _ converter: SourceLocationConverter) throws {
    switch expr {
    case let identifier as IdentifierExprSyntax:
      self = .identifier(identifier.identifier.text)

    case let ternary as TernaryExprSyntax:
      self = try .ternary(
        Expr(ternary.conditionExpression, converter),
        Expr(ternary.firstChoice, converter),
        Expr(ternary.secondChoice, converter)
      )

    case let literal as IntegerLiteralExprSyntax:
      guard let int = Int(literal.digits.text) else {
        throw ASTError(expr, .unknownSyntax, converter)
      }
      self = .literal(.integer(int))

    case let literal as FloatLiteralExprSyntax:
      guard let double = Double(literal.floatingDigits.text) else {
        throw ASTError(expr, .unknownSyntax, converter)
      }
      self = .literal(.floating(double))

    case let literal as BooleanLiteralExprSyntax:
      guard let bool = Bool(literal.booleanLiteral.text) else {
        throw ASTError(expr, .unknownSyntax, converter)
      }
      self = .literal(.bool(bool))

    case let literal as StringLiteralExprSyntax:
      self = .literal(.string(literal.segments.compactMap {
        ($0 as? StringSegmentSyntax)?.content.text
      }.joined()))

    default:
      throw ASTError(expr, .unknownSyntax, converter)
    }
  }
}
