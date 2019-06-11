//
//  Helpers.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/11/19.
//

import Foundation

// Function to generate string of spaces that will be equalent to
// difference between strings length + 1
//
// Example:
// offset(0, 100) will return String with 3 spaces like this: "   "
// offset(50, 100) will return String with 2 spaces like this: "  "
public func offset(_ startIndex: Int, _ endIndex: Int) -> String {
  return String(
    repeating: " ",
    count: "\(endIndex)".count - "\(startIndex)".count + 1
  )
}
