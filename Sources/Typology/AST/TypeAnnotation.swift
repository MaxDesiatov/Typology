//
//  TypeAnnotation.swift
//  Typology
//
//  Created by Max Desiatov on 07/06/2019.
//

import Foundation
import SwiftSyntax

struct TypeAnnotation: Location {
  let type: Type

  let range: SourceRange
}

extension TypeAnnotation {
  init(_ syntax: TypeAnnotationSyntax, _ converter: SourceLocationConverter) throws {
    self.init(
      type: try Type(syntax.type, converter),
      range: syntax.sourceRange(converter: converter)
    )
  }

  init(_ syntax: TypeSyntax, _ converter: SourceLocationConverter) throws {
    self.init(
      type: try Type(syntax, converter),
      range: syntax.sourceRange(converter: converter)
    )
  }
}
