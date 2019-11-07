//
//  AST.swift
//  Typology
//
//  Created by Max Desiatov on 19/04/2019.
//

import Foundation
import SwiftSyntax

typealias Identifier = String
typealias Operator = String

struct File {
  let statements: [Statement]
}

protocol Location {
  var range: SourceRange { get }
}

protocol Statement: Location {}

struct CaseDecl {}

struct EnumDecl {
  let cases: [CaseDecl]
}

struct ImportDecl {
  let path: [String]
}

struct Module {
  let files: [File]
}

struct Target {
  let dependencies: [Module]
  let main: Module
}

extension Syntax {
  func toStatement(_ converter: SourceLocationConverter) throws -> [Statement] {
    switch self {
    case let syntax as VariableDeclSyntax:
      return try [BindingDecl(syntax, converter)]

    case let syntax as SequenceExprSyntax:
      return try syntax.elements.map { try ExprNode($0, converter) }

    case let syntax as FunctionDeclSyntax:
      return try [FunctionDecl(syntax, converter)]

    case let syntax as ReturnStmtSyntax:
      return try [ReturnStmt(syntax, converter)]

    case let syntax as CodeBlockItemSyntax:
      return try syntax.item.toStatement(converter)

    case let syntax as FunctionCallExprSyntax:
      return try [ExprNode(
        expr: Expr.application(
          Expr(syntax.calledExpression, converter),
          syntax.argumentList.map { try Expr($0.expression, converter) }
        ),
        range: syntax.sourceRange(converter: converter)
      )]

    default:
      throw ASTError(self, .unknownSyntax, converter)
    }
  }
}

extension Array where Element == Statement {
  init(_ syntax: CodeBlockItemListSyntax, _ converter: SourceLocationConverter) throws {
    self = try syntax.flatMap { try $0.item.toStatement(converter) }
  }
}

extension File {
  init(_ syntax: SourceFileSyntax, _ converter: SourceLocationConverter) throws {
    statements = try .init(syntax.statements, converter)
  }
}

extension File {
  public init(path: String) throws {
    let url = URL(fileURLWithPath: path)
    let syntax = try SyntaxParser.parse(url)
    try self.init(syntax, SourceLocationConverter(file: path, tree: syntax))
  }
}

extension String {
  func parseAST() throws -> File {
    let url = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("typology.swift")

    try write(toFile: url.path, atomically: true, encoding: .utf8)

    let syntax = try SyntaxParser.parse(url)
    try FileManager.default.removeItem(at: url)
    return try File(syntax, SourceLocationConverter(file: url.path, tree: syntax))
  }
}
