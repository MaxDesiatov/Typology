//
//  TuplePattern.swift
//  Typology
//
//  Created by Max Desiatov on 07/06/2019.
//

import Foundation
import SwiftSyntax

struct TuplePattern: Pattern {
  let elements: [TuplePatternElement]
  let range: SourceRange
}

struct TuplePatternElement {
  let name: TuplePatternName?
  let pattern: Pattern
}

extension TuplePatternElement {
  init(_ syntax: TuplePatternElementSyntax, _ file: URL) throws {
    try self.init(
      name: syntax.labelName.map {
        .init(value: $0.text, range: $0.sourceRange(in: file))
      },
      pattern: syntax.pattern.toPattern(file)
    )
  }
}

struct TuplePatternName: Location {
  let value: String
  let range: SourceRange
}
