//
//  ASTTests.swift
//  TypologyTests
//
//  Created by Max Desiatov on 01/06/2019.
//

@testable import TypologyCore
import XCTest

let root = URL(fileURLWithPath: #file)
  .deletingLastPathComponent()
  .deletingLastPathComponent()
  .deletingLastPathComponent()
  .appendingPathComponent("ValidationTests/AST/")

final class ASTTests: XCTestCase {
  func testTernary() throws {
    let string = try #"true ? "then" : "else""# .parseAST()
      .statements.first as? ExprNode
    let int = try "false ? 0 : 42".parseAST()
      .statements.first as? ExprNode
    let error = try #"true ? "then" : 42"# .parseAST()
      .statements.first as? ExprNode

    XCTAssertEqual(try string?.expr.infer(), .string)
    XCTAssertEqual(try int?.expr.infer(), .int)
    XCTAssertThrowsError(try error?.expr.infer())
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

  func testFuncPosition() throws {
    let functions = try
      """
          // declare function #commentsForComments
          //This is also a comment
          //    but is written over multiple lines.
          func first(_ x: String) -> String {
              var x: String {
                return "Hello"
              }
              var y: String {
                get {
                  return "Hello, "
                }
                set {
                  print("world!")
                }
              }
              dynamic private(set) let a: Double = 3.14, b: Int
              let z = 5
              let (x, y) = z

              return x
          }

          /* This is also a comment
              but is written over multiple lines. */
          // declare another function with double offset #commentsForComments
              func second(_ x: String) -> String {
                  return x
              }
      """.parseAST()

    let firstFunc = functions.statements.first
    let secondFunc = functions.statements.last

    XCTAssertEqual(firstFunc?.range.start.line, 4)
    XCTAssertEqual(firstFunc?.range.start.column, 5)
    XCTAssertEqual(firstFunc?.range.end.line, 21)
    XCTAssertEqual(firstFunc?.range.end.column, 6)

    XCTAssertEqual(secondFunc?.range.start.line, 26)
    XCTAssertEqual(secondFunc?.range.start.column, 9)
    XCTAssertEqual(secondFunc?.range.end.line, 28)
    XCTAssertEqual(secondFunc?.range.end.column, 10)
  }

  func testInitFromFilePositive() throws {
    let url = root.appendingPathComponent("Positive.swift")
    XCTAssertNoThrow(try File(path: url.path))
  }

  func testInitFromFileNegative() throws {
    let url = root.appendingPathComponent("Negative.swift")
    XCTAssertThrowsError(try File(path: url.path))
  }
}
