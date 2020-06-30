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
      throw ASTError(syntax.accessorKind._syntaxNode, .unknownSyntax, converter)
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
  init(_ syntax: SyntaxProtocol?, _ converter: SourceLocationConverter) throws {
    if let block = syntax.flatMap({ CodeBlockSyntax($0._syntaxNode) }) {
      self = try [AccessorDecl(
        body: [Statement](block.statements, converter),
        kind: .get,
        range: block.sourceRange(converter: converter)
      )]
    } else if let block = syntax.flatMap({ AccessorBlockSyntax($0._syntaxNode) }) {
      self = try block.accessors.map { try AccessorDecl($0, converter) }
    } else if let syntax = syntax {
      throw ASTError(syntax._syntaxNode, .unknownSyntax, converter)
    } else {
      self = []
    }
  }
}
