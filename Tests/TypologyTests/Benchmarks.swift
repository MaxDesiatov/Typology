//
//  Benchmarks.swift
//  SwiftSyntax
//
//  Created by Max Desiatov on 25/05/2019.
//

import XCTest
@testable import Typology

class Benchmarks: XCTestCase {
  func delayErrors(_ closure: (() -> ()) -> ()) throws {
    var caughtError: Error?

    closure {
      do {
        let environment: TypeEnv = [
          "increment": .init(.arrow(.int, .int)),
          "stringify": .init(.arrow(.int, .string)),
          "decode": .init(.arrow(.string, .int)),
        ]
        let lambda = Expr.lambda(
          "x",
          .application(
            "decode",
            .application(
              "stringify",
              .application("increment", .ternary(
                .literal(.bool(false)),
                "x",
                .literal(42))))))

        _ = try lambda.infer(in: environment)
      } catch {
        caughtError = error
      }
    }

    if let error = caughtError {
      throw error
    }
  }

  func testInference() throws {
      try delayErrors { closure in
        self.measure {
          closure()
        }
      }
  }
}
