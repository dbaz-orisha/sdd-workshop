# 002 - Valid promotions and product, shop and date eligibility

## GOAL

Give marketing valid promotion definitions and ensure each offer is eligible
only for the linked products, selected shops and inclusive local-date period.

## SCOPE

Create only `app/promotions.js` and `app/test/promotion-definitions.test.html`.
Do not edit the page, other app scripts, shared test helper, check runner or graph.

## CONTEXT

There is no promotion model or eligibility behavior in the starting app.
This ticket has no preceding-ticket prerequisite.
Use the promotion records and validation/eligibility entry points from
[design.md](../openspec/changes/shop-promotions/design.md).
The [specification](../openspec/changes/shop-promotions/specs/shop-promotions/spec.md)
requirements are "Invalid promotion definitions are rejected visibly",
"Marketing defines product eligibility", and "Marketing defines shop and date
eligibility". This ticket provides explicit validation errors; ticket 005
displays them. The marketing choices are in [DOMAIN.md](../DOMAIN.md).

## ACCEPTANCE

1. Valid percentage, second-half and three-for-two definitions are accepted; stable IDs and product/shop references are retained.
2. One product can be linked to multiple valid promotions without applying them at this stage.
3. An unlinked product or unselected shop is ineligible; a linked product at a selected shop can qualify.
4. A November 1-7 offer qualifies on both boundary dates, but not October 31 or November 8, using an explicit shop-local date.
5. Missing or blank names, unknown types/IDs, empty product/shop selections, invalid dates and reversed ranges produce specific validation errors.
6. Percentage values must be finite, greater than zero and at most 100; fractional values are accepted.
7. Priorities must be positive whole numbers; unsupported grouping, discounted-unit or repetition values, or missing required multi-unit settings, produce errors.
8. Invalid definitions are not normalized into successful defaults; validating and evaluating eligibility do not mutate input definitions.

## VERIFY

Add `app/test/promotion-definitions.test.html`, loading `check.js` and the new
script. Include valid cases and a `checkThrows` case for every invalid-input
family in the acceptance criteria. From `group-4`, run:

```sh
sh app/check.sh lint
sh app/check.sh test
```

Both commands must exit zero; all acceptance assertions must print `ok`.

## FORBIDDEN

No pricing, discount application, form implementation, production rollout,
new business defaults, dependencies, test-helper changes or test weakening.
Eligibility does not select a winner or permit stacking.

## REPORT

Follow [REPORT.md](../graph/REPORT.md): done or blocked, changed files, exact
verification commands and results, and unmet criteria. Distinguish validation
errors deliberately tested from failures of VERIFY.
