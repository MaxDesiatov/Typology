//
//  Type.swift
//  Typology
//
//  Created by Max Desiatov on 27/04/2019.
//

struct TypeIdentifier: Equatable, Hashable {
  let value: String
}

extension TypeIdentifier: ExpressibleByStringLiteral {
  init(stringLiteral value: String) {
    self.value = value
  }
}

indirect enum Type: Equatable {
  case variable(TypeVariable)
  case constructor(TypeIdentifier, [Type])
  case arrow(Type, Type)
  case tuple([Type])

  static let bool   = Type.constructor("Bool", [])
  static let string = Type.constructor("String", [])
  static let double = Type.constructor("Double", [])
  static let int    = Type.constructor("Int", [])
}
