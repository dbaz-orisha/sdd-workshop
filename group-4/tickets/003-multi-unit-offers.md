# 003 - Configurable multi-unit offer applications

## GOAL

Calculate the offer applications marketing has authorized for second unit at
half price and buy three/pay two, without guessing grouping or repetition.

## SCOPE

Create only `app/offers.js` and `app/test/multi-unit-offers.test.html`.
Read earlier app scripts but do not edit them, the page, test helper or graph.

## CONTEXT

Requires tickets 001 and 002: money arithmetic and validated eligibility.
Neither earlier ticket generates multi-unit applications.
Implement `offers.candidates` and its application records described in
[design.md](../openspec/changes/shop-promotions/design.md).
Source [specification](../openspec/changes/shop-promotions/specs/shop-promotions/spec.md)
requirements: both multi-unit types, configurable grouping, discounted-unit
choice and repetition. Generate percentage applications too for the selector
in ticket 004, reusing ticket 001 rather than recoding money.
Marketing owns these settings; [DOMAIN.md](../DOMAIN.md) forbids stacking.

## ACCEPTANCE

1. Two identical EUR 10 units under second-half cost EUR 15; three under three-for-two cost EUR 20.
2. Same-product grouping rejects mixed linked pairs and mixed linked triples.
3. Mixed grouping admits linked products and excludes unlinked products; three linked EUR 10 products cost EUR 20 under three-for-two.
4. With a mixed EUR 10/EUR 20/EUR 30 triple, cheapest-free costs EUR 50 and most-expensive-free costs EUR 30.
5. With a mixed EUR 10/EUR 30 pair, cheapest-half costs EUR 35 and most-expensive-half costs EUR 25.
6. Six EUR 10 units under three-for-two cost EUR 40 with repeat and EUR 50 with once.
7. Four EUR 10 units under second-half cost EUR 30 with repeat and EUR 35 with once.
8. Insufficient units do not qualify; remainder units keep their original price; qualifying units cannot be consumed twice in one application.
9. The EUR 1.01 half-price pair totals EUR 1.52; existing money and eligibility helpers determine rounding and shop/date filtering.
10. Candidate generation includes different valid group allocations, not only the first units in basket order; repeating applications respect their configured setting.
11. Candidate metadata identifies every participating unit and product, including full-price members, so later selection can enforce non-stacking.
12. Percentage candidates use the configured percentage and existing rounded-unit arithmetic; inputs are not mutated.

## VERIFY

Add the named browser test loading `check.js`, money, definitions and offers.
Assert every number above, including mixed and same-product configurations for
both types. From `group-4`, run:

```sh
sh app/check.sh lint
sh app/check.sh test
```

Both must exit zero with `ok` assertions and no `FAIL`.

## FORBIDDEN

No greedy winner selection, UI, independent money rounding, undisclosed group
limits, ignored configuration, new dependencies or test weakening.
Do not implement the global optimization assigned to ticket 004.

## REPORT

Follow [REPORT.md](../graph/REPORT.md). Give done/blocked, changed files, exact
commands and outputs, and unmet criteria. State which configurations the tests
cover; do not substitute a visual check for VERIFY.
