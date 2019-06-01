//
//  Visitor.swift
//  Typology
//
//  Created by Max Desiatov on 16/04/2019.
//  Copyright © 2019 Typology. All rights reserved.
//

import SwiftSyntax

enum ASTError: Error {
  case unknownSyntax
}

extension File {
  init(_ file: SourceFileSyntax) throws {
    statements = try file.statements.map {
      switch $0 {
      case let expr as ExprSyntax:
        return try Expr(expr)
      default:
        throw ASTError.unknownSyntax
      }
    }
  }
}

extension Expr {
  init(_ expr: ExprSyntax) throws {
    switch expr {
    default:
      throw ASTError.unknownSyntax
    }
  }
}
