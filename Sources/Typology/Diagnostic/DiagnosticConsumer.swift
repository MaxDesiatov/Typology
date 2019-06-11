//
//  DiagnosticConsumer.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/10/19.
//

/// An object that intends to receive notifications when diagnostics are
/// emitted.
public protocol TypologyDiagnosticConsumer {
  /// Handle the provided diagnostic which has just been registered with the
  /// DiagnosticEngine.
  func handle(_ diagnostic: TypologyDiagnostic, _ fileContent: [String])

  /// Finalize the consumption of diagnostics, flushing to disk if necessary.
  func finalize()
}
