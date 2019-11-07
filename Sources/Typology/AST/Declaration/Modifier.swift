//
//  File.swift
//  Typology
//
//  Created by Max Desiatov on 07/06/2019.
//

import Foundation
import SwiftSyntax

/// Declaration modifiers such as `private`, `public`, `dynamic` etc.
struct Modifier: Location {
  /// The main name of the modifier
  let name: String

  /// Used to specify granular access, such as `private(set)`
  let detail: String?

  let range: SourceRange
}

extension Modifier {
  init(_ syntax: DeclModifierSyntax, _ converter: SourceLocationConverter) {
    self.init(
      name: syntax.name.text,
      detail: syntax.detail?.text,
      range: syntax.sourceRange(converter: converter)
    )
  }
}
