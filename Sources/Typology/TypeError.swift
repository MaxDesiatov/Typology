//
//  TypeError.swift
//  Typology
//
//  Created by Max Desiatov on 28/05/2019.
//

enum TypeError: Error {
  case ambiguous(Identifier)
  case arrowMember(Identifier)
  case infiniteType(TypeVariable, Type)
  case noOverloadFound(Identifier, Type)
  case tupleIndexOutOfRange(total: Int, addressed: Int)
  case unificationFailure(Type, Type)
  case unknownType(TypeIdentifier)
  case unknownMember(TypeIdentifier, Identifier)
  case unknownTupleMember(Identifier)
  case unbound(Identifier)
  case tupleUnificationFailure(Identifier, Identifier)
}
