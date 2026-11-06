# Tasks

Implementation checkboxes are updated after accepted work is incorporated and
verified in the committed starting code. The group reviews the worker briefs in
[tickets/](../../../tickets/) before backlog sign-off; writing this checklist
does not authorize starting a worker.

Delivery targets the personal fork `dbaz-orisha/sdd-workshop`: push each run
branch there and open its PR against the fork, with human merge. Incorporate
accepted prerequisite code into the committed starting branch before running
dependent tickets. The first 001 run passed implementation, checks and review
but delivery to the original repository was denied; publishing its existing
branch to the fork is pending.

## 1. Core pricing contracts

- [ ] 1.1 Add exact cent arithmetic and percentage pricing with `money-percentage.test.html`; verify `sh app/check.sh lint` and `sh app/check.sh test` (ticket 001).
- [ ] 1.2 Add valid promotion definitions and product/shop/inclusive-date eligibility with `promotion-definitions.test.html`; verify both app checks (ticket 002).
- [ ] 1.3 Generate all relevant configured multi-unit and percentage applications with `multi-unit-offers.test.html`; verify both app checks (ticket 003).
- [ ] 1.4 Select the lowest valid basket total and deterministic priority winner with `best-basket-price.test.html`; verify both app checks (ticket 004).

## 2. User workflows

- [ ] 2.1 Add marketing creation/editing and visible validation with `marketing-page.test.html`; verify both app checks (ticket 005).
- [ ] 2.2 Add automatic till calculation, cashier explanation and recalculation with `till-recalculation.test.html`; verify both app checks (ticket 006).
- [ ] 2.3 Add compact, non-stale receipt savings with `receipt-savings.test.html`; verify both app checks (ticket 007).

## 3. Cross-view acceptance

- [ ] 3.1 Prove the real marketing-to-till-to-receipt workflow with `promotion-journey.test.html`; verify all accumulated app checks without production changes (ticket 008).

## Dependencies

| Ticket | Requires | Main requirement coverage |
| --- | --- | --- |
| [001](../../../tickets/001-money-percentage.md) | None | Money, percentage discounts |
| [002](../../../tickets/002-promotion-definitions.md) | None | Validation, product/shop/date eligibility |
| [003](../../../tickets/003-multi-unit-offers.md) | 001, 002 | Both multi-unit types, grouping, discounted unit, repetition |
| [004](../../../tickets/004-best-basket-price.md) | 003 | Non-stacking best basket price, priority |
| [005](../../../tickets/005-marketing-page.md) | 002 | Marketing creation/editing, visible errors and configuration |
| [006](../../../tickets/006-till-recalculation.md) | 004, 005 | Automatic application, current definitions, recalculation, cashier visibility |
| [007](../../../tickets/007-receipt-savings.md) | 006 | Compact positive savings, omitted zero savings |
| [008](../../../tickets/008-promotion-journey.md) | 007 | Cross-view acceptance of the whole agreed workflow |

The graph takes the smallest ready ticket first. Tickets 001 and 002 have no
prerequisites; later tickets may run only after their dependencies are accepted.
No ticket is marked complete until its VERIFY passes.

## Workflow follow-up

- Review the eight worker briefs with group-4; adjust scope and acceptance as requested.
- Record backlog sign-off only after the group has reviewed and approved these tickets.
- Implement only through an explicitly assigned worker ticket in the later workshop flow.
- Merge accepted PRs in the personal fork and incorporate the prerequisite code into the committed starting branch before proceeding to dependent tickets.
- After all tickets pass and review is accepted, archive the change with OpenSpec to update the living specifications.
