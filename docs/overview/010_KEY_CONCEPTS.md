<small>

`Previous` [README](../README.md#-documentation) | `Next` [Basic Usage](./020_BASIC_USAGE.md)

</small>

---

# The Key Concepts

### What is a process?

A sequence of steps or actions to achieve a specific end. In other words, it is a series of steps that produce a result.

### What is a `Solid::Process`?

It is a class that encapsulates reusable business logic. Its main goal is to **ACT AS AN ORCHESTRATOR** who knows the order, what to use, and the steps necessary to produce an expected result.

### Core Concepts at a Glance

| Concept | Description |
|---------|-------------|
| **Input** | Defines what data the process needs |
| **Output** | The result (`Success` or `Failure`) |
| **Steps** | Named methods that can be chained |
| **Dependencies** | Collaborators that can be injected |

### Why not just use...?

Unlike plain service objects, `Solid::Process` provides built-in input validation, result typing, and observability. Unlike Interactors, it offers a Steps DSL for explicit flow control. Unlike Dry::Transaction, it integrates seamlessly with Rails conventions.

### Emergent Design

The business rule is directly coupled with business needs. We are often unclear about these rules and how they will be implemented as code. Clarity tends to improve over time and after many maintenance cycles.

For this reason, this abstraction embraces emerging design, allowing developers to implement code in a basic structure that can evolve and become sophisticated through the learnings obtained over time.

### The Mantra

* **Make it Work**, then
* **Make it Better**, then
* **Make it Even Better**.

Using the emerging design concept, I invite you to embrace this development cycle, write the minimum necessary to implement processes and add more solid-process features based on actual needs.

<p align="right"><a href="#the-key-concepts">⬆️ &nbsp;back to top</a></p>

---

<small>

`Previous` [README](../README.md#-documentation) | `Next` [Basic Usage](./020_BASIC_USAGE.md)

</small>
