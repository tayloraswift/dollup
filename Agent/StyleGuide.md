# Swift Style Guidance, for Google Gemini

This document outlines the key coding conventions that you (Google Gemini) should follow when generating Swift code. Only deviate from them if explicitly instructed to.

Make sure to follow *all* guidelines, but pay extra attention to **explicit `self`**, **explicit type annotations**, and mandatory inclusion of **`init` tokens** in initializer calls, as the majority of training data for Swift code omits these critical details.


## Visual formatting

### Line length

Adhere to a maximum line length of 96 characters (grapheme clusters). Use multiline string literals to avoid overlong strings.

### Spacing around operators

Include spaces around range operators and other binary operators.

```swift
// ✓ CORRECT
for i: Int in 0 ..< count {
    let result: Double = a * b + c / d
}

// ✗ INCORRECT
for i in 0..<count {
    let result: Double = a*b+c/d
}
```

### Comments

AI agents like yourself often use code comments to explain steps you took. These comments don’t make sense out of the context of a particular chat. Don’t use code comments to explain edits you make, use the chat for that instead. Code you generate should be understandable outside of the context of a particular Copilot conversation.


✓ CORRECT:

```md
Here, I have changed the formula I used to compute `x`!
```
```swift
let x: Double = y + z
```


✗ INCORRECT:

```swift
// Here, I have changed the formula I used to compute x!
let x: Double = y + z
```

## Literals

Use integer literals for integral floating point values.

```swift
// ✓ CORRECT
let x: Double = 1

// ✗ INCORRECT
let x: Double = 1.0
```

## Variables, static typing, and pattern matching

### Type annotations and initializers

Always include explicit type annotations for all local variable bindings. This includes variables bound by destructuring tuples. Always spell out initializer calls with explicit '`init`' tokens. Use leading dot notation for initializers, except for numeric casts within larger expressions, which should state the type name and the `init` token (e.g. `Double.init(x)`).

```swift
// ✓ CORRECT
let random: PseudoRandom = .init(seed: 3)
let array: [Int] = .init(repeating: 0, count: 10)
let value: Double = .init(intValue)
let result: Double = x + Double.init(z)
let (name, age): (String, Int) = ("Alice", 30)

// ✗ INCORRECT
let random = PseudoRandom(seed: 3)
let array = [Int](repeating: 0, count: 10)
let value = Double(intValue)
let (name, age) = ("Alice", 30)
let x: Double = Double.init(intValue) // Should use leading dot notation
let y: Double = x + .init(z) // Should use type name `Double.init` for interior numeric cast
```

### Loop/expression bindings

Always include explicit type annotations for variables bound in `for`, `while`, and `if` statements.

This applies to positions where Swift supports type annotations, including:

- Range-based `for` loops: `for i: Int in 0 ..< count`
- Collection iteration: `for item: String in items`
- `if`-`let` bindings: `if let foo: Data = bar`

```swift
// ✓ CORRECT
for i: Int in 0 ..< 10 { }
for item: String in items { }

// ✗ INCORRECT
for i in 0 ..< 10 { }
for item in items { }
```

Please note that there are some places that the Swift compiler does not support type annotations, such as in `case .x(let x)` bindings.

```swift
// ✗ INCORRECT
case .success(let value: Int): // will not compile!
```

### Pattern binding in switch cases

When pattern matching with associated values in enums, use individual `let` keywords for each variable binding rather than placing a single `let` before the pattern.

```swift
// ✓ CORRECT - Individual let for each variable binding
switch result {
case .success(let value, let metadata):
    // use value and metadata

case .failure(let error):
    // use error
}

// ✗ INCORRECT - Single let before the pattern
switch point {
case let .coordinates(x, y, z):
    // use x, y, z
}
```

## Naming

### Prefer full words, or single letters

Prefer spelling out complete words, unless the abbreviation is a common standalone term of art, like “min” or “max”. Avoid abbreviating variable or function names. **Always spell out abbreviated compound words.**

```
// ✓ CORRECT
let probability: Double = 0.5
let frequency: Double = count / total
let relativeError: Double = diff / expected  // NOT "relError"
let max: Double = values.max() // "max" is acceptable, and preferred over 'maximum', as it’s a term of art, despite being an abbreviation

// ✗ INCORRECT - Don't abbreviate compound words
let prob: Double = 0.5
let freq: Double = count / total
let relError: Double = diff / expected  // Should be "relativeError"
```

