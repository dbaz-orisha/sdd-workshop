# 004 - Lowest basket price without stacking

## GOAL

Charge the customer the lowest valid total basket price and consistently
identify the selected promotions when several offers compete.

## SCOPE

Create only `app/pricing.js` and `app/test/best-basket-price.test.html`.
Do not edit earlier app scripts, views, test helper, check runner or graph.

## CONTEXT

Requires ticket 003, which itself requires 001 and 002.
Candidates exist after 003 but no global winner is selected.
Implement `pricing.calculate` and its result contract from
[design.md](../openspec/changes/shop-promotions/design.md).
Source [specification](../openspec/changes/shop-promotions/specs/shop-promotions/spec.md):
"Promotions do not stack" and "Promotion priority resolves equal-price ties".
The best deal is the lowest basket total, not an independent product choice.
The original non-stacking decision is in [DOMAIN.md](../DOMAIN.md).

## ACCEPTANCE

1. A EUR 100 product eligible for 10% and 20% costs EUR 80; two 20% offers still cost EUR 80, not a stacked price.
2. Three different EUR 10 products eligible together for three-for-two cost EUR 20 instead of EUR 25 from an isolated 50% offer on one product.
3. Selected applications neither reuse units nor assign different promotions to the same product; full-price members of a group are not available for another offer.
4. The selected combination is the lowest total under the configured grouping, discounted-unit and repetition rules; never override cheapest-free with most-expensive-free.
5. A lower-price offer wins even if another has higher priority; equal-price alternatives prefer higher priority, then next-highest priorities.
6. For equal prices and matching priority prefixes, another positive priority outranks a missing entry.
7. Remaining ties use stable promotion IDs consistently; changing the order of equivalent input definitions does not change the selected combination or total.
8. Empty baskets total zero; no eligible offers leave original totals unchanged, with zero savings and no selected promotion.
9. Results include original/final totals, savings, unit prices and applied-promotion IDs; totals sum rounded prices, savings equal original minus final, and inputs remain unchanged.
10. Invalid basket references, quantities, definitions or unsafe arithmetic report explicit errors rather than an undiscounted success result.

## VERIFY

Add the named browser test loading all core scripts and `check.js`. Include
small, explicitly enumerated competing combinations with exact expected totals;
do not validate the selector solely against itself. From `group-4`, run:

```sh
sh app/check.sh lint
sh app/check.sh test
```

Both must exit zero; each acceptance assertion prints `ok`.

## FORBIDDEN

No greedy approximation, truncated search, priority-over-price decisions,
double use of group units, silent failure fallback, UI, new dependencies or
test weakening.

## REPORT

Follow [REPORT.md](../graph/REPORT.md). Report done/blocked, changed files,
commands, assertion outputs and unmet criteria. State the exact competing
totals proven by the tests.
