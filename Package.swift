// swift-tools-version: 5.10.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Grape",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16)
    ],
    products: [
        .library(name: "Grape", targets: [
            "Grape"
        ]),
        .library(name: "GrapeCXX", targets: [
            "GrapeCXX"
        ]),
        .library(name: "GrapeObjC", targets: [
            "GrapeObjC"
        ])
    ],
    targets: [
        .target(name: "Grape", dependencies: [
            "GrapeObjC"
        ]),
        .target(name: "GrapeCXX", sources: [
            "", "common"
        ], publicHeadersPath: "include"),
        .target(name: "GrapeObjC", dependencies: [
            "GrapeCXX"
        ], publicHeadersPath: "include")
    ],
    cLanguageStandard: .c2x,
    cxxLanguageStandard: .cxx2b
)
