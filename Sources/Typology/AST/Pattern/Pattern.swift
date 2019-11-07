//
//  Pattern.swift
//  Typology
//
//  Created by Max Desiatov on 07/06/2019.
//

import Foundation
import SwiftSyntax

protocol Pattern: Location {}

extension PatternSyntax {
  func toPattern(_ converter: SourceLocationConverter) throws -> Pattern {
    switch self {
    case let syntax as TuplePatternSyntax:
      return try TuplePattern(
        elements: syntax.elements.map { try TuplePatternElement($0, converter) },
        range: syntax.sourceRange(converter: converter)
      )
    case let syntax as IdentifierPatternSyntax:
      return IdentifierPattern(
        identifier: syntax.identifier.text,
        range: syntax.sourceRange(converter: converter)
      )
    default:
      throw ASTError(self, .unknownSyntax, converter)
    }
  }
}
