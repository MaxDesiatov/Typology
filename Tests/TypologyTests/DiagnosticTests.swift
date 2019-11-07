//
//  DiagnosticTests.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/11/19.
//

import SwiftCLI
import SwiftSyntax
@testable import Typology
import XCTest

final class DiagnosticTests: XCTestCase {
  func testIsSwiftFile() throws {
    XCTAssertTrue(isSwiftFile("/FileName.swift"))
    XCTAssertFalse(isSwiftFile("/FileName.sh"))
    XCTAssertFalse(isSwiftFile("/FileName.yml"))
  }

  func testParseFile() throws {
    let consoleConsumer = ConsoleDiagnosticConsumer()
    let urlPositive = root.appendingPathComponent("Positive.swift")
    let urlNegative = root.appendingPathComponent("Negative.swift")
    XCTAssertNoThrow(
      try parseFile(
        path: urlPositive.path,
        consumers: [consoleConsumer]
      )
    )
    XCTAssertNoThrow(
      try parseFile(
        path: urlNegative.path,
        consumers: [consoleConsumer]
      )
    )
  }

  func testOffsetGenerateFunction() throws {
    XCTAssertEqual("\(offset(1, 234))", "   ")
    XCTAssertEqual("\(offset(56, 7890))", "   ")
    XCTAssertEqual("\(offset(11, 123))", "  ")
  }

  func testTypologyDiagnosticEngine() throws {
    // Test diagnose add consumer functional
    let filePath = root.appendingPathComponent("Positive.swift").path
    let contents = try String(contentsOfFile: filePath)
    let lines = contents.components(separatedBy: .newlines)
    let engine = TypologyDiagnosticEngine(fileContent: lines)
    let consoleConsumer = ConsoleDiagnosticConsumer()
    let consoleConsumer1 = ConsoleDiagnosticConsumer()
    engine.addConsumer(consoleConsumer)
    XCTAssertEqual(engine.consumers.count, 1)

    // Test to call TypologyDiagnosticEngine.deinit while test
    _ = TypologyDiagnosticEngine(fileContent: lines)

    // Test diagnose handle message functional
    let message = Diagnostic.Message(.note, "note message")
    XCTAssertNoThrow(engine.diagnose(message))

    // Test diagnose on previous added diagnostic with new added comsumer
    engine.addConsumer(consoleConsumer1)

    // Test when diagnose handle diagnostic that takes one line
    let location = SourceLocation(
      line: 1,
      column: 1,
      offset: 1,
      file: filePath
    )
    let diagnostic = TypologyDiagnostic(
      message: message,
      location: location,
      notes: [],
      highlights: [
        SourceRange(
          start: location,
          end: location
        ),
      ],
      fixIts: []
    )
    XCTAssertNoThrow(engine.diagnose(diagnostic))

    // Test when diagnose handle diagnostic that takes multiple lines
    let location2 = SourceLocation(
      line: 3,
      column: 1,
      offset: 1,
      file: filePath
    )
    let location3 = SourceLocation(
      line: 4,
      column: 4,
      offset: 4,
      file: filePath
    )

    let diagnostic2 = TypologyDiagnostic(
      message: message,
      location: location2,
      notes: [],
      highlights: [
        SourceRange(
          start: location,
          end: location3
        ),
      ],
      fixIts: []
    )
    XCTAssertNoThrow(engine.diagnose(diagnostic2))
  }
}
