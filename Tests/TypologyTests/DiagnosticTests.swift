//
//  DiagnosticTests.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/11/19.
//

import SwiftSyntax
@testable import Typology
import XCTest

final class DiagnosticTests: XCTestCase {
  func testOffsetGenerateFunction() throws {
    XCTAssertEqual("\(offset(0, 100))".count, 3)
  }

  func testTypologyDiagnosticEngine() throws {
    // Test diagnose add consumer functional
    let filePath = root.appendingPathComponent("Positive.swift").path
    let contents = try String(contentsOfFile: filePath)
    let lines = contents.components(separatedBy: .newlines)
    let engine = TypologyDiagnosticEngine(fileContent: lines)
    let consoleConsumer = ConsoleDiagnosticConsumer()
    engine.addConsumer(consoleConsumer)
    XCTAssertEqual(engine.consumers.count, 1)

    // Test diagnose handle message functional
    let message = Diagnostic.Message(.note, "note message")
    XCTAssertNoThrow(engine.diagnose(message))

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
      file: filePath,
      position: AbsolutePosition(line: 4, column: 4, utf8Offset: 4)
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
