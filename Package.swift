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
      targets: ["PotentCodables"]
    ),
  ],
  targets: [
    .target(
      name: "PotentCodables",
      path: "./Sources"
    ),
    .testTarget(
      name: "PotentCodablesTests",
      dependencies: ["PotentCodables"],
      path: "./Tests"
    )
  ]
)
