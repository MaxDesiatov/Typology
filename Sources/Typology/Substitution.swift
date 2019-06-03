//
//  Substitution.swift
//  Typology
//
//  Created by Max Desiatov on 27/04/2019.
//

typealias Substitution = [TypeVariable: Type]

extension Substitution {
  /// It is up to the implementation of the inference algorithm to ensure that
  /// clashes do not occur between substitutions.
  func compose(_ sub: Substitution) -> Substitution {
    return sub.mapValues { $0.apply(self) }.merging(self) { value, _ in value }
  }
}

protocol Substitutable {
  func apply(_ sub: Substitution) -> Self
  var freeTypeVariables: Set<TypeVariable> { get }
}

extension Substitutable {
  func occurs(_ typeVariable: TypeVariable) -> Bool {
    return freeTypeVariables.contains(typeVariable)
  }
}

extension TypeVariable: Substitutable {
  var freeTypeVariables: Set<TypeVariable> {
    return [self]
  }

  func apply(_ sub: Substitution) -> TypeVariable {
    if case let .variable(v)? = sub[self] {
      return v
    } else {
      return self
    }
  }
}

extension Type: Substitutable {
  func apply(_ sub: Substitution) -> Type {
    switch self {
    case let .variable(v):
      return sub[v] ?? .variable(v)
    case let .arrow(t1, t2):
      return .arrow(t1.apply(sub), t2.apply(sub))
    case .constructor:
      return self
    case let .tuple(types):
      return .tuple(types.map { $0.apply(sub) })
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
    case let .tuple(types):
      return types.freeTypeVariables
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
    return Scheme(type, variables: variables)
  }

  var freeTypeVariables: Set<TypeVariable> {
    return type.freeTypeVariables.subtracting(variables)
  }
}

extension Array: Substitutable where Element: Substitutable {
  func apply(_ sub: Substitution) -> [Element] {
    return map { $0.apply(sub) }
  }

  var freeTypeVariables: Set<TypeVariable> {
    return reduce([]) { $0.union($1.freeTypeVariables) }
  }
}

extension Environment: Substitutable {
  func apply(_ sub: Substitution) -> Environment {
    return mapValues { $0.apply(sub) }
  }

  var freeTypeVariables: Set<TypeVariable> {
    return Array(values).freeTypeVariables
  }
}

extension Constraint: Substitutable {
  func apply(_ sub: Substitution) -> Constraint {
    switch self {
    case let .equal(t1, t2):
      return .equal(t1.apply(sub), t2.apply(sub))
    case let .member(type, member, mt):
      return .member(type.apply(sub), member: member, memberType: mt.apply(sub))
    case let .disjunction(id, type, alternatives):
      return .disjunction(
        id,
        assumption: type.apply(sub),
        alternatives: alternatives.apply(sub)
      )
    }
  }

  var freeTypeVariables: Set<TypeVariable> {
    switch self {
    case let .equal(t1, t2):
      return t1.freeTypeVariables.union(t2.freeTypeVariables)
    case let .member(type, _, memberType):
      return type.freeTypeVariables.union(memberType.freeTypeVariables)
    case let .disjunction(_, type, alternatives):
      return type.freeTypeVariables.union(alternatives.freeTypeVariables)
    }
  }
}
