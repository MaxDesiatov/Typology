//
//  InferenceTests.swift
//  Typology
//
//  Created by Max Desiatov on 16/04/2019.
//  Copyright © 2019 Typology. All rights reserved.
//

@testable import Typology
import XCTest

final class InferenceTests: XCTestCase {
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
      "increment": [.init(.arrow(.int, .int))],
      "stringify": [.init(.arrow(.int, .string))],
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
          .application("increment", "x")
        )
      )
    )

    let error = Expr.lambda(
      "x",
      .application(
        "stringify",
        .application(
          "decode",
          .application("increment", "x")
        )
      )
    )

    let e: Environment = [
      "increment": [.init(.arrow(.int, .int))],
      "stringify": [.init(.arrow(.int, .string))],
      "decode": [.init(.arrow(.string, .int))],
    ]

    XCTAssertEqual(try lambda.infer(environment: e), .arrow(.int, .int))
    XCTAssertThrowsError(try error.infer())
  }

  func testLambdaApplication() throws {
    let lambda = Expr.application(
      .lambda("x", .ternary("x", .literal(1), .literal(0))), .literal(true)
    )

    let error = Expr.application(
      .lambda("x", .ternary("x", .literal(1), .literal(0))), .literal("blah")
    )

    XCTAssertEqual(try lambda.infer(), .int)
    XCTAssertThrowsError(try error.infer())
  }

  func testMember() throws {
    let appending = Expr.application(.member(.literal("Hello, "), "appending"),
                                     .literal(" World"))
    let count = Expr.application(.member(.literal("Test"), "count"), .tuple([]))

    let m: Members = [
      "String": [
        "appending": [.init(.arrow(.string, .string))],
        "count": [.init(.arrow(.tuple([]), .int))],
      ],
    ]

    XCTAssertEqual(try appending.infer(members: m), .string)
    XCTAssertEqual(try count.infer(members: m), .int)
  }

  func testMemberOfMember() throws {
    let literal = Expr.literal("Test")
    let magnitude = Expr.member(.member(literal, "count"), "magnitude")
    let error = Expr.member(.member(literal, "magnitude"), "count")

    let m: Members = [
      "String": [
        "count": [.init(.int)],
      ],
      "Int": [
        "magnitude": [.init(.int)],
      ],
    ]

    XCTAssertEqual(try magnitude.infer(members: m), .int)
    XCTAssertThrowsError(try error.infer(members: m))
  }

  func testLambdaMember() throws {
    let lambda = Expr.application(
      .lambda("x", .ternary("x", .literal("one"), .literal("zero"))),
      .literal(true)
    )
    let count = Expr.member(lambda, "count")
    let error = Expr.member(lambda, "magnitude")

    let m: Members = [
      "String": [
        "count": [.init(.int)],
      ],
      "Int": [
        "magnitude": [.init(.int)],
      ],
    ]

    XCTAssertEqual(try count.infer(members: m), .int)
    XCTAssertThrowsError(try error.infer(members: m))
  }

  func testTupleMember() throws {
    let tuple = Expr.tuple([.literal(42), .literal("forty two")])

    XCTAssertEqual(try Expr.member(tuple, "0").infer(), .int)
    XCTAssertEqual(try Expr.member(tuple, "1").infer(), .string)
  }

  func testOverload() throws {
    
  }

  static var allTests = [
    ("testTernary", testTernary),
  ]
}
