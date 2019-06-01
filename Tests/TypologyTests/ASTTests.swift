//
//  ASTTests.swift
//  TypologyTests
//
//  Created by Max Desiatov on 01/06/2019.
//

import XCTest
@testable import Typology

final class ASTTests: XCTestCase {
  func testTernary() throws {
    let string = try #"true ? "then" : "else""#.parseAST()
      .statements.first as? Expr
    let int = try "false ? 0 : 42".parseAST()
      .statements.first as? Expr
    let error = try #"true ? "then" : 42"#.parseAST()
      .statements.first as? Expr

    XCTAssertEqual(try string?.infer(), .string)
    XCTAssertEqual(try int?.infer(), .int)
    XCTAssertThrowsError(try error?.infer())
  }
}
