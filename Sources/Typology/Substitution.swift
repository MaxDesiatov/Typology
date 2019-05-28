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
  func apply(_ sub: Substitution) -> Self
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
    case let .variable(v, args):
      return sub[v] ?? .variable(v, args)
    case let .arrow(t1, t2):
      return .arrow(t1.apply(sub), t2.apply(sub))
    case let .constructor(c, args):
      // no substitutions for a plain type constructor
      return .constructor(c, args)
    case let .tuple(types):
      return .tuple(types.map { $0.apply(sub) })
    }
  }

  var freeTypeVariables: Set<TypeVariable> {
    switch self {
    case .constructor:
      return []
    case let .variable(v, args):
      return Set([v]).union(args.freeTypeVariables)
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
    return Scheme(variables: variables, constrained: type)
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
    }
  }

  var freeTypeVariables: Set<TypeVariable> {
    switch self {
    case let .equal(t1, t2):
      return t1.freeTypeVariables.union(t2.freeTypeVariables)
    }
  }
}

extension Predicate: Substitutable {
  func apply(_ substitution: Substitution) -> Predicate {
    return Predicate(subject: subject.apply(substitution), inherited: inherited)
  }

  var freeTypeVariables: Set<TypeVariable> {
    return subject.freeTypeVariables
  }
}

extension GenericConstraint: Substitutable where T: Substitutable {
  func apply(_ sub: Substitution) -> GenericConstraint<T> {
    return GenericConstraint(
      predicates: predicates.apply(sub),
      constrained: constrained.apply(sub)
    )
  }

  var freeTypeVariables: Set<TypeVariable> {
    return constrained.freeTypeVariables.union(predicates.freeTypeVariables)
  }
}
