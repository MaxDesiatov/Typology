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
    let diagnosticEngine = DiagnosticEngine()
    let consoleConsumer = ConsoleDiagnosticConsumer()

    diagnosticEngine.addConsumer(consoleConsumer)

    do {
      _ = try File(path: path.value)
    } catch let error as ASTError {
      let diagnose = Diagnostic.Message(.error, "\(error.value)")
      diagnosticEngine.diagnose(diagnose, location: error.range.start)
    } catch {
      let diagnose = Diagnostic.Message(.note, error.localizedDescription)
      diagnosticEngine.diagnose(diagnose)
    }
  }
}

let diagnose = CLI(singleCommand: Diagnose())
diagnose.goAndExit()
