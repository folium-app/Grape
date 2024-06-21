// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Grape",
    products: [
        .library(name: "Grape", targets: ["Grape"]),
        .library(name: "GrapeCXX", targets: ["GrapeCXX"]),
        .library(name: "GrapeObjC", targets: ["GrapeObjC"])
    ],
    dependencies: [
        .package(url: "https://github.com/jarrodnorwell/HQx", branch: "main"),
        .package(url: "https://github.com/jarrodnorwell/xBRZ", branch: "main")
    ],
    targets: [
        .target(name: "Grape", dependencies: ["GrapeObjC"]),
        .target(name: "GrapeCXX", sources: [""], publicHeadersPath: "include", cxxSettings: [
            .unsafeFlags([
                "-Wno-conversion"
            ])
        ], swiftSettings: [
            .interoperabilityMode(.Cxx)
        ]),
        .target(name: "GrapeObjC", dependencies: ["GrapeCXX", "HQx", "xBRZ"], publicHeadersPath: "include", cxxSettings: [
            .unsafeFlags([
                "-Wno-conversion"
            ])
        ], swiftSettings: [
            .interoperabilityMode(.Cxx)
        ])
    ],
    cLanguageStandard: .c2x,
    cxxLanguageStandard: .cxx2b
)
