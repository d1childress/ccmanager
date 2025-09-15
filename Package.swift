// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ccmanager",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "ccmanager",
            targets: ["ccmanager"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", from: "0.1.5"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        .package(url: "https://github.com/apple/swift-charts", from: "1.0.0")
    ],
    targets: [
        .executableTarget(
            name: "ccmanager",
            dependencies: [
                "SwiftUIX",
                "SwiftyJSON",
                "Alamofire",
                .product(name: "Charts", package: "swift-charts")
            ],
            path: "ccmanager"
        )
    ]
)