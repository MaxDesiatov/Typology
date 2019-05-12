//
//  TypologyTests.swift
//  Typology
//
//  Created by Max Desiatov on 16/04/2019.
//  Copyright © 2019 Typology. All rights reserved.
//

import Foundation
import XCTest
@testable import Typology

class TypologyTests: XCTestCase {
  func testTernary() throws {
    let string = Expr.ternary(
      .literal(.bool(true)),
      .literal(.string("then")),
      .literal(.string("else"))
    )
    let int = Expr.ternary(
      .literal(.bool(false)),
      .literal(.integer(0)),
      .literal(.integer(42))
    )
    let error = Expr.ternary(
      .literal(.bool(true)),
      .literal(.string("then")),
      .literal(.integer(42))
    )

    XCTAssertEqual(try string.infer(), .stringType)
    XCTAssertEqual(try int.infer(), .intType)
    XCTAssertThrowsError(try error.infer())
  }

  func testApplication() throws {
    let increment = Expr.application(
      .identifier("increment"),
      .literal(.integer(0))
    )
    let stringify = Expr.application(
      .identifier("stringify"),
      .literal(.integer(0))
    )
    let error = Expr.application(
      .identifier("increment"),
      .literal(.bool(false))
    )
    let environment: TypeEnv = [
      "increment": .init(.arrow(.intType, .intType)),
      "stringify": .init(.arrow(.intType, .stringType))
    ]

    XCTAssertEqual(try increment.infer(in: environment), .intType)
    XCTAssertEqual(try stringify.infer(in: environment), .stringType)
    XCTAssertThrowsError(try error.infer())
  }

  static var allTests = [
    ("testTernary", testTernary),
  ]
}
