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
    let whatever = Expr.ternary(
      .literal(.bool(true)),
      .literal(.string("then")),
      .literal(.integer(42))
    )

    XCTAssertEqual(try string.infer(), .stringType)
    XCTAssertEqual(try int.infer(), .intType)
    XCTAssertThrowsError(try whatever.infer())
  }

  static var allTests = [
    ("testTernary", testTernary),
  ]
}
