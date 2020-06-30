//
//  Protocol.swift
//  Typology
//
//  Created by Max Desiatov on 27/05/2019.
//

struct ProtocolIdentifier: Hashable {
  let value: String
}

extension ProtocolIdentifier: ExpressibleByStringLiteral {
  init(stringLiteral value: String) {
    self.value = value
  }
}

struct Protocol {
  let inherited: [ProtocolIdentifier]
  let members: Environment
}
