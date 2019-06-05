//
//  ASTTests.swift
//  TypologyTests
//
//  Created by Max Desiatov on 01/06/2019.
//

@testable import Typology
import XCTest

final class ASTTests: XCTestCase {
  func testTernary() throws {
    let string = try #"true ? "then" : "else""# .parseAST()
      .statements.first as? Expr
    let int = try "false ? 0 : 42".parseAST()
      .statements.first as? Expr
    let error = try #"true ? "then" : 42"# .parseAST()
      .statements.first as? Expr

    XCTAssertEqual(try string?.infer(), .string)
    XCTAssertEqual(try int?.infer(), .int)
    XCTAssertThrowsError(try error?.infer())
  }

  func testFunc() throws {
    let f = try "func x(_ x: String, y: [Int]) -> Int { return 42 }"
      .parseAST().statements.first as? FunctionDecl

    XCTAssertEqual(f?.scheme, Scheme(
      [.string, .constructor("Array", [.int])] --> .int
    ))
  }

  func testGenericFunc() throws {
    let f = try "func x<T>(_ x: T, _ y: T) -> T { return x }"
      .parseAST().statements.first as? FunctionDecl

    let tVar = "T"
    let t = Type.constructor(TypeIdentifier(value: tVar), [])

    XCTAssertEqual(f?.scheme, Scheme(
      [t, t] --> t,
      variables: [TypeVariable(value: tVar)]
    ))
  }
}
