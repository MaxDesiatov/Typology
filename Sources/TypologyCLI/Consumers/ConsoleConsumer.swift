//
//  Console.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/8/19.
//

import SwiftSyntax

struct ConsoleConsumer: DiagnosticConsumer {
  func handle(_ diagnostic: Diagnostic) {
    print(diagnostic.message.text)
  }

  func finalize() {}
}
