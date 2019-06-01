//
//  Visitor.swift
//  Typology
//
//  Created by Max Desiatov on 16/04/2019.
//  Copyright © 2019 Typology. All rights reserved.
//

import Foundation
import SwiftSyntax

enum ASTError: Error {
  case unknownSyntax
}

extension File {
  init(_ file: SourceFileSyntax) throws {
    statements = try file.statements.flatMap { statement -> [Statement] in
      try statement.children.flatMap { syntax -> [Statement] in
        switch syntax {
        case let sequence as SequenceExprSyntax:
          return try sequence.elements.map { try Expr($0) }
        default:
          throw ASTError.unknownSyntax
        }
      }
    }
  }
}

extension Expr {
  init(_ expr: ExprSyntax) throws {
    switch expr {
    case let identifier as IdentifierExprSyntax:
      self = .identifier(identifier.identifier.text)

    case let ternary as TernaryExprSyntax:
      self = try .ternary(
        Expr(ternary.conditionExpression),
        Expr(ternary.firstChoice),
        Expr(ternary.secondChoice)
      )

    case let literal as IntegerLiteralExprSyntax:
      guard let int = Int(literal.digits.text) else {
        throw ASTError.unknownSyntax
      }
      self = .literal(.integer(int))

    case let literal as FloatLiteralExprSyntax:
      guard let double = Double(literal.floatingDigits.text) else {
        throw ASTError.unknownSyntax
      }
      self = .literal(.floating(double))

    case let literal as BooleanLiteralExprSyntax:
      guard let bool = Bool(literal.booleanLiteral.text) else {
        throw ASTError.unknownSyntax
      }
      self = .literal(.bool(bool))

    case let literal as StringLiteralExprSyntax:
      self = .literal(.string(literal.stringLiteral.text))


    default:
      throw ASTError.unknownSyntax
    }
  }
}

extension String {
  func parseAST() throws -> File {
    let url = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("typology.ast")

    try write(toFile: url.path, atomically: true, encoding: .utf8)

    let syntax = try SyntaxTreeParser.parse(url)
    try FileManager.default.removeItem(at: url)
    return try File(syntax)
  }
}
