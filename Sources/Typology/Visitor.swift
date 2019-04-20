//
//  Visitor.swift
//  Typology
//
//  Created by Max Desiatov on 16/04/2019.
//  Copyright © 2019 Typology. All rights reserved.
//

import SwiftSyntax

final class Visitor: SyntaxVisitor {
  override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
    node.path.map { $0.name.text }
    return .skipChildren
  }

  override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
    node.genericParameterClause
    return .skipChildren
  }

  override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
    node.genericParameterClause.first?.
    return .skipChildren
  }

  override func visit(_ node: TypealiasDeclSyntax) -> SyntaxVisitorContinueKind {
    node.identifier.text
    return .skipChildren
  }

  override func visit(_ node: ReturnStmtSyntax) -> SyntaxVisitorContinueKind {
    return .skipChildren
  }

  override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
    node
    return .skipChildren
  }
}
