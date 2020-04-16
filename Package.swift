// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SemanticVersion",
  products: [.library(name: "SemanticVersion", type: .dynamic, targets: ["SemanticVersion"])],
  dependencies: [],
  targets: [
    .target(name: "SemanticVersion", dependencies: [], path:".", sources:["Sources"]),
    .testTarget(name: "SemanticVersionTests", dependencies: ["SemanticVersion"])
  ]
)
