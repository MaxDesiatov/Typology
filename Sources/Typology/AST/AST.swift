//
//  AST.swift
//  Typology
//
//  Created by Max Desiatov on 19/04/2019.
//

import SwiftSyntax

typealias Identifier = String
typealias Operator = String

struct File {
  let statements: [Statement]
}

protocol Statement {
  var startPosition: AbsolutePosition { get }
  var endPosition: AbsolutePosition { get }
}

struct ReturnStmt: Statement {
  let expr: Expr?
  let startPosition: AbsolutePosition
  let endPosition: AbsolutePosition
}

struct FunctionDecl: Statement {
  let genericParameters: [TypeVariable]
  let parameters: [(String?, String?, Type)]
  let statements: [Statement]
  let returns: Type
  let startPosition: AbsolutePosition
  let endPosition: AbsolutePosition

  var scheme: Scheme {
    return Scheme(parameters.map { $0.2 } --> returns, variables: genericParameters)
  }
}

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
