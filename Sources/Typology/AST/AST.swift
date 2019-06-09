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

public struct File {
  let statements: [Statement]
}

public protocol Location {
  var range: SourceRange { get }
}

public protocol Statement: Location {}

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
  func toStatement(_ file: URL) throws -> [Statement] {
    switch self {
    case let syntax as VariableDeclSyntax:
      return try [BindingDecl(syntax, file)]

    case let syntax as SequenceExprSyntax:
      return try syntax.elements.map { try ExprNode($0, file) }

    case let syntax as FunctionDeclSyntax:
      return try [FunctionDecl(syntax, file)]

    case let syntax as ReturnStmtSyntax:
      return try [ReturnStmt(syntax, file)]

    case let syntax as CodeBlockItemSyntax:
      return try syntax.item.toStatement(file)

    case let syntax as FunctionCallExprSyntax:
      return try [ExprNode(
        expr: Expr.application(
          Expr(syntax.calledExpression, file),
          syntax.argumentList.map { try Expr($0.expression, file) }
        ),
        range: syntax.sourceRange(in: file)
      )]

    default:
      throw ASTError(self, .unknownSyntax, file)
    }
  }
}

extension Array where Element == Statement {
  init(_ syntax: CodeBlockItemListSyntax, _ file: URL) throws {
    self = try syntax.flatMap { try $0.item.toStatement(file) }
  }
}

extension File {
  init(_ syntax: SourceFileSyntax, _ url: URL) throws {
    statements = try .init(syntax.statements, url)
  }
}

extension File {
  public init(path: String) throws {
    let url = URL(fileURLWithPath: path)
    let syntax = try SyntaxTreeParser.parse(url)
    try self.init(syntax, url)
  }
}

extension String {
  public func parseAST() throws -> File {
    let url = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent("typology.swift")

    try write(toFile: url.path, atomically: true, encoding: .utf8)

    let syntax = try SyntaxTreeParser.parse(url)
    try FileManager.default.removeItem(at: url)
    return try File(syntax, url)
  }
}
