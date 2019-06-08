//
//  Return.swift
//  Typology
//
//  Created by Max Desiatov on 07/06/2019.
//

import Foundation
import SwiftSyntax

struct ReturnStmt: Statement {
  let expr: Expr?

  let range: SourceRange
}

extension ReturnStmt {
  init(_ syntax: ReturnStmtSyntax, _ file: URL) throws {
    try self.init(
      expr: syntax.expression.map { try Expr($0, file) },
      range: syntax.sourceRange(in: file)
    )
  }
}
