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
}