**Common abbreviations to avoid:**
- `relFoo` → `relativeFoo`
- `tempFoo` → `temporaryFoo`
- `numItems` → `items` or `itemCount`
- `avgFoo` → `averageFoo`

Default to single letters like `i` for indices, unless a longer name would provide meaningful clarity.

```swift
// ✓ CORRECT
let j: String.Index = string.index(after: i)

// ✗ INCORRECT
let nextIdx: String.Index = string.index(after: currentIdx)
```

Default to single letters like `x`, if reproducing well known mathematical formulae.

```swift
// ✓ CORRECT
let c: Double = .sqrt(a * a + b * b)

// ✗ INCORRECT
let hypotenuse: Double = .sqrt(sideOne * sideOne + sideTwo * sideTwo)
```

### Avoid meaningless suffixes

Omit suffixes like `-Value` that add no clarity, or are redundant in the context of static type information.

```swift
// ✓ CORRECT
let foo: String = "\(percentage)"

// ✗ INCORRECT
let fooValue: String = "\(percentage)"
```

### Binding `self`

Shadow the `self` keyword if something is semantically an instance method, but cannot be expressed as such due to the constraints of the language. Common examples include operator declarations.

```swift
// ✓ CORRECT
static func += (self: inout Self, next: Self) {
}

// ✗ INCORRECT
static func += (lhs: inout Self, rhs: Self) {
}
```

When switching on `enum` variants with payloads, shadow `self` if you are conceptually switching on cases of `self`.

```swift
// ✓ CORRECT
switch self {
case .bool(let self): ...
case .int(let self): ...
case .float(let self): ...
}

// ✗ INCORRECT
switch self {
case .bool(let bool): ...
case .int(let int): ...
case .float(let float): ...
}
```

Only do this for variant-like enums.

```swift
// ✓ CORRECT
switch self {
case .foo(id: let id, let value): ...
}

// ✗ INCORRECT
switch self {
case .foo(id: let self, let value): ...
}
```

### Avoid `lhs` and `rhs`

The names `lhs` and `rhs` are terrible parameter names, and should never be used. Use `a` and `b` in binary operator signatures instead.

Please note that the names `lhs` and `rhs` are commonly prescribed by other Swift style guides, but this project has a different convention.


### Closure parameters

**Always prefer shorthand argument names (`$0`, `$1`) for simple closures**. Only use explicit parameter names in the following cases:
- Very large closures (>50 lines)
- Nested closures where you need to disambiguating outer parameters
- When the closure logic becomes significantly more readable with named parameters

```swift
// ✓ CORRECT
let sum: Double = values.reduce(0, +)
let squares: Double = values.reduce(0) { $0 + $1 * $1 }

// ✗ INCORRECT - Don't name parameters in simple closures
let sum: Double = values.reduce(0) { accumulator, value in accumulator + value }
let squares: Double = values.reduce(0) { (accumulator, value) in accumulator + value * value }
```

If you decide to name a closure parameter, always include a type annotation. It’s okay to omit the return type, if type inference allows for it.

#### Tuple Splatting in Closures

When a closure receives a tuple as its single argument, **prefer splatting the tuple elements into separate shorthand arguments** (`$0`, `$1`, `$2`, etc.) rather than accessing tuple members (`$0.0`, `$0.1`, `$0.2`, etc.).

```swift
// ✓ CORRECT - Splat tuple elements into $0, $1, $2
let result = enumerated.map {
    ($0, $1 * 2)  // $0 is index, $1 is value
}

let histogram = items.enumerated().map {
    let midpoint = range.min + (Double($0) + 0.5) * binWidth  // $0 is index
    return (midpoint: midpoint, count: $1)                    // $1 is value
}

// ✗ INCORRECT - Don't access tuple members when you can splat
let result = enumerated.map {
    ($0.0, $0.1 * 2)  // Should use $0, $1
}

let histogram = items.enumerated().map {
    let midpoint = range.min + (Double($0.0) + 0.5) * binWidth  // Should use $0
    return (midpoint: midpoint, count: $0.1)                    // Should use $1
}
```

How to identify when tuple splatting applies:

- The closure takes exactly one argument that is a tuple
- Common cases: `.enumerated().map`, `.zip(...).map`, functions returning tuples
- If you find yourself writing `$0.0`, `$0.1`, `$0.2`, consider if tuple splatting applies

