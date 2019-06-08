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
  init(_ syntax: TypeAnnotationSyntax, _ file: URL) throws {
    self.init(
      type: try Type(syntax.type, file),
      range: syntax.sourceRange(in: file)
    )
  }

  init(_ syntax: TypeSyntax, _ file: URL) throws {
    self.init(
      type: try Type(syntax, file),
      range: syntax.sourceRange(in: file)
    )
  }
}
