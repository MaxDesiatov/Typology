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
  /** A type constructor is an abstraction on which generics system is built.
   It is a "type function", which takes other types as arguments and returns
   a new type. `Type.constructor("Int", [])` represents an `Int` type, while
   `Type.constructor("Dictionary", ["String", "Int"])` represents a
   `[String: Int]` type (`Dictionary<String, Int>` when desugared).

   Examples:

   * `Int` and `String` are nullary type constructors, they
   don't take any type arguments and already represent a ready to use type.

   * `Array` is a unary type constructor, which takes a single type argument:
   a type of its element. `Array<Int>` is a type constructor applied to the
   `Int` argument and produces a type for an array of integers.

   * `Dictionary` is a binary type constructor with two type arguments
   for the key type and value type respectively. `Dictionary<String, Int>` is
   a binary type constructor applied to produce a dictionary from `String` keys
   to `Int` values.

   * `->` is a binary type constructor with two type arguments for the argument
   and for the return value of a function. It is written as a binary operator
   to produce a type like `Args -> Returned`. Note that we use a separate
   enum `case arrow(Type, Type)` for this due to a special treatment of function
   types in the type checker.

   Since type constructors are expected to be applied to a correct number of
   type arguments, it's useful to introduce a notion of
   ["kinds"](https://en.wikipedia.org/wiki/Kind_(type_theory)). As values have
   types that help to verify correctness of expressions at compile time, types
   have kinds that allow us to verify type constructor applications. Note that
   this is different from metatypes in Swift. Metatypes are still types and
   and metatype values can be stored as constants/variables and operated on in
   runtime. Kinds are completely separate from this and are a purely
   compile-time concept that help use to reason about generic types.

   In Typology's documentation we adopt a notation for kinds similar to the one
   used for Haskell, similar languages and type theory papers, but slightly
   modified for Swift. All nullary type constructors have a kind `*`, you can
   think of `*` as a "placeholder" for a type. If we use `::` to represent "has
   a kind" declarations, we could say that `Int :: *` or `String :: *`. Unary
   type constructors have a kind `<*> ~> *`, where `~>` is a binary operator for
   a "type function", and so `Array :: <*> ~> *`. A binary type constructor
   has a kind `<*, *> ~> *` and `Dictionary :: <*, *> ~> *.
   */
  case constructor(TypeIdentifier, [Type])

  /** A type variable used in generic type declarations. The most primitive
   type variables is the one without type arguments: `.variable("T", [])` (you
   can use any other free variable name instead of `"T"`).

   A type of a generic function

   ```
   func f<T>(_ arg: T) -> T
   ```

   can be represented as

   ```
   Type.arrow(.variable("T", []), .variable("T", []))
   ```

   Note the second array argument of `case variable(TypeVariable, [Type])`.
   In the example above, for a simple generic function the second argument
   is always an empty array, but we'd like to allow type variables to be proper
   type constructors, at least internally within Typology. While as of 2019
   Swift doesn't allow higher-kinded types, we're convinced that it would be a
   very welcome addition to Swift in the future and would like to have a
   built-in support for it in Typology from the start.

   An example of a higher-kinded type used a in a function declaration would be

   ```func f<T>(_ arg: T<Int>) -> T<Int>
   ```

   In Typology this would be represented as

   ```
   Type.arrow(.variable("T", [.int]), .variable("T", [.int]))
   ```

   With generic constraints a practical application of this would be a function

   ```
   func f<T>(_ arg: T<Int>) -> T<Int> where T<Int>: Sequence
   ```

   which would allow one to write a generic function operating on any arbitrary
   sequence of integers.
   */
  case variable(TypeVariable, [Type])

  /** Binary type operator `->` representing function types.
   */
  case arrow(Type, Type)

  /** Tuple types, where each element of an associated array is a corresponding
   type of the tuple's element.

   ```
   (Int, String, Bool)
   ```

   is represented in Typology as

   ```
   Type.tuple([.int, .string, .bool])
   ```
   */
  case tuple([Type])

  static let bool   = Type.constructor("Bool", [])
  static let string = Type.constructor("String", [])
  static let double = Type.constructor("Double", [])
  static let int    = Type.constructor("Int", [])
}
