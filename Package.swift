// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift_casting",
  targets: [
    .target(name: "Struct punning"),
    .target(name: "Layout by hand")
  ]
)
