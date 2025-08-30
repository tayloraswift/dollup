# High level architecture

This tool should consist of a number of “passes” which can run independently and individually, and are invoked by this executable target.
Each pass should be implemented as a library target, and there should be as little code in this executable target as possible.

Library targets should be independent of filesystem and argument parsing dependencies, those should be introduced at the level of the executable target only.

Use the tayloraswift/swift-io library for file system operations, and use the apple/swift-argument-parser library for command line argument parsing.
