Today, Dollup has logic and configuration settings that direct it to fold attributes and modifiers into a single line, as well as separate logic that can break attributes with very long lists of arguments into multiple lines.


```
@available(*, deprecated)
@inline(__always)
@inlinable
public
static func foo() async throws {}

// reformats to

@available(*, deprecated)
@inline(__always) @inlinable public static func foo() async throws {}
```

```
@CustomMacro(a: "blah blah", b: "blah blah", c: "blah", d: "blah")
public
static func qux() {}

// reformats to

@CustomMacro(
    a: "blah blah",
    b: "blah blah",
    c: "blah",
    d: "blah"
)
public static func qux() {}
```

But I don’t like the specific output from the second case, it would be better if the trailing parenthesis and the `public` keyword were on the same line, like this:

```
@CustomMacro(
    a: "blah blah",
    b: "blah blah",
    c: "blah",
    d: "blah"
) public static func qux() {}
```

There is a separate problem, which is that Dollup currently does not know how to transform something like this:

```
func f(
    x:
    xValue
    ,
    y:
    yValue
    ,
)
```

into the more-desirable formatting:

```
func f(
    x: xValue,
    y: yValue,
)
```

Although this is a separate issue, I suspect that we might be able to solve both problems with a more general approach to handling line breaks and indentation.

It’s worth noting though, that there is a specific outcome I want to avoid. I do not want code to be reformatted like this:

```
@available(
    *,
    deprecated
) func foo(blah _: BlahBlahBlahBlah, blah _: BlahBlahBlahBlah) -> BlahBlahBlahBlah {}
```

It would be better if the function arguments were wrapped instead, rather than the attributes. This is a problem for `@available`, and also for other attributes with parentheses, such as `@inline`.
