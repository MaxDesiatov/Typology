//
//  DiagnosticEngine.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/10/19.
//

import Foundation
import SwiftSyntax

/// The DiagnosticEngine allows Swift tools to emit diagnostics.
public class TypologyDiagnosticEngine {
  /// Creates a new DiagnosticEngine with no diagnostics.
  public init(fileContent: [String]) {
    self.fileContent = fileContent
  }

  /// The list of consumers of the diagnostic passing through this engine.
  internal var consumers = [TypologyDiagnosticConsumer]()

  /// The file content
  public var fileContent: [String]

  public private(set) var diagnostics = [TypologyDiagnostic]()

  /// Adds the provided consumer to the consumers list.
  public func addConsumer(_ consumer: TypologyDiagnosticConsumer) {
    consumers.append(consumer)

    // Start the consumer with all previous diagnostics.
    for diagnostic in diagnostics {
      consumer.handle(diagnostic, fileContent)
    }
  }

  /// Registers a diagnostic with the diagnostic engine.
  /// - parameters:
  ///   - message: The message for the diagnostic. This message includes
  ///              a severity and text that will be conveyed when the diagnostic
  ///              is serialized.
  public func diagnose(
    _ message: TypologyDiagnostic.Message,
    location: SourceLocation? = nil,
    actions: ((inout TypologyDiagnostic.Builder
    ) -> ())? = nil
  ) {
    let diagnostic = TypologyDiagnostic(
      message: message,
      location: location,
      actions: actions
    )
    diagnostics.append(diagnostic)
    for consumer in consumers {
      consumer.handle(diagnostic, fileContent)
    }
  }

  public func diagnose(_ diagnostic: TypologyDiagnostic) {
    diagnostics.append(diagnostic)
    for consumer in consumers {
      consumer.handle(diagnostic, fileContent)
    }
  }

  /// Tells each consumer to finalize their diagnostic output.
  deinit {
    for consumer in consumers {
      consumer.finalize()
    }
  }
}
