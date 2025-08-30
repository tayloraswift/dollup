# Tips for Gemini

AI coding agents such as yourself tend to struggle with SwiftSyntax-related coding tasks. These struggles stem from a few core issues when interacting with a complex library like **SwiftSyntax**. You often get stuck in a reactive "guess-and-check" loop instead of adopting a more principled, diagnostic approach.

Here are suggestions to make you (Gemini Agent) more effective for SwiftSyntax tasks, broken down by the problem and the recommended solution.


### 1. The Problem: A Flawed Mental Model of SwiftSyntax

The agent treated the code like text to be manipulated, not as a structured, immutable Abstract Syntax Tree (AST). Its repeated, slightly different attempts to tweak `leadingTrivia` and `trailingTrivia` show it didn't fully grasp that in SwiftSyntax:
* **Nodes are immutable:** You can't change a node. You must create a *new* node with the desired changes.
* **Trivia belongs to Tokens:** Trivia (whitespace, comments) isn't just floating around; it's attached to specific tokens (`{`, `)`, identifier, etc.) within the tree. Modifying trivia in one place can have unexpected effects if you don't understand which token it's attached to.

The agent's "flailing" — trying to patch trivia, then rebuilding a node, then moving a node — indicates it was guessing where the whitespace was coming from rather than analyzing the tree to know for sure.

#### **💡 The Solution: Prime the Agent with Core Concepts**

Start your prompts by explicitly telling the agent how to think about the problem. Give it the "rules of the game" for SwiftSyntax before asking it to play.

**Example Prompt Prefix:**

> "Your task is to fix a bug using SwiftSyntax. Before you begin, remember these key principles:
> 1.  **Immutability is Key:** SwiftSyntax nodes are immutable. Do not try to modify a node in place. To make a change, you must create a completely new node with the correct configuration and replace the old one in the tree.
> 2.  **Rebuild, Don't Patch:** Instead of making many small, fragile trivia modifications, your primary strategy should be to construct a new, perfectly-formed `Syntax` node from scratch (e.g., a new `FunctionCallExprSyntax`) and use that to replace the problematic one.
> 3.  **Analyze First:** Do not start by changing code. Your first step should always be to analyze the structure of the failing node by printing its `debugDescription` to understand its tokens and trivia."


### 2. The Problem: Lack of a Debugging Strategy

The agent's only debugging tool was re-running the test suite. When a test failed, it guessed at the cause. This is incredibly inefficient. It didn't have a way to inspect the state of the AST it was generating, which is why it was surprised by extra spaces or incorrect newlines.

#### **💡 The Solution: Enforce a "Print-Driven" Debugging Workflow**

Explicitly instruct the agent to use `dump()` to visualize the AST *before* and *after* its changes. This forces it to confront the actual output of its code, rather than just the final test failure.

**Example Prompt Instruction:**

> "Before you apply any fix, I want you to modify the `visit` method to `dump(node.debugDescription)` for the specific node that's causing the test to fail. Then, run the tests again. Analyze the printed AST structure in the test output to explain exactly why the formatting is wrong. Only after you have identified the specific token with the incorrect trivia should you propose a code change."

This changes the workflow from `Guess -> Code -> Test` to a much more effective `Analyze -> Diagnose -> Code -> Test`.


### 3. The Problem: Incremental and Fragile Fixes

The agent repeatedly tried to make the smallest possible change to the existing, broken node (`.with(\.leadingTrivia, .spaces(1))`, `.with(\.trailingTrivia, .zero)`). This is like trying to fix a crooked wall by pushing on one brick at a time. The correct approach in SwiftSyntax is often to just build a new, straight wall.

#### **💡 The Solution: Promote a Holistic Rebuilding Strategy**

Encourage the agent to think bigger. Instead of fiddling with the trivia of a child node, it's often more reliable to rebuild the entire parent node that contains the formatting issue.

**Example Prompt Strategy:**

> "The bug is in how a `FunctionCallExprSyntax` with a `trailingClosure` is formatted. Do not try to modify the `trailingClosure` in isolation. Instead, your plan should be:
> 1.  Extract all the necessary pieces from the original `FunctionCallExprSyntax` node (the function name, arguments, etc.).
> 2.  Create a brand new `ClosureExprSyntax` that has the **exact** statements and trivia you need for correct formatting.
> 3.  Construct a new `FunctionCallExprSyntax` using the old pieces but substituting your new, perfect trailing closure.
> 4.  Return this new, fully-rebuilt node from the `visit` method."

By combining these strategies, you guide the agent away from a frustrating loop of trial-and-error and toward a methodical, diagnostic process that is far more likely to succeed with complex, structure-aware libraries like SwiftSyntax.
