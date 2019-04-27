//
//  Inference.swift
//  Typology
//
//  Created by Max Desiatov on 27/04/2019.
//

enum Constraint {
  case equal(Type, Type)
}

struct Scheme {
  let variables: [TypeVariable]
  let type: Type
}

typealias Variable = String
typealias TypeEnv = [Variable: Scheme]

enum TypeError: Error {
  case infiniteType(TypeVariable, Type)
  case unificationFailure(Type, Type)
}

struct Inference {
  private var variableCount = 0
  var environment: TypeEnv
  var constraints: [Constraint]

  mutating func fresh() -> Type {
    defer { variableCount += 1 }

    return .variable("T\(variableCount)")
  }

  /// Converting a σ type into a τ type by creating fresh names for each type
  /// variable that does not appear in the current typing environment.
  mutating func instantiate(_ scheme: Scheme) -> Type {
    let substitution = scheme.variables.map { ($0, fresh()) }
    return scheme.type.apply(Dictionary(uniqueKeysWithValues: substitution))
  }

  /// Converting a τ type into a σ type by closing over all free type variables
  /// in a type scheme.
  func generalize(type: Type, in env: TypeEnv) -> Scheme {
    let variables = type.freeTypeVariables.subtracting(env.freeTypeVariables)
    return Scheme(variables: Array(variables), type: type)
  }

//  func infer(_ expr: Expr) -> Type {
//    switch expr {
//      case .literal(<#T##Literal#>)
//    }
//  }
}
