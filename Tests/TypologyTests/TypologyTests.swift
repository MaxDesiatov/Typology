//
//  TypologyTests.swift
//  Typology
//
//  Created by Max Desiatov on 16/04/2019.
//  Copyright © 2019 Typology. All rights reserved.
//

import XCTest
@testable import Typology

class TypologyTests: XCTestCase {
  func testTernary() throws {
    let string = Expr.ternary(
      .literal(true),
      .literal("then"),
      .literal("else")
    )
    let int = Expr.ternary(
      .literal(.bool(false)),
      .literal(0),
      .literal(42)
    )
    let error = Expr.ternary(
      .literal(true),
      .literal("then"),
      .literal(42)
    )

    XCTAssertEqual(try string.infer(), .string)
    XCTAssertEqual(try int.infer(), .int)
    XCTAssertThrowsError(try error.infer())
  }

  func testApplication() throws {
    let increment = Expr.application("increment", .literal(0))

    let stringify = Expr.application("stringify", .literal(0))
    let error = Expr.application("increment", .literal(false))

    let e: Environment = [
      "increment": .init(.arrow(.int, .int)),
      "stringify": .init(.arrow(.int, .string))
    ]

    XCTAssertEqual(try increment.infer(environment: e), .int)
    XCTAssertEqual(try stringify.infer(environment: e), .string)
    XCTAssertThrowsError(try error.infer())
  }

  func testLambda() throws {
    let lambda = Expr.lambda(
      "x",
      .application(
        "decode",
        .application(
          "stringify",
          .application("increment", "x"))))

    let error = Expr.lambda(
      "x",
      .application(
        "stringify",
        .application(
          "decode",
          .application("increment", "x"))))

    let e: Environment = [
      "increment": .init(.arrow(.int, .int)),
      "stringify": .init(.arrow(.int, .string)),
      "decode": .init(.arrow(.string, .int)),
    ]

    XCTAssertEqual(try lambda.infer(environment: e), .arrow(.int, .int))
    XCTAssertThrowsError(try error.infer())
  }

  func testMember() throws {
    let appending = Expr.application(.member(.literal("Hello, "), "appending"),
                                     .literal(" World"))
    let count = Expr.application(.member(.literal("Test"), "count"), .tuple([]))

    let t: Types = ["String":
      [
        "appending": .init(.arrow(.string, .string)),
        "count": .init(.arrow(.tuple([]), .int))
      ]
    ]

    XCTAssertEqual(try appending.infer(types: t), .string)
    XCTAssertEqual(try count.infer(types: t), .int)
  }

  func testTupleMember() throws {
    let tuple = Expr.tuple([.literal(42), .literal("forty two")])

    XCTAssertEqual(try Expr.member(tuple, "0").infer(), .int)
    XCTAssertEqual(try Expr.member(tuple, "1").infer(), .string)
  }

  static var allTests = [
    ("testTernary", testTernary),
  ]
}
