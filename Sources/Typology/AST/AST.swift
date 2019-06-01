//
//  AST.swift
//  Typology
//
//  Created by Max Desiatov on 19/04/2019.
//

typealias Identifier = String
typealias Operator = String

struct File {
  let statements: [Statement]
}

struct WhereClause {
}

struct InheritanceClause {
  var types: [NominalType]
}

protocol ExprType {}

struct FunctionType: ExprType {
  var genericParameters: [GenericParameter]
  var parameters: [ExprType]
}

struct TupleType: ExprType {
}

struct NominalType: ExprType {
  var name: String
  var parameters: [GenericParameter]
}

struct GenericParameter {
  var name: String
  var inheritance: InheritanceClause
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

struct Module {
  var files: [File]
}

struct Target {
  var dependencies: [Module]
  var main: Module
}
