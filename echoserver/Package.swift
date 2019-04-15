// swift-tools-version:4.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "echoserver",
    products: [
      .executable(name: "echoserver",
                  targets: [
                    "Service",
                    "EchoService",
                    "Server",
		  ]
      ),
      .library(name: "Service", targets: ["Service"]),
      .library(name: "EchoService", targets: ["EchoService", "Service"]),
    ],
    dependencies: [
        .package(url: "https://github.com/amzn/smoke-framework.git", .branch("master")),
	.package(url: "https://github.com/AlwaysRightInstitute/Shell.git", from: "0.1.4"),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "Server",
            dependencies: ["Service", "EchoService", "HeliumLogger", "Shell"]),
        .target(
            name: "EchoService",
            dependencies: ["Service", "SmokeOperations", "SmokeHTTP1", "SmokeOperationsHTTP1"]),
        .target(
            name: "Service",
            dependencies: ["SmokeOperations", "SmokeHTTP1", "SmokeOperationsHTTP1"]),
        .testTarget(
            name: "ServerTests",
            dependencies: ["Server"]),
    ]
)
