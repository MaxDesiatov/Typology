//
//  Protocol.swift
//  Typology
//
//  Created by Max Desiatov on 27/05/2019.
//

struct Predicate {
  let subject: Type
  let inherited: ProtocolIdentifier
}

struct GenericConstraint<T> {
  let predicates: [Predicate]
  let constrained: T
}

struct ProtocolIdentifier: Hashable {
  let value: String
}

extension ProtocolIdentifier: ExpressibleByStringLiteral {
  init(stringLiteral value: String) {
    self.value = value
  }
}

typealias ConformanceDeclaration = GenericConstraint<Predicate>

struct Protocol {
  let inherited: [ProtocolIdentifier]
  let members: Environment
}
