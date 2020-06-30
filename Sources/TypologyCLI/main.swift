//
//  TypologyCLI.swift
//  Typology
//
//  Created by Matvii Hodovaniuk on 6/8/19.
//

import Foundation
import SwiftCLI
import TypologyCore

let diagnose = CLI(singleCommand: Diagnose())
diagnose.goAndExit()
