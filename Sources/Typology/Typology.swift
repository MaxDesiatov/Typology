//
//  Typology.swift
//  Typology
//
//  Created by Max Desiatov on 16/04/2019.
//  Copyright © 2019 Typology. All rights reserved.
//

import SwiftSyntax

struct WhereClause {
}

struct InheritanceClause {
  var types: [NominalType]
}

struct FunctionType {
}

struct TupleType {
}

struct NominalType {
  var name: String
  var parameters: [GenericParameter]
}

struct TypeSignature {
}

struct GenericParameter {
  var name: String
  var inheritance: InheritanceClause
}

struct GenericParameterClause {

}

struct TypealiasDecl {
  var identifier: String
  var initializer: String
  var whereClause: WhereClause?
}

protocol Statement {}

struct FunctionDecl {
  var statements: [Statement]
}

struct ProtocolDecl {
  var conformance: [InheritanceClause]
  var functions: [FunctionDecl]
  var structs: [ConcreteTypeDecl]
}

struct CaseDecl {
}

struct EnumDecl {
  var cases: [CaseDecl]
}

struct ConcreteTypeDecl {
  enum Nature {
    case `class`
    case `struct`
  }

  var functions: [FunctionDecl]
  var typealiases: [TypealiasDecl]
  var structs: [ConcreteTypeDecl]
  var enums: [EnumDecl]
  var classes: [ConcreteTypeDecl]
}

struct ImportDecl {
  var path: [String]
}

struct File {
  var imports: [ImportDecl]
  var functions: [FunctionDecl]
  var statements: [Statement]
  var concreteTypes: [ConcreteTypeDecl]
  var protocols: [ProtocolDecl]
}

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
