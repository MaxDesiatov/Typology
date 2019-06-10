//
//  TypologyCLI.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/8/19.
//

// Read the contents of the specified file
//    let contents = try String(contentsOfFile: path.value)
//     Split the file into separate lines
//    let lines = contents.split(separator: "\n")

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
    if isSwiftFile(path.value) {
      let diagnosticEngine = TypologyDiagnosticEngine()
      let consoleConsumer = ConsoleDiagnosticConsumer()
      diagnosticEngine.addConsumer(consoleConsumer)
      do {
        _ = try File(path: path.value)
      } catch let error as ASTError {
        let diagnose = TypologyDiagnostic.Message(.error, "\(error.value)")
        let postition = TypologyAbsolutePosition(line: error.range.start.line, column: error.range.start.column, utf8Offset: error.range.start.offset)
        let location = TypologySourceLocation(file: error.range.start.file, position: postition)
        diagnosticEngine.diagnose(diagnose, location: location)
      } catch {
        let diagnose = TypologyDiagnostic.Message(.note, error.localizedDescription)
        diagnosticEngine.diagnose(diagnose)
      }
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
        })?.compactMap({ $0 as? URL }).filter({ isSwiftFile($0.path) })
      else {
        fatalError("Enumerator is nil")
      }
      let enumerated = enumerator.enumerated()

      for (_, fileURL) in enumerated {
        let diagnosticEngine = TypologyDiagnosticEngine()
        let consoleConsumer = ConsoleDiagnosticConsumer()
        diagnosticEngine.addConsumer(consoleConsumer)
        do {
          print(fileURL.path)
          _ = try File(path: fileURL.path)
        } catch let error as ASTError {
          let diagnose = TypologyDiagnostic.Message(.error, "\(error.value)")

          diagnosticEngine.diagnose(diagnose, location: TypologySourceLocation(from: error.range.start))
        } catch {
          let diagnose = TypologyDiagnostic.Message(.note, error.localizedDescription)
          diagnosticEngine.diagnose(diagnose)
        }
      }
    }
  }
}

private func isSwiftFile(_ path: String) -> Bool {
  return path.contains(".swift")
}

let diagnose = CLI(singleCommand: Diagnose())
diagnose.goAndExit()
