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

  func testTypologyDiagnosticEngine() throws {
    // Test diagnose add consumer
    let filePath = root.appendingPathComponent("Positive.swift").path
    let contents = try String(contentsOfFile: filePath)
    let lines = contents.components(separatedBy: .newlines)
    let engine = TypologyDiagnosticEngine(fileContent: lines)
    let consoleConsumer = ConsoleDiagnosticConsumer()
    engine.addConsumer(consoleConsumer)
    XCTAssertEqual(engine.consumers.count, 1)

    // Test diagnose handle message
    let message = TypologyDiagnostic.Message(.note, "note message")
    XCTAssertNoThrow(engine.diagnose(message))

    // Test diagnose handle diagnostic
    let location = TypologySourceLocation(line: 1, column: 1, offset: 1, file: filePath)
    let diagnostic = TypologyDiagnostic(
      message: message,
      location: location,
      notes: [],
      highlights: [
        TypologySourceRange(
          start: location,
          end: location
        ),
      ],
      fixIts: []
    )
    XCTAssertNoThrow(engine.diagnose(diagnostic))
  }
}
