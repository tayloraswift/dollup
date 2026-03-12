[![ci build status](https://github.com/tayloraswift/dollup/actions/workflows/Tests.yml/badge.svg)](https://github.com/tayloraswift/dollup/actions/workflows/Tests.yml/badge.svg)
[![ci build status](https://github.com/tayloraswift/dollup/actions/workflows/Deploy.yml/badge.svg)](https://github.com/tayloraswift/dollup/actions/workflows/Deploy.yml/badge.svg)

# dollup 🎀

Dollup is a tool for formatting Swift source code. It automatically adjusts indentation, wraps lines to a specified maximum width, and enforces a consistent brace style, helping to maintain a readable code style.

## Using Prebuilt Binaries

Dollup is easiest to use in precompiled form. The binaries are distributed from a parallel repo, [`ordo-one/dollup`](https://github.com/ordo-one/dollup).

```swift
dependencies: [
    .package(url: "https://github.com/ordo-one/dollup", from: "1.0.0"),
]
```

Adding the binary package dependency will automatically make the plugin available.

```bash
swift package dollup --allow-writing-to-package-directory
```

Some people find it helpful to add formatting enforcement to their CI pipelines.

```yaml
-   name: 🎀 Format 🎀
    run: |
        swift package dollup --allow-writing-to-package-directory
        git diff --exit-code
```

Note that prebuilt binaries are only available for select platforms.

| Platform | Architecture | Download |
| -------- | ------------ | -------- |
| 🍏 macOS | arm64 | [zip](https://download.rarestype.com/dollup/master/macOS-arm64/dollup.artifactbundle.zip) |
| 🐧 Linux | arm64 | [zip](https://download.rarestype.com/dollup/master/Linux-aarch64/dollup.artifactbundle.zip) |
| 🐧 Linux | x86_64 | [zip](https://download.rarestype.com/dollup/master/Linux-x86_64/dollup.artifactbundle.zip) |


## Building from Source

To build the `dollup` executable, you will need the Swift 6.2 (or newer) toolchain. Navigate to the project's root directory and run the following command:

```bash
swift build
```

The compiled executable will be located in the `.build/debug` directory.

## Usage

To format a Swift file or all Swift files within a directory, run the `dollup` executable with the path to the file or directory as an argument:

```bash
swift run dollup [file-path]
```

This will reformat the specified file in place.

When a directory is provided, `dollup` will recursively format all `.swift` files within it.

## Configuration

Dollup is configured by creating a Swift executable that conforms to the `DollupConfiguration` protocol. This allows you to specify formatting options in a declarative way.

Here's an example of a simple configuration file:

```swift
import DollupConfig
import SystemPackage

@main enum Main: DollupConfiguration {
    public static func configure(file _: FilePath?, settings: inout DollupSettings) {
        settings.check = true
        settings.whitespace {
            $0.width = 96
            $0.braces = .egyptian

            $0.indent.spaces = 4
            $0.indent.ifConfig = false

            $0.formatColonPadding = true
            $0.keywordsOnSameLine = true
        }
    }

    public static func filter(file: FilePath) -> Bool {
        true // run on all files
    }
    public static func report(file: FilePath) {
        print("> reformatted '\(file)'")
    }
}
```

This configuration specifies that the code should be formatted with a maximum line width of 96 characters, Egyptian-style braces, and an indent width of 4 spaces. It also enables the integrity check, which ensures that the reformatted code is semantically equivalent to the original.

## How it Works

The `dollup` tool is built using **SwiftSyntax** to parse and transform Swift source code. It operates in several passes:

1.  **Line Expansion**: The tool first ensures that code blocks with interior newlines are properly expanded, adding line breaks where necessary to enforce a consistent vertical layout.
2.  **Re-indentation**: It then analyzes the code's structure to calculate the correct indentation level for each line, taking into account nested blocks, function calls, and other language constructs.
3.  **Line Wrapping**: Finally, it iteratively wraps lines that exceed the specified maximum width, breaking long lines at appropriate points, such as after commas in argument lists or before operators in expressions.

The tool is designed to be robust and preserves the semantic meaning of the code throughout the formatting process. An integrity check is performed by default to verify that no unintended changes have been introduced.
