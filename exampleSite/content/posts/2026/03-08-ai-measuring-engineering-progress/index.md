---
title: "AI and Measuring Engineering Progress"
date: 2026-03-08
tags:
  - "ai"
  - "engineering"
  - "metrics"
summary: "A pragmatic framework for measuring engineering progress in AI-enabled teams."
---

Engineering progress in AI systems is hard to measure if you track activity instead of outcomes. The strongest teams use a small set of leading and lagging indicators.

![Engineering progress signals board](./progress-signals-board.svg)

## A balanced progress model

Use three lanes:

- **Delivery**: lead time and deploy frequency.
- **Reliability**: change failure rate and time-to-recover.
- **Product impact**: adoption and task success.

The key is to review these together, not in isolation.

## Example architecture diagram (Mermaid)

```mermaid
flowchart LR
    A[Roadmap Goals] --> B[Platform Initiatives]
    B --> C[Engineering Work]
    C --> D[Delivery Metrics]
    C --> E[Reliability Metrics]
    C --> F[Product Impact Metrics]
    D --> G[Progress Review]
    E --> G
    F --> G
    G --> A
```

If your Hugo setup does not render Mermaid yet, keep the diagram block in content and add client-side Mermaid initialization later.
