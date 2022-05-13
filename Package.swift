// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIAppKit",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "SwiftUIAppKit",
            targets: ["SwiftUIAppKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/Alamofire/AlamofireImage", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/bhimsenp/SwiftUINavigation.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "SwiftUIAppKit",
            dependencies: ["Alamofire", "AlamofireImage", "SwiftUINavigation"])
    ]
)
