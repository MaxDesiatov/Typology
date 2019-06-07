//
//  Binding.swift
//  Typology
//
//  Created by Max Desiatov on 07/06/2019.
//

import Foundation
import SwiftSyntax

struct BindingDecl: Statement {
  let attributes: [Attribute]
  let bindings: [PatternBinding]
  let isConstant: Bool
  let modifiers: [Modifier]

  let range: SourceRange
}

extension BindingDecl {
  init(_ syntax: VariableDeclSyntax, _ file: URL) throws {
    try self.init(
      attributes: syntax.attributes?.map { Attribute($0, file) } ?? [],
      bindings: syntax.bindings.map { try PatternBinding($0, file) },
      isConstant: syntax.letOrVarKeyword.text == "let",
      modifiers: syntax.modifiers?.map { Modifier($0, file) } ?? [],
      range: syntax.sourceRange(in: file)
    )
  }
}
