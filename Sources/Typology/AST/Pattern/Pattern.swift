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
  func toPattern(_ file: URL) throws -> Pattern {
    switch self {
    case let syntax as TuplePatternSyntax:
      return try TuplePattern(
        elements: syntax.elements.map { try TuplePatternElement($0, file) },
        range: syntax.sourceRange(in: file)
      )
    case let syntax as IdentifierPatternSyntax:
      return IdentifierPattern(
        identifier: syntax.identifier.text,
        range: syntax.sourceRange(in: file)
      )
    default:
      throw ASTError(self, .unknownSyntax, file)
    }
  }
}
