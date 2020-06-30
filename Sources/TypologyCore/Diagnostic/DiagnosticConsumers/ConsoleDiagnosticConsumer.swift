//
//  Console.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/8/19.
//

import Foundation
import Rainbow
import SwiftSyntax

let verticalSeparator = "|".applyingColor(.blue)

/// ConsoleDiagnosticConsumer formats diagnostics and prints them to the
/// console.
public class ConsoleDiagnosticConsumer: TypologyDiagnosticConsumer {
  /// Creates a new ConsoleDiagnosticConsumer.
  public init() {}

  /// Writes the text of the diagnostic to stderr.
  func write<T: CustomStringConvertible>(_ msg: T) {
    FileHandle.standardError.write("\(msg)".data(using: .utf8)!)
  }

  /// Prints the contents of a diagnostic to stderr.
  public func handle(
    _ diagnostic: TypologyDiagnostic,
    _ fileContent: [String]
  ) {
    write(diagnostic, fileContent)
  }

  /// Prints each of the fields in a diagnostic to stderr.
  public func write(_ diagnostic: TypologyDiagnostic, _ fileContent: [String]) {
    if
      let loc = diagnostic.location,
      let file = loc.file,
      let line = loc.line,
      let column = loc.column {
      write("\(file):\(line):\(column): ")
    } else {
      write("<unknown>:0:0: ")
    }
    switch diagnostic.message.severity {
    case .note: write("note: ".applyingColor(.magenta))
    case .warning: write("warning: ".applyingColor(.yellow))
    case .error: write("error: ".applyingColor(.red))
    }

    write(diagnostic.message.text)
    write("\n")

    guard !diagnostic.highlights.isEmpty else { return }

    for highlight in diagnostic.highlights {
      guard let startLine = highlight.start.line, let endLine = highlight.end.line else { continue }

      let maxOffset = String(
        repeating: " ",
        count: "\(endLine)".count + 1
      )

      if highlight.end.line != highlight.start.line {
        // show multiline error
        let errorLines = startLine...endLine

        print(maxOffset, verticalSeparator)

        for line in errorLines {
          let lineOffset = offset(line, endLine)
          let errorString = fileContent[line]

          print("\(String(line).applyingColor(.blue))" +
            "\(lineOffset)\(">".applyingColor(.red))" +
            "\(verticalSeparator) \(errorString)")
        }

        print(maxOffset, verticalSeparator)
      } else {
        // show one line error
        let errorLine = startLine
        let errorOffset = String(repeating: " ", count: errorLine)
        let errorString = fileContent[errorLine]
        let errorUnderscore = String(
          repeating: "^",
          count: endLine - startLine
        )
        .applyingColor(.red)

        print(maxOffset, verticalSeparator)
        print("\(String(errorLine).applyingColor(.blue))" +
          "  \(verticalSeparator) \(errorString)")
        print(maxOffset, verticalSeparator, errorOffset, errorUnderscore)
      }
    }
  }

  public func finalize() {
    // Do nothing
  }
}