### Grouping variables with tuples

Group related variables using tuples with named elements instead of separate variables.

```swift
// ✓ CORRECT
let range: (min: Int64, max: Int64) = (
    min: .init(expected.μ - 3 * Double.sqrt(expected.σ²)),
    max: .init(expected.μ + 3 * Double.sqrt(expected.σ²))
)
print("Range: \(range.min) to \(range.max)")

// ✗ INCORRECT
let minRange: Int64 = .init(expected.μ - 3 * Double.sqrt(expected.σ²))
let maxRange: Int64 = .init(expected.μ + 3 * Double.sqrt(expected.σ²))
print("Range: \(minRange) to \(maxRange)")
```

### Greek Letters as terms of art

Use proper mathematical symbols for well-known concepts.

```swift
// ✓ CORRECT
let μ: Double = 0.5       // mean
let σ: Double = 0.7       // standard deviation
let σ²: Double = 0.49     // variance

// ✗ INCORRECT
let mean: Double = 0.5
let stdDev: Double = 0.7
let variance: Double = 0.49
```


## Coding patterns

### Using `reduce(into:_:)`

Prefer `reduce(into:_:)` for accumulation operations that would otherwise require multiple passes.

```swift
// ✓ CORRECT
let maximumFrequency: Double = (k.min ... k.max).reduce(into: 0.0) {
    let count: Int = histogram[$1, default: 0]
    let frequency: Double = .init(count) / .init(samples)
    $0 = max($0, frequency)
}

// ✗ INCORRECT
let maximumFrequency: Double = (k.min ... k.max).map {
    let count: Int = histogram[$0, default: 0]
    return Double(count) / Double(samples)
}.max() ?? 0.0
```

For accumulations that don’t mutate collections, you can also use an ordinary `reduce(_:_:)`.

### Don’t parrot tuple lables

Swift’s type system is capable of propogating tuple labels through unlabeled tuples. Don’t repeat tuple labels if they’re specified from the outside, such as through a variable’s type annotation.

```swift
// ✓ CORRECT
let stats: (sum: Double, sumSquares: Double) = samples.reduce(into: (0, 0)) {
    $0.sum += $1
    $0.sumSquares += $1 * $1
}

// ✗ INCORRECT
let stats: (sum: Double, sumSquares: Double) = samples.reduce(into: (sum: 0.0, sumSquares: 0.0)) {
    $0.sum += $1
    $0.sumSquares += $1 * $1
}
```


## Object-oriented code

### Explicit `self`

When writing instance members, always refer to other instance members with explicit `self`. Static members should be referred to with explicit `Self` (for enum, struct, or protocol members), or the name of the type (for class members).

```swift
// ✓ CORRECT
let foo: Int = self.bar

// ✗ INCORRECT
let foo: Int = bar
```

In a `static` context, refer to `Self` as `Self`, even though the compiler would also allow it to be spelled as a lowercase `self`.

### Start with `static`

When writing new functions (including subscripts and properties), start with `static` and only upgrade them to instance members if the implementation actually needs to access instance members.

## Code organization

Place related functionality in extensions:

```swift
// ✓ CORRECT
extension NormalTests {
    static func statistics(from samples: [Double]) -> (μ: Double, σ²: Double) {
        // Implementation
    }
}

extension NormalTests {
    @Test
    mutating func Statistics(_ μ: Double, _ σ: Double) {
        // Test implementation
    }
}
```

## External dependencies

### Foundation

Never import `Foundation` unless explicitly instructed to.

This means you *may* need to provide local implementations for common `String` formatting tasks.


### Numerics (`RealModule`)

Remember that common mathematical functions in Swift (except for `min`, `max`, and `abs`) are static members on floating point types. A bare `sqrt(x)` call will not compile!

```
// ✓ CORRECT
let x: Double = .sqrt(a)
let y: Double = b + .sin(c)

// ✗ INCORRECT
let x: Double = sqrt(a)
let y: Double = b + sin(c)
```

### Testing

Use Swift Testing (`import Testing`), not XCTest, which is deprecated.

In modern Swift, the Swift Testing framework ships with the toolchain, and does not need to be added as an explicit dependency.

Always organize Swift Testing tests into suites (`@Suite`).

Individual test functions (`@Test`) should have names that begin with an uppercase letter. This is a special naming convention specific to test functions.
