//
//  DiagnosticError.swift
//  Typology
//
//  Created by Max Desiatov on 07/06/2019.
//

import SwiftSyntax

protocol DiagnosticError: Error {
  var range: SourceRange { get }
}
