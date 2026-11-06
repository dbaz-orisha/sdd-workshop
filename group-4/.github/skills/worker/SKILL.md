---
name: worker
description: 'Use when the graph assigns a group-4 Shop promotions implementation ticket. Implement only that ticket, test first, respect its scope, and write the required report.'
---

# Group-4 promotion worker

## Role

Implement the assigned ticket, not the whole product. This workshop app uses
plain HTML, CSS and JavaScript loaded in a browser, with no dependencies or
build step. Do not use tooling or scripts from unrelated projects.

## Procedure

1. Read the assigned ticket, its seven sections and the standing orders supplied
   in the prompt. Read only its relevant specification and design references,
   prerequisite implementation, and existing test helper.
2. If a previous step is supplied as `LAST`, read its result and report. Repair
   the stated failure within the same ticket; do not add unrequested features.
3. Follow the ticket's SCOPE exactly. If prerequisites or a necessary business
   rule are missing, report blocked rather than inventing an answer.
4. Write the named acceptance tests first. Use local browser test pages loading
   `check.js`, with `check` or `checkThrows` assertions for every acceptance
   number. Confirm a missing behavior is red before implementing it.
5. Implement the smallest complete change that satisfies the ticket. Reuse
   earlier helpers and the shared contracts in the design. Preserve prior
   behavior and tests; fix test failures without weakening their requirements.
6. Run the exact VERIFY commands. For UI tickets, test real controls and rendered
   outputs, not only calculation helpers. If the required browser is missing,
   report the validation blocker rather than claiming success.
7. Write the requested report path and stop. Do not commit, push, open a pull
   request, or run git; delivery belongs to the graph's command step.

## Agreed promotion rules

Apply only the rules relevant to the assigned ticket:

- Marketing creates offers and chooses eligible products, shops, inclusive
  shop-local dates and positive whole-number priorities.
- Supported types are percentage discount, second unit at half price, and buy
  three/pay two. Do not add other promotion types.
- For both multi-unit types, grouping, cheapest/most-expensive discounted unit,
  and once/repeat behavior are configurable once per promotion.
- Apply offers automatically. Choose the valid non-stacking combination with
  the lowest total basket price, not independent product-level winners.
- Respect configured rules when calculating the best price. Different
  promotions cannot claim the same product; group units cannot be reused.
- Compare equal-price combinations by descending priorities, missing entries
  below configured values, then stable identifiers. Price comes before priority.
- Calculate EUR cents with half-up rounding of each discounted unit's final
  price. Derive totals and savings from rounded prices.
- Recalculate after basket changes and use current valid definitions on the
  next calculation. Invalid input produces an explicit error, not a fallback.
- Show applied promotions to the cashier. Show one compact receipt savings
  summary only when savings are positive.

## Report

Follow the assigned `graph/REPORT.md` exactly, with four headings in this order:
`## Ticket`, `## Changed`, `## Checked`, `## Not done`.

Give done or blocked, each changed file, actual verification commands and their
outputs, and remaining work. Do not claim a check passed unless it ran and
passed. A report is required even when work is blocked.
