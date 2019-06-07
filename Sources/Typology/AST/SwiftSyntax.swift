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

extension Array where Element == Statement {
  init(_ statements: CodeBlockItemListSyntax) throws {
    self = try statements.flatMap { statement -> [Statement] in
      try statement.children.flatMap { syntax -> [Statement] in
        switch syntax {
        case let sequence as SequenceExprSyntax:
          return try sequence.elements.map { ExprNode(position: $0.position, expr: try Expr($0)) }

        case let function as FunctionDeclSyntax:
          let returns = function.signature.output?.returnType
          let body = function.body?.statements
          let position = function.position
          return try [FunctionDecl(
            genericParameters: function.genericParameterClause?
              .genericParameterList.map {
                TypeVariable(value: $0.name.text)
              } ?? [],
            parameters: function.signature.input.parameterList
              .compactMap { parameter -> (String?, String?, Type)? in
                guard let type = parameter.type else { return nil }
                return try (
                  parameter.firstName?.text,
                  parameter.secondName?.text,
                  Type(type)
                )
              },
            statements: body.flatMap([Statement].init) ?? [],
            returns: returns.map(Type.init) ?? .tuple([]), position: position
          )]

        case let stmt as ReturnStmtSyntax:
          return try [ReturnStmt(expr: stmt.expression.map(Expr.init), position: stmt.position)]

        default:
          throw ASTError.unknownSyntax
        }
      }
    }
  }
}

extension File {
  init(_ file: SourceFileSyntax) throws {
    statements = try .init(file.statements)
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

extension Type {
  init(_ type: TypeSyntax) throws {
    switch type {
    case let tuple as TupleTypeSyntax:
      self = try .tuple(tuple.elements.map { try Type($0.type) })

    case let identifier as SimpleTypeIdentifierSyntax:
      self = .constructor(TypeIdentifier(value: identifier.name.text), [])

    case let array as ArrayTypeSyntax:
      self = try .constructor("Array", [Type(array.elementType)])

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
