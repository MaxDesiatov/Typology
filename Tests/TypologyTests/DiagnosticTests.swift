//
//  DiagnosticTests.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/11/19.
//

@testable import Typology
import XCTest

final class DiagnosticTests: XCTestCase {
  func testOffsetGenearateFunction() throws {
    XCTAssertEqual("\(offset(0, 100))".count, 3)
  }
}
