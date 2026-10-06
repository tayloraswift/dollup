## Don’t say “fragile” when what you really mean is “brittle”

In software, “fragile” is good! in an ideal code base, flipping a single minus sign to a plus *should* totally invert the behavior! You don’t want to have to hunt down a million fallbacks and default configurations to change something.

Software engineering is not like mechanical engineering. “Robust” systems in software are bad, they’re hard to maintain, hard to debug and reason about, and prone to decay. You always want to be thinking along a “brittle versus flexible” axis, never a “fragile versus robust” axis.
