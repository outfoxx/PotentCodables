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
  dependencies: [
    .package(url: "https://github.com/nicklockwood/SwiftFormat.git", .upToNextMinor(from: "0.40.10"))
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
