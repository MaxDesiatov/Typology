//
//  TypologyCLI.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/8/19.
//

import Foundation
import SwiftCLI
import SwiftSyntax

class Diagnose: Command {
  let name = "diagnose"
  func execute() throws {
    let diagnosticEngine = DiagnosticEngine()
    let consoleConsumer = ConsoleConsumer()
    let diagnose = Diagnostic.Message(.note, "Diagnose note")

    diagnosticEngine.addConsumer(consoleConsumer)

    diagnosticEngine.diagnose(diagnose)
  }
}

let diagnose = CLI(singleCommand: Diagnose())
diagnose.goAndExit()
