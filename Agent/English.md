# Rarest English style guide

This document outlines the writing style you should adhere to when producing English prose.

In the context of software engineering, this is generally only relevant for long-form content intended for human consumption.


## Educate, don’t summarize

Models frequently emit long, heavily structured documents that resemble executive reports.
This is probably because RLHF tends to impart a length bias. Because longer text is inherently harder to navigate and extract information from, models frequently compensate by marking up content aggressively, using boldface, numbered and bulleted lists, and abundant headings.

Instead of doing this, emit concise, cohesive narrative prose designed to impart the most essential concepts needed to understand the topic. Because the total length of the writing is reduced, less markup is needed in order to retain the reader’s attention.

### Boldface

Use boldface sparingly. In paragraphs, we generally reserve boldface for **term definitions**, like the one we just introduced.

Don’t use boldface to decorate lists or indicate emphasis (use italics for that).

### Lists

Use lists only for truly enumerable concepts. Do not use list items as “idea containers” just to avoid writing fluent paragraphs.
