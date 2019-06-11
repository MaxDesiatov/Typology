//
//  TypologyCLI.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/8/19.
//

import Foundation
import SwiftCLI
import SwiftSyntax
import Typology

class Diagnose: Command {
  let name = "diagnose"
  let path = Parameter()
  func execute() throws {
    let diagnosticEngine = TypologyDiagnosticEngine()
    let consoleConsumer = ConsoleDiagnosticConsumer()
    diagnosticEngine.addConsumer(consoleConsumer)

    if isSwiftFile(path.value) {
      let contents = try String(contentsOfFile: path.value)
      let lines = contents.components(separatedBy: .newlines)

      diagnosticEngine.fileContent = lines
      parseFile(path: path.value, engine: diagnosticEngine)
    } else {
      let resourceKeys: [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
      let baseurl = URL(fileURLWithPath: path.value)
      guard let enumerator = FileManager
        .default
        .enumerator(at: baseurl,
                    includingPropertiesForKeys: resourceKeys,
                    options: [.skipsHiddenFiles],
                    errorHandler: { (url, error) -> Bool in
                      print("Error while reading a list of files in folder at \(url.path): ", error)
                      return true
        })?.compactMap({ $0 as? URL })
        .filter({ isSwiftFile($0.path) })
      else {
        fatalError("Enumerator is nil")
      }
      let enumerated = enumerator.enumerated()

      for (_, fileURL) in enumerated {
        let contents = try String(contentsOfFile: fileURL.path)
        let lines = contents.components(separatedBy: .newlines)
        diagnosticEngine.fileContent = lines

        parseFile(path: fileURL.path, engine: diagnosticEngine)
      }
    }
  }
}

private func parseFile(path: String, engine: TypologyDiagnosticEngine) {
  do {
    _ = try File(path: path)
  } catch let error as ASTError {
    let diagnose = TypologyDiagnostic.Message(.error, "\(error.value)")

    let diagnostic = TypologyDiagnostic(
      message: diagnose,
      location: TypologySourceLocation(from: error.range.start),
      notes: [],
      highlights: [TypologySourceRange(start: TypologySourceLocation(from: error.range.start), end: TypologySourceLocation(from: error.range.end))],
      fixIts: []
    )

    engine.diagnose(diagnostic)
  } catch {
    let diagnose = TypologyDiagnostic.Message(.note, error.localizedDescription)
    engine.diagnose(diagnose)
  }
}

private func isSwiftFile(_ path: String) -> Bool {
  return path.contains(".swift")
}

let diagnose = CLI(singleCommand: Diagnose())
diagnose.goAndExit()
