[![ci build status](https://github.com/tayloraswift/dollup/actions/workflows/Tests.yml/badge.svg)](https://github.com/tayloraswift/dollup/actions/workflows/Tests.yml/badge.svg)
[![ci build status](https://github.com/tayloraswift/dollup/actions/workflows/Deploy.yml/badge.svg)](https://github.com/tayloraswift/dollup/actions/workflows/Deploy.yml/badge.svg)

# dollup 🎀

Dollup is a command-line tool for formatting Swift source code. It automatically adjusts indentation and wraps lines to a specified maximum width, helping to maintain a consistent and readable code style.


## Using Prebuilt Binaries

Dollup supports Linux and macOS. We provide prebuilt binaries for several platforms.

| Platform | Architecture | Download |
| -------- | ------------ | -------- |
| macOS 15 | arm64 | [tar.gz](https://download.swiftinit.org/dollup/0.1.0/macOS-ARM64/dollup.tar.gz) |
| Ubuntu 24.04 | arm64 | [tar.gz](https://download.swiftinit.org/dollup/0.1.0/Ubuntu-24.04-ARM64/dollup.tar.gz) |
| Ubuntu 24.04 | x86_64 | [tar.gz](https://download.swiftinit.org/dollup/0.1.0/Ubuntu-24.04-X64/dollup.tar.gz) |
| Ubuntu 22.04 | arm64 | [tar.gz](https://download.swiftinit.org/dollup/0.1.0/Ubuntu-22.04-ARM64/dollup.tar.gz) |
| Ubuntu 22.04 | x86_64 | [tar.gz](https://download.swiftinit.org/dollup/0.1.0/Ubuntu-22.04-X64/dollup.tar.gz) |


Download the correct binary for your platform from the table above, extract it, and add the `dollup` binary to your `PATH`. The pre-built Linux binaries do not require the Swift runtime to be installed on the system.


## Building from Source

To build the `dollup` executable, you will need the Swift 6.1 toolchain. Navigate to the project's root directory and run the following command:

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


## Options

You can customize the formatting behavior with the following options:

  * `-I, --indent <value>`: Sets the number of spaces to use for each indentation level. The default value is **4**.
  * `-L, --line-length <value>`: Specifies the maximum line length. The formatter will wrap lines that exceed this limit. The default value is **96**.
  * `-y, --disable-integrity-check`: Disables the integrity check that ensures the reformatted code is semantically equivalent to the original. This is not recommended for general use.
  * `-g, --ignore <pattern>`: A list of file patterns to ignore when formatting a directory (e.g., `generated` to ignore all `*.generated.swift` files). This option can be repeated.


## How it Works

The `dollup` tool is built using **SwiftSyntax** to parse and transform Swift source code. It operates in several passes:

1.  **Line Expansion**: The tool first ensures that code blocks with interior newlines are properly expanded, adding line breaks where necessary to enforce a consistent vertical layout.
2.  **Re-indentation**: It then analyzes the code's structure to calculate the correct indentation level for each line, taking into account nested blocks, function calls, and other language constructs.
3.  **Line Wrapping**: Finally, it iteratively wraps lines that exceed the specified maximum width, breaking long lines at appropriate points, such as after commas in argument lists or before operators in expressions.

The tool is designed to be robust and preserves the semantic meaning of the code throughout the formatting process. An integrity check is performed by default to verify that no unintended changes have been introduced.
