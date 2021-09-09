// swift-tools-version:4.2
import PackageDescription

let package = Package(name: "Add_Test_Targets")

package.products = [
    .executable(name: "add_test_targets", targets: ["Add_Test_Targets"])
]
package.dependencies = [
    .package(url: "https://github.com/tuist/XcodeProj.git", .upToNextMajor(from: "8.0.0"))
]
package.targets = [
    .target(name: "Add_Test_Targets", dependencies: [.product(name: "XcodeProj", package: "XcodeProj")], path: "Sources")
]
