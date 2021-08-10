//
//  Function.swift
//  Typology
//
//  Created by Max Desiatov on 07/06/2019.
//

import Foundation
import SwiftSyntax

struct FunctionDecl: Statement {
  let genericParameters: [TypeVariable]
  let parameters: [(externalName: String?, internalName: String?, TypeAnnotation)]
  let statements: [Statement]
  let returns: TypeAnnotation?

  let range: SourceRange

  var scheme: Scheme {
    return Scheme(
      parameters.map { $0.internalName.type } --> (returns?.type ?? .tuple([])),
      variables: genericParameters
    )
  }
}

extension FunctionDecl {
  init(_ syntax: FunctionDeclSyntax, _ converter: SourceLocationConverter) throws {
    let returns = syntax.signature.output?.returnType
    let body = syntax.body?.statements

    try self.init(
      genericParameters: syntax.genericParameterClause?
        .genericParameterList.map {
          TypeVariable(value: $0.name.text)
        } ?? [],
      parameters: syntax.signature.input.parameterList
        .compactMap { parameter -> (String?, String?, TypeAnnotation)? in
          guard let type = parameter.type else { return nil }
          return try (
            parameter.firstName?.text,
            parameter.secondName?.text,
            TypeAnnotation(type, converter)
          )
        },
      statements: body.flatMap { try [Statement]($0, converter) } ?? [],
      returns: returns.map {
        try TypeAnnotation($0, converter)
      },
      range: syntax.sourceRange(converter: converter)
    )
  }
}
