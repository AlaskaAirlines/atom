// swift-tools-version:5.0
//
//  Package.swift
//  Atom
//
//  Created by Michael Babiy on 6/5/19.
//  Copyright © 2018 Alaska Airlines, Inc. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "Atom",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_12)
    ],
    products: [
        .library(
            name: "Atom",
            targets: ["Atom"])
    ],
    targets: [
        .target(
            name: "Atom",
            path: "Framework/Atom")
    ],
    swiftLanguageVersions: [.v5]
)
