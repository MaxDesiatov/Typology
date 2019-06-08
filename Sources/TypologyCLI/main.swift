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
    let diagnositcEngine = DiagnosticEngine()
    let consoleConsumer = ConsoleConsumer()
    let diagnose = Diagnostic.Message(.note, "Diagnose note")

    diagnositcEngine.addConsumer(consoleConsumer)

    diagnositcEngine.diagnose(diagnose)
  }
}

let diagnose = CLI(singleCommand: Diagnose())
diagnose.goAndExit()
