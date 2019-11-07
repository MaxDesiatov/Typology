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
  init(_ syntax: VariableDeclSyntax, _ converter: SourceLocationConverter) throws {
    try self.init(
      attributes: syntax.attributes?.compactMap { $0 as? AttributeSyntax }.map {
        Attribute($0, converter)
      } ?? [],
      bindings: syntax.bindings.map { try PatternBinding($0, converter) },
      isConstant: syntax.letOrVarKeyword.text == "let",
      modifiers: syntax.modifiers?.map { Modifier($0, converter) } ?? [],
      range: syntax.sourceRange(converter: converter)
    )
  }
}
