//
//  TypologyCLI.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/8/19.
//

//          let diagnostic = TypologyDiagnostic(
//            message: diagnose,
//            location: error.range.start as? TypologySourceLocation,
//            notes: [Note](),
//            highlights: [TypologySourceRange](),
//            fixIts: [FixIt]()
//          )

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
      let lines = contents.split(separator: "\n")
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
      let count = enumerator.count
      let enumerated = enumerator.enumerated()

      for (i, fileURL) in enumerated {
        let contents = try String(contentsOfFile: fileURL.path)
        let lines = contents.split(separator: "\n")
        diagnosticEngine.fileContent = lines

        let diagnose = TypologyDiagnostic.Message(.note, "Diagnosing \(fileURL.lastPathComponent) (\(i + 1)/\(count))")
        diagnosticEngine.diagnose(diagnose)
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
    engine.diagnose(diagnose, location: TypologySourceLocation(from: error.range.start))
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
