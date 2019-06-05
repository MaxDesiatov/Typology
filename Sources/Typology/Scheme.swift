//
//  Scheme.swift
//  Typology
//
//  Created by Max Desiatov on 27/05/2019.
//

/** Schemes are types containing one or more generic variables. A scheme
 explicitly specifies variables bound in the current type, which allows those
 variables to be distinguished from those that were bound in an outer scope.
 */
struct Scheme: Equatable {
  /** Type containing variables bound in `variables` property.
   */
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
