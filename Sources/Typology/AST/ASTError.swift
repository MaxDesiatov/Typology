//
//  ASTError.swift
//  Typology
//
//  Created by Max Desiatov on 07/06/2019.
//

import Foundation
import SwiftSyntax

struct ASTError: DiagnosticError {
  enum Value {
    case unknownSyntax
  }

  let range: SourceRange
  let value: Value
}

extension ASTError {
  init(_ syntax: Syntax, _ value: Value, _ file: URL) {
    self.init(range: syntax.sourceRange(in: file), value: value)
  }
}
