# Typology

## Goals

* **Education**: understanding how type checking can be implemented in a Swift
  compiler
* **User Experience**: finding the best way to report type errors and to improve
  related developer tools
* **Research and Experimentation**: prototyping advanced features that could be
  fully developed within Swift's type system.

## How does it work?

Same as [the type checker in Apple's Swift
compiler](https://github.com/apple/swift/blob/master/docs/TypeChecker.rst),
Typology relies on the fact that you can express [type
systems](https://en.m.wikipedia.org/wiki/Hindley–Milner_type_system) with
[predicate logic](https://en.m.wikipedia.org/wiki/First-order_logic). This means
that verifying that your code is well-typed is essentially the same as verifying
that certain logical statements are

1. internally consistent: you don't use explicit type signatures that don't
   match;
2. have only one solution for variables in the system: type inference can
   resolve unknown types unambiguously.

Typology generates a sequence of predicates and rules for declarations and
expressions in your Swift source code.
