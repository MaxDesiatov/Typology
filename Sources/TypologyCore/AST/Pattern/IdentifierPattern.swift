//
//  IdentifierPattern.swift
//  Typology
//
//  Created by Max Desiatov on 07/06/2019.
//

import Foundation
import SwiftSyntax

struct IdentifierPattern: Pattern {
  let identifier: String

  let range: SourceRange
}
