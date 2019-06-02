//
//  TypeError.swift
//  Typology
//
//  Created by Max Desiatov on 28/05/2019.
//

enum TypeError: Error {
  case arrowMember(Identifier)
  case infiniteType(TypeVariable, Type)
  case tupleIndexOutOfRange(total: Int, addressed: Int)
  case unificationFailure(Type, Type)
  case unknownMember(TypeIdentifier, Identifier)
  case unknownTupleMember(Identifier)
  case unbound(Identifier)
}
