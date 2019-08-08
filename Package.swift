// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "PotentCodables",
  platforms: [
    .iOS(.v10),
    .macOS(.v10_12),
    .watchOS(.v3),
    .tvOS(.v10),
  ],
  products: [
    .library(
      name: "PotentCodables",
      targets: ["PotentCodables", "PotentJSON", "PotentCBOR", "PotentASN1"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/attaswift/BigInt.git", from: "4.0.0"),
    .package(url: "https://github.com/lukaskubanek/OrderedDictionary.git", from: "2.2.2"),
    .package(url: "https://github.com/nicklockwood/SwiftFormat.git", .upToNextMinor(from: "0.40.10"))
  ],
  targets: [
    .target(
      name: "PotentCodables"
    ),
    .target(
      name: "PotentJSON",
      dependencies: ["PotentCodables"]
    ),
    .target(
      name: "PotentCBOR",
      dependencies: ["PotentCodables"]
    ),
    .target(
      name: "PotentASN1",
      dependencies: ["PotentCodables", "BigInt", "OrderedDictionary"]
    ),
    .testTarget(
      name: "PotentCodablesTests",
      dependencies: ["PotentCodables", "PotentJSON", "PotentCBOR", "PotentASN1"],
      path: "./Tests"
    )
  ]
)
