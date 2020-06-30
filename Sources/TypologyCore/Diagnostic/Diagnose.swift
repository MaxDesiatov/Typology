//
//  Diagnose.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/11/19.
//

import Foundation
import SwiftCLI
import SwiftSyntax

public final class Diagnose: Command {
  public init() {}
  public let name = "diagnose"
  let path = Parameter()
  public func execute() throws {
    let consoleConsumer = ConsoleDiagnosticConsumer()
    if isSwiftFile(path.value) {
      try parseFile(path: path.value, consumers: [consoleConsumer])
    } else {
      let resourceKeys: [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
      let baseurl = URL(fileURLWithPath: path.value)
      guard let enumerator = FileManager
        .default
        .enumerator(at: baseurl,
                    includingPropertiesForKeys: resourceKeys,
                    options: [.skipsHiddenFiles],
                    errorHandler: { (url, error) -> Bool in
                      print("Error while reading a list of files" +
                        " in folder at \(url.path): ", error)
                      return true
        })?.compactMap({ $0 as? URL })
        .filter({ isSwiftFile($0.path) })
      else {
        fatalError("Enumerator is nil")
      }

      for fileURL in enumerator {
        try parseFile(path: fileURL.path, consumers: [consoleConsumer])
      }
    }
  }
}

public func parseFile(
  path: String, consumers: [TypologyDiagnosticConsumer]
) throws {
  let contents = try String(contentsOfFile: path)
  let lines = contents.components(separatedBy: .newlines)
  let engine = TypologyDiagnosticEngine(fileContent: lines)
  for consumer in consumers {
    engine.addConsumer(consumer)
  }
  do {
    _ = try File(path: path)
  } catch let error as ASTError {
    let diagnose = Diagnostic.Message(.error, "\(error.value)")

    let diagnostic = TypologyDiagnostic(
      message: diagnose,
      location: error.range.start,
      notes: [],
      highlights: [
        SourceRange(
          start: error.range.start,
          end: error.range.end
        ),
      ],
      fixIts: []
    )

    engine.diagnose(diagnostic)
  } catch {
    let diagnose = Diagnostic.Message(.note, error.localizedDescription)
    engine.diagnose(diagnose)
  }
}

public func isSwiftFile(_ path: String) -> Bool {
  return path.contains(".swift")
}
