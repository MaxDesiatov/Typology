//
//  Scheme.swift
//  Typology
//
//  Created by Max Desiatov on 27/05/2019.
//

struct Scheme {
  let type: Type

  /// Variables bound in the scheme
  let variables: [TypeVariable]

  init(
    _ type: Type,
    variables: [TypeVariable] = []
  ) {
    self.type = type
    self.variables = variables
  }
}
