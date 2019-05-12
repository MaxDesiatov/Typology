//
//  Type.swift
//  Typology
//
//  Created by Max Desiatov on 27/04/2019.
//

indirect enum Type: Equatable {
  case variable(TypeVariable)
  case constructor(String)
  case arrow(Type, Type)

  static let boolType   = Type.constructor("Bool")
  static let stringType = Type.constructor("String")
  static let doubleType = Type.constructor("Double")
  static let intType    = Type.constructor("Int")
  
  func bind(to variable: TypeVariable) throws -> Substitution {
    if self == .variable(variable) {
      return [:]
    } else if occurs(variable) {
      throw TypeError.infiniteType(variable, self)
    }

    return [variable: self]
  }

  func unify(_ t2: Type) throws -> Substitution {
    switch (self, t2) {
    case let (.arrow(i1, o1), .arrow(i2, o2)):
      let s1 = try i1.unify(i2)
      let s2 = try o1.apply(s1).unify(o2.apply(s1))
      return s2.compose(s1)
    case let (.variable(v), t):
      return try t.bind(to: v)
    case let (t, .variable(v)):
      return try t.bind(to: v)
    case let (.constructor(a), .constructor(b)) where a == b:
      return [:]
    case let (a, b):
      throw TypeError.unificationFailure(a, b)
    }
  }
}
