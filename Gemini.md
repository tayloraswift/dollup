# Guidelines for Gemini

This project uses SwiftSyntax for code transformation. Adherence to the following guidelines when modifying `.swift` files is mandatory.

# High level architecture

The `dollup` tool consists of a number of “passes” which can run independently and individually, and are invoked by this executable target.
Each pass should be implemented as a library target, and there should be as little code as possible in the `dollup` executable target.

Library targets should be independent of filesystem and argument parsing dependencies, those should be introduced at the level of the executable target only.

Use the `tayloraswift/swift-io` library for file system operations, and use the `apple/swift-argument-parser` library for command line argument parsing.


## Toolchain and environment

Write code that compiles with the latest stable Swift toolchain (Swift 6.1). Do not use obsolete toolchains.

Use the latest stable version of SwiftSyntax, which is SwiftSyntax 601.


## Coding style

Follow the Style Guide located under `/Agent/StyleGuide.md`. This Style Guide is different from the more common “Swift API Design Guidelines”, and takes precedence over those guidelines.


## Strategy for implementing new functionality

Before you begin generating code, first reason about whether the new feature should reside in an independent formatting pass, or whether it should be integrated into an existing pass.


## Strategy for Working with SwiftSyntax

Your primary goal is to perform correct, robust transformations. Avoid trial-and-error. Follow this principled approach:

### 1. Analyze Before Modifying

Before you write any code to fix a bug, your first step **must** be to diagnose the problem by inspecting the Abstract Syntax Tree (AST).
-   Insert a `dump(node)` statement into the relevant `SyntaxRewriter`'s `visit` method to dump the structure of the problematic node.
-   Run the tests and analyze the printed output to pinpoint the exact token that has incorrect trivia or structure.
-   State your diagnosis before proposing a solution.

### 2. Execution Plan

For any given task, your plan should resemble the following:
1.  **Diagnose:** Identify the failing node and `dump` its AST structure.
2.  **Plan:** State your plan to rebuild the node with the correct structure and trivia.
3.  **Execute:** Write the code to perform the rebuilding.
4.  **Verify:** Run the tests to confirm the fix.
