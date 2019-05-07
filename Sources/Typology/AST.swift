//
//  AST.swift
//  Typology
//
//  Created by Max Desiatov on 19/04/2019.
//

typealias Identifier = String
typealias Operator = String

enum Literal {
  case integer(Int)
  case floating(Double)
  case bool(Bool)
  case string(String)

  var defaultType: Type {
    switch self {
    case .integer:
      return .constructor("Int")
    case .floating:
      return .constructor("Double")
    case .bool:
      return .constructor("Bool")
    case .string:
      return .constructor("String")
    }
  }
}

indirect enum Expr {
  case variable(Identifier)
  case application(Expr, Expr)
  case lambda(Identifier, Expr)
  case constant(Identifier, Expr, Expr)
  case literal(Literal)
  case ternary(Expr, Expr, Expr)
  case binaryOperator(Operator, Expr, Expr)
}

struct File {
  let declarations: [(Identifier, Expr)]
  let expressions: [Expr]
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

//struct File {
//  var imports: [ImportDecl]
//  var functions: [FunctionDecl]
//  var statements: [Statement]
//  var concreteTypes: [ConcreteTypeDecl]
//  var protocols: [ProtocolDecl]
//}
//
//struct Module {
//  var files: [File]
//}
//
//struct Target {
//  var dependencies: [Module]
//  var main: Module
//}
