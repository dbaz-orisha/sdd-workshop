# 008 - Verify the complete marketing-to-receipt journey

## GOAL

Prove the completed page delivers Brisa's agreed workflow from marketing's
definition to the cashier's best price and the customer's receipt.

## SCOPE

Create only `app/test/promotion-journey.test.html`.
All production files are read-only. Report any production failure as blocked;
do not change production behavior or earlier tests in this ticket.

## CONTEXT

Requires ticket 007, which transitively requires the pricing engine and views.
Earlier tickets own their focused tests; this ticket owns cross-view acceptance.
Use [design.md](../openspec/changes/shop-promotions/design.md), the complete
[specification](../openspec/changes/shop-promotions/specs/shop-promotions/spec.md),
and the client's goal in [DOMAIN.md](../DOMAIN.md).
No existing test covers a real marketing-to-till-to-receipt workflow.

## ACCEPTANCE

1. Through real page controls, marketing creates overlapping valid percentage offers; the cashier receives the best non-stacked price and one matching receipt savings line.
2. Marketing defines a mixed three-for-two offer and competing isolated discount; three EUR 10 products total EUR 20, not EUR 25, with EUR 10 receipt savings.
3. Marketing's cheapest/most-expensive choice changes a mixed EUR 10/EUR 20/EUR 30 triple's total from EUR 50 to EUR 30 after recalculation.
4. Switching a second-half offer from same-product to mixed grouping changes eligibility for two different linked products; its discounted-unit and repetition settings are respected.
5. Product, selected-shop and inclusive-date eligibility, quantity changes and removal are reflected consistently in till prices, promotion names and receipt savings.
6. Invalid marketing edits display an error and leave the prior valid offer usable; no zero-savings summary appears when no offer applies.
7. Equal-price offers follow configured priority; equal-priority selection is stable across repeated calculations.
8. All earlier tests still pass; the integration test asserts actual controls and rendered outputs rather than bypassing views with helper-only calls.

## VERIFY

Load the real local app page in the named browser test and use `check.js`.
Drive actual marketing, till and receipt controls with deterministic products,
shops and dates. Check at least one visible result for each acceptance line.
From `group-4`, run:

```sh
sh app/check.sh lint
sh app/check.sh test
```

Both must exit zero and all focused and integration tests must print `ok`.

## FORBIDDEN

No production fixes, mocked best-deal results, replacing earlier tests,
deleting failures, new dependencies, modifying the runner or graph, or starting
another ticket. If a requirement fails, identify the failing owning ticket.

## REPORT

Follow [REPORT.md](../graph/REPORT.md). Give done/blocked, changed files,
exact commands and outputs, and the tested user journeys. If blocked, give the
failing scenario, observed/expected values and the owning ticket.
