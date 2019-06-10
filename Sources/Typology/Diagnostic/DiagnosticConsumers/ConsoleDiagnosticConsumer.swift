//
//  Console.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/8/19.
//

import Foundation
import Rainbow
import SwiftSyntax

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
  public func handle(_ diagnostic: TypologyDiagnostic, _ fileContent: [Substring]) {
    write(diagnostic, fileContent)
    // FIXIT implement Note.asDiagnostic
    // for note in diagnostic.notes {
    //   write(note.asDiagnostic())
    // }
  }

  /// Prints each of the fields in a diagnositic to stderr.
  public func write(_ diagnostic: TypologyDiagnostic, _ fileContent: [Substring]) {
    var errorString = ""
    var errorLine = 0
    var errorColumn = 0
    if let loc = diagnostic.location {
      write("\(loc.file):\(loc.line):\(loc.column): ")
      errorString = String(fileContent[loc.line])
      errorLine = loc.line
      errorColumn = loc.column
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

    if !errorString.isEmpty {
      let offset = String(repeating: " ", count: "\(errorLine)".count)
      let errorOffset = String(repeating: " ", count: errorColumn - 1)
      let verticalSeparator = " | ".applyingColor(.blue)
      print(offset, verticalSeparator)
      print("\(errorLine)".applyingColor(.blue), verticalSeparator, "\(errorString)")
      print(offset, verticalSeparator, "\(errorOffset)^^^")
    }
  }

  public func finalize() {
    // Do nothing
  }
}
