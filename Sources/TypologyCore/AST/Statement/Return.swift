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
  init(_ syntax: ReturnStmtSyntax, _ converter: SourceLocationConverter) throws {
    try self.init(
      expr: syntax.expression.map { try Expr($0, converter) },
      range: syntax.sourceRange(converter: converter)
    )
  }
}
