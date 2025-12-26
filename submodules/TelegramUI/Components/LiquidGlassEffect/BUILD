load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "LiquidGlassEffect",
    module_name = "LiquidGlassEffect",
    srcs = glob([
        "Sources/**/*.swift",
    ]),
    copts = [
        "-warnings-as-errors",
    ],
    deps = [
        "//submodules/AsyncDisplayKit",
        "//submodules/Display",
        "//submodules/UIKitRuntimeUtils",
    ],
    visibility = [
        "//visibility:public",
    ],
)
