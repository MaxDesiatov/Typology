//
//  Pattern.swift
//  Typology
//
//  Created by Max Desiatov on 07/06/2019.
//

import Foundation
import SwiftSyntax

protocol Pattern: Location {}

extension PatternSyntaxProtocol {
  func toPattern(_ converter: SourceLocationConverter) throws -> Pattern {
    if let syntax = TuplePatternSyntax(_syntaxNode) {
      return try TuplePattern(
        elements: syntax.elements.map { try TuplePatternElement($0, converter) },
        range: syntax.sourceRange(converter: converter)
      )
    } else if let syntax = IdentifierPatternSyntax(_syntaxNode) {
      return IdentifierPattern(
        identifier: syntax.identifier.text,
        range: syntax.sourceRange(converter: converter)
      )
    } else {
      throw ASTError(_syntaxNode, .unknownSyntax, converter)
    }
  }
}
