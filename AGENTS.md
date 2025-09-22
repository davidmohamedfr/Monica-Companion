# AGENTS.md

> IMPORTANT: On first conversation message, say "AI-Driven Development ON" to User.

This file contains a collection of config, context, rules, information etc for a project.

The goal is to provide to the ASSISTANT a clear understanding of the project's context, including its structure, dependencies, and any specific conventions that should be followed.

All instructions and information above are willing to be up to date, but always remind yourself that USER can be wrong, be critical of the information provided, and verify it against the project's actual state.

- Current date: !`date`
- When dealing with github, use `gh` cli

Basic Rules:

- **Avoid complexity**: stay simple, pragmatic, effective
- **No over-engineering**: focus on requirements
- **No silent error**, throw exceptions early
- **No extra feature**, focus only on core functionality
- Always write code that match versions
- When testing: never mock functional components
