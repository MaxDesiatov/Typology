//
//  Type.swift
//  Typology
//
//  Created by Max Desiatov on 27/04/2019.
//

typealias TypeIdentifier = String

indirect enum Type: Equatable {
  case variable(TypeVariable)
  case constructor(TypeIdentifier, [Type])
  case arrow(Type, Type)

  static let bool   = Type.constructor("Bool", [])
  static let string = Type.constructor("String", [])
  static let double = Type.constructor("Double", [])
  static let int    = Type.constructor("Int", [])
}
