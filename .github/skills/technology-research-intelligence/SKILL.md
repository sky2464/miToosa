---
name: technology-research-intelligence
description: Researches fast-moving technology, security, and ecosystem changes from authoritative sources and social signals. Use when you need a current recommendation, comparison, or risk assessment that depends on the latest information.
---

# Technology Research Intelligence

## Overview

Convert noisy, time-sensitive information into a recommendation you can trust. This skill is for situations where current reality matters more than memorized best practice.

## When to Use

- Evaluating libraries, frameworks, tools, hosting, or architecture patterns
- Checking release notes, breaking changes, deprecations, or migration guidance
- Investigating security issues, advisories, CVEs, or supply-chain concerns
- Comparing current community sentiment, adoption signals, or pain points
- Answering open technical questions where the latest information changes the answer

## Source Hierarchy

Use sources in this order:

1. Official docs, release notes, changelogs, API references, migration guides
2. Security advisories, CVEs, vendor statements, maintainer issues and PRs
3. Standards, RFCs, benchmarks, and reference implementations
4. High-signal community discussion from Reddit, X, Hacker News, and similar places as discovery only
5. Blog posts and commentary as supporting context only

## Research Workflow

1. Restate the question and the decision criteria.
2. Identify the current stack, constraints, and existing decisions from the repo context.
3. Gather the newest authoritative sources.
4. Scan community sources for regressions, adoption patterns, and unresolved edge cases.
5. Separate verified facts from anecdotal claims.
6. Compare at least two viable options and state the default recommendation.
7. Record durable findings in /memories/repo/researcher.md when the result should survive future sessions.

## Output Format

- Bottom line
- Verified facts
- Emerging signals
- Recommendation
- Risks and next checks
- Sources and verification dates

## Guardrails

- Never present Reddit or X sentiment as fact without corroboration.
- Never use a single source for a breaking change or security claim.
- Always note the publication date or verification date for time-sensitive claims.
- If sources conflict, say which ones are higher trust and why.
- If the best answer depends on the app’s existing architecture, say so directly.

## Memory Protocol

- Keep durable repository-specific notes in /memories/repo/researcher.md.
- Keep notes short, factual, and dated.
- Do not store speculation as a fact.
- Update the memory when a recommendation becomes a standard pattern for this codebase.
