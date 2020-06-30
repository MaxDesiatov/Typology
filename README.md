# Typology

![CI status](https://github.com/MaxDesiatov/Typology/workflows/CI/badge.svg?branch=main)
[![Coverage](https://img.shields.io/codecov/c/github/MaxDesiatov/Typology/main.svg?style=flat)](https://codecov.io/gh/maxdesiatov/Typology)

Typology is a work in progress attempt to implement type checking of Swift in Swift itself.
Currently it uses [SwiftSyntax](https://github.com/apple/swift-syntax) as a parser, but is ready
to switch to other pure Swift parsers in the future when any are available.

## Goals

- **Education**: understanding how type checking can be implemented in a Swift
  compiler
- **User Experience**: finding the best way to report type errors and to improve
  related developer tools
- **Research and Experimentation**: prototyping advanced features that could be
  fully developed within Swift's type system.

## How does it work?

Same as [the type checker in Apple's Swift
compiler](https://github.com/apple/swift/blob/master/docs/TypeChecker.rst),
Typology relies on the fact that you can express [type
systems](https://en.m.wikipedia.org/wiki/Hindley–Milner_type_system) with a set of constraints
on types that are resolved through [unification](<https://en.wikipedia.org/wiki/Unification_(computer_science)>).

## See also

### Type systems and type checkers

- [Apple's Swift Compiler Type Checker Design and Implementation](https://github.com/apple/swift/blob/master/docs/TypeChecker.rst) by multiple contributors
- [A Type System From Scratch](https://www.youtube.com/watch?v=IbjoA5xVUq0) by [@CodaFi](https://github.com/CodaFi)
- [Write You a Haskell: Hindley-Milner Inference](http://dev.stephendiehl.com/fun/006_hindley_milner.html) by [@sdiehl](https://github.com/sdiehl)
- [Typing Haskell in Haskell](http://web.cecs.pdx.edu/~mpj/thih/TypingHaskellInHaskell.html) by [Mark P Jones](https://web.cecs.pdx.edu/~mpj/)
- [“What part of Hindley-Milner do you not understand?”](https://stackoverflow.com/questions/12532552/what-part-of-hindley-milner-do-you-not-understand) question and answers on StackOverflow
- [So you want to write a type checker...](http://languagengine.co/blog/so-you-want-to-write-a-type-checker/) by [@psygnisfive](https://github.com/psygnisfive)
- [Exponential time complexity in the Swift type checker](https://www.cocoawithlove.com/blog/2016/07/12/type-checker-issues.html) by [@mattgallagher](https://github.com/mattgallagher)
- [A Swift Playground containing Martin Grabmüller's "Algorithm W Step-by-Step"](https://gist.github.com/CodaFi/ca35a0c22fbd96eca505b5df45f2509e) by [@CodaFi](https://github.com/CodaFi)

### Error reporting

- [Compiler Errors for Humans](https://elm-lang.org/blog/compiler-errors-for-humans) on [Elm blog](https://elm-lang.org/blog)
- [Shape of errors to come in Rust compiler](https://blog.rust-lang.org/2016/08/10/Shape-of-errors-to-come.html) by [Jonathan Turner](https://github.com/jonathandturner)

### Optimizing type checker's performance for large projects

- [Apple's Swift Compiler Dependency Analysis](https://github.com/apple/swift/blob/master/docs/DependencyAnalysis.rst) by multiple contributors
