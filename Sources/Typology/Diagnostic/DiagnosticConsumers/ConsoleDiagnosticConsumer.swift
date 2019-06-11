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

private func offset(_ startIndex: Int, _ endIndex: Int) -> String {
    return String(repeating: " ", count: "\(endIndex)".count - "\(startIndex)".count + 1)
}

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
  public func handle(_ diagnostic: TypologyDiagnostic, _ fileContent: [String]) {
    write(diagnostic, fileContent)
    // FIXIT implement Note.asDiagnostic
    // for note in diagnostic.notes {
    //   write(note.asDiagnostic())
    // }
  }

  /// Prints each of the fields in a diagnositic to stderr.
  public func write(_ diagnostic: TypologyDiagnostic, _ fileContent: [String]) {
    if let loc = diagnostic.location {
      write("\(loc.file):\(loc.line):\(loc.column): ")
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

    if !diagnostic.highlights.isEmpty {
      for highlight in diagnostic.highlights {
        let maxOffset = String(repeating: " ", count: "\(highlight.end.line)".count + 1)

        if highlight.end.line != highlight.start.line {
          // show multiline error
          let errorLines = highlight.start.line...highlight.end.line

          print(maxOffset, verticalSeparator)

          for line in errorLines {
            let lineOffset = offset(line, highlight.end.line)
            let errorString = fileContent[line]

            print("\(String(line).applyingColor(.blue))\(lineOffset)\(">".applyingColor(.red))\(verticalSeparator) \(errorString)")
          }

          print(maxOffset, verticalSeparator)
        } else {
          // show one line error
          let errorLine = highlight.start.line
          let errorOffset = String(repeating: " ", count: highlight.start.line)
          let errorString = fileContent[errorLine]
          let errorUnderscore = String(repeating: "^", count: highlight.end.line - highlight.start.line)
            .applyingColor(.red)

          print(maxOffset, verticalSeparator)
          print("\(String(errorLine).applyingColor(.blue))  \(verticalSeparator) \(errorString)")
          print(maxOffset, verticalSeparator, errorOffset, errorUnderscore)
        }
      }
    }
  }

  public func finalize() {
    // Do nothing
  }
}
