//
//  Substitution.swift
//  Typology
//
//  Created by Max Desiatov on 27/04/2019.
//

typealias TypeVariable = String
typealias Substitution = [TypeVariable: Type]

extension Substitution {
  /// It is up to the implementation of the inference algorithm to ensure that
  /// clashes do not occur between substitutions.
  func compose(_ sub: Substitution) -> Substitution {
    return sub.mapValues { $0.apply(self) }.merging(self) { value, _ in value }
  }
}

protocol Substitutable {
  func apply(_: Substitution) -> Self
  var freeTypeVariables: Set<TypeVariable> { get }
}

extension Substitutable {
  func occurs(_ typeVariable: TypeVariable) -> Bool {
    return freeTypeVariables.contains(typeVariable)
  }
}

extension Type: Substitutable {
  func apply(_ sub: Substitution) -> Type {
    switch self {
    case let .variable(v):
      return sub[v] ?? .variable(v)
    case let .arrow(t1, t2):
      return .arrow(t1.apply(sub), t2.apply(sub))
    case let .constructor(c):
      // no substitutions for a plain type constructor
      return .constructor(c)
    }
  }

  var freeTypeVariables: Set<TypeVariable> {
    switch self {
    case .constructor:
      return []
    case let .variable(v):
      return [v]
    case let .arrow(t1, t2):
      return t1.freeTypeVariables.union(t2.freeTypeVariables)
    }
  }
}

extension Scheme: Substitutable {
  func apply(_ sub: Substitution) -> Scheme {
    let type = self.type.apply(variables.reduce(sub) {
      var result = $0
      result[$1] = nil
      return result
    })
    return Scheme(variables: variables, type: type)
  }

  var freeTypeVariables: Set<TypeVariable> {
    return type.freeTypeVariables.subtracting(variables)
  }
}

extension Array: Substitutable where Element: Substitutable {
  func apply(_ sub: Substitution) -> Array<Element> {
    return map { $0.apply(sub) }
  }

  var freeTypeVariables: Set<TypeVariable> {
    return reduce([]) { $0.union($1.freeTypeVariables) }
  }
}

extension TypeEnv: Substitutable {
  func apply(_ sub: Substitution) -> TypeEnv {
    return mapValues { $0.apply(sub) }
  }

  var freeTypeVariables: Set<TypeVariable> {
    return Array(values).freeTypeVariables
  }
}
