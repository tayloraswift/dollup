# Tips for Gemini

This project uses SwiftSyntax for code transformation. Adherence to the following strategies when modifying `.swift` files is mandatory.

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
