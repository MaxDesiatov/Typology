// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Typology",
  products: [
    // Products define the executables and libraries produced by a package, and make them visible to other packages.
    .library(
      name: "Typology",
      targets: ["Typology"]
    ),
    .executable(name: "typology", targets: ["TypologyCLI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50000.0")),
    .package(url: "https://github.com/jakeheis/SwiftCLI", from: "5.0.0"),
    .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages which this package depends on.
    .target(
      name: "Typology",
      dependencies: ["SwiftSyntax", "Rainbow"]
    ),
    .target(
      name: "TypologyCLI",
      dependencies: ["SwiftCLI", "SwiftSyntax", "Typology"]
    ),
    .testTarget(
      name: "TypologyTests",
      dependencies: ["Typology"]
    ),
  ]
)
