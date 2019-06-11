//
//  Diagnostic.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/10/19.
//

import Foundation
import SwiftSyntax

/// A Note attached to a Diagnostic. This provides more context for a specific
/// error, and optionally allows for FixIts.
public struct Note: Codable {
  /// The note's message.
  public let message: TypologyDiagnostic.Message

  /// The source location where the note should point.
  public let location: SourceLocation?

  /// An array of source ranges that should be highlighted.
  public let highlights: [SourceRange]

  /// An array of FixIts that apply to this note.
  public let fixIts: [FixIt]

  /// Constructs a new Note from the constituent parts.
  internal init(
    message: TypologyDiagnostic.Message,
    location: SourceLocation?,
    highlights: [SourceRange],
    fixIts: [FixIt]
  ) {
    precondition(message.severity == .note,
                 "notes can only have the `note` severity")
    self.message = message
    self.location = location
    self.highlights = highlights
    self.fixIts = fixIts
  }
}

/// A TypologyDiagnostic message that can be emitted regarding some piece of code.
public struct TypologyDiagnostic: Codable {
  public struct Message: Codable {
    /// The severity of TypologyDiagnostic. This can be note, error, or warning.
    public let severity: Severity

    /// A string containing the contents of the TypologyDiagnostic.
    public let text: String

    /// Creates a diagnostic message with the provided severity and text.
    public init(_ severity: Severity, _ text: String) {
      self.severity = severity
      self.text = text
    }
  }

  // These values must match clang/Frontend/SerializedDiagnostics.h
  /// The severity of the diagnostic.
  public enum Severity: UInt8, Codable {
    case note = 1
    case warning = 2
    case error = 3
  }

  /// The diagnostic's message.
  public let message: Message

  /// The location the diagnostic should point.
  public let location: SourceLocation?

  /// An array of notes providing more context for this diagnostic.
  public let notes: [Note]

  /// An array of source ranges to highlight.
  public let highlights: [SourceRange]

  /// An array of possible FixIts to apply to this diagnostic.
  public let fixIts: [FixIt]

  /// Creates a new Diagnostic with the provided message, pointing to the
  /// provided location (if any).
  /// This initializer also takes a closure that will be passed a Diagnostic
  /// Builder as an inout parameter. Use this closure to add notes, highlights,
  /// and FixIts to the diagnostic through the Builder's API.
  /// - parameters:
  ///   - message: The diagnostic's message.
  ///   - location: The location the diagnostic is attached to.
  ///   - actions: A closure that's used to attach notes and highlights to
  ///              diagnostics.
  init(message: Message, location: SourceLocation?) {
    self.init(
      message: message,
      location: location,
      notes: [],
      highlights: [],
      fixIts: []
    )
  }

  /// Creates a new Diagnostic with the provided message, pointing to the
  /// provided location (if any).
  /// - parameters:
  ///   - message: The diagnostic's message.
  ///   - location: The location the diagnostic is attached to.
  ///   - highlights: An array of SourceRanges which will be highlighted when
  ///                 the diagnostic is presented.
  public init(
    message: Message,
    location: SourceLocation?,
    notes: [Note],
    highlights: [SourceRange],
    fixIts: [FixIt]
  ) {
    self.message = message
    self.location = location
    self.notes = notes
    self.highlights = highlights
    self.fixIts = fixIts
  }
}
