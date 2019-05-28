//
//  Scheme.swift
//  Typology
//
//  Created by Max Desiatov on 27/05/2019.
//

struct Scheme {
  /// Variables bound in this scheme
  let variables: [TypeVariable]

  let type: GenericConstraint<Type>

  init(variables: [TypeVariable], constrained: GenericConstraint<Type>) {
    self.variables = variables
    self.type = constrained
  }

  init(variables: [TypeVariable], type: Type) {
    self.variables = variables
    self.type = GenericConstraint(predicates: [], constrained: type)
  }

  init(_ type: Type) {
    self.variables = []
    self.type = GenericConstraint(predicates: [], constrained: type)
  }
}

