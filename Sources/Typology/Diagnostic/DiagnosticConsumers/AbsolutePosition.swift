//
//  AbsolutePosition.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/10/19.
//

/// An absolute position in a source file as text - the absolute utf8Offset from
/// the start, line, and column.
public struct TypologyAbsolutePosition {
  public let utf8Offset: Int
  public let line: Int
  public let column: Int

  static let startOfFile = TypologyAbsolutePosition(line: 1, column: 1, utf8Offset: 0)

  public init(line: Int, column: Int, utf8Offset: Int) {
    self.line = line
    self.column = column
    self.utf8Offset = utf8Offset
  }
}
