//
//  Helpers.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/11/19.
//

import Foundation

// Generate offset betwenn two integers like if they was strings
// Goal is to make line nubmer in diagnose report look good
public func offset(_ startIndex: Int, _ endIndex: Int) -> String {
  return String(
    repeating: " ",
    count: "\(endIndex)".count - "\(startIndex)".count + 1
  )
}
