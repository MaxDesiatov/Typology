//
//  Accessor.swift
//  Typology
//
//  Created by Max Desiatov on 07/06/2019.
//

import Foundation
import SwiftSyntax

struct AccessorDecl: Location {
  enum Kind: String {
    case get
    case set
  }

  let body: [Statement]
  let kind: Kind

  let range: SourceRange
}

extension AccessorDecl {
  init(_ syntax: AccessorDeclSyntax, _ converter: SourceLocationConverter) throws {
    guard let kind = Kind(rawValue: syntax.accessorKind.text) else {
      throw ASTError(syntax.accessorKind, .unknownSyntax, converter)
    }

    let statements = syntax.body?.statements

    try self.init(
      body: statements.map { try [Statement]($0, converter) } ?? [],
      kind: kind,
      range: syntax.sourceRange(converter: converter)
    )
  }
}

extension Array where Element == AccessorDecl {
  init(_ maybeSyntax: Syntax?, _ converter: SourceLocationConverter) throws {
    switch maybeSyntax {
    case let block as CodeBlockSyntax:

      self = try [AccessorDecl(
        body: [Statement](block.statements, converter),
        kind: .get,
        range: block.sourceRange(converter: converter)
      )]
    case let block as AccessorBlockSyntax:
      self = try block.accessors.map { try AccessorDecl($0, converter) }
    case nil:
      self = []
    case let syntax?:
      throw ASTError(syntax, .unknownSyntax, converter)
    }
  }
}
