//
//  PatternBinding.swift
//  Typology
//
//  Created by Max Desiatov on 07/06/2019.
//

import Foundation
import SwiftSyntax

struct PatternBinding: Location {
  let accessors: [AccessorDecl]
  let pattern: Pattern
  let typeAnnotation: TypeAnnotation?

  let range: SourceRange
}

extension PatternBinding {
  init(_ syntax: PatternBindingSyntax, _ file: URL) throws {
    try self.init(
      accessors: .init(syntax.accessor, file),
      pattern: syntax.pattern.toPattern(file),
      typeAnnotation: syntax.typeAnnotation.map {
        try TypeAnnotation($0, file)
      },
      range: syntax.sourceRange(in: file)
    )
  }
}
