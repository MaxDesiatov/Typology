//
//  Attribute.swift
//  Typology
//
//  Created by Max Desiatov on 07/06/2019.
//

import Foundation
import SwiftSyntax

/// Declaration attributes such as @objc
struct Attribute: Location {
  let name: String
  let argument: String?

  let range: SourceRange
}

extension Attribute {
  init(_ syntax: AttributeSyntax, _ file: URL) {
    self.init(
      name: syntax.attributeName.text,
      argument: (syntax.argument as? ObjCSelectorSyntax)?.description,
      range: syntax.sourceRange(in: file)
    )
  }
}
