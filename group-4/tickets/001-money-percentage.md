# 001 - Exact EUR pricing and percentage discounts

## GOAL

Give Brisa correct percentage-discount prices and savings, including amounts
that fall on half-cent boundaries.

## SCOPE

Create only `app/money.js` and `app/test/money-percentage.test.html`.
Do not edit the page, test helper, check runner, graph, or planning documents.

## CONTEXT

The app currently has only a title and heading; there is no price calculation.
No preceding ticket is required. Implement the money entry point in
[design.md](../openspec/changes/shop-promotions/design.md).
Source requirements: "Money is calculated in EUR cents" and "Percentage
discounts are supported" in the
[specification](../openspec/changes/shop-promotions/specs/shop-promotions/spec.md).
[DOMAIN.md](../DOMAIN.md) and the specification establish automatic discounts;
do not build selection or views yet.

## ACCEPTANCE

1. A EUR 100 unit with a 20% discount costs EUR 80; the input price is unchanged.
2. A EUR 1.01 unit with a 50% discount costs EUR 0.51, using final-price half-up rounding.
3. Two independently discounted EUR 1.01 units total EUR 1.02, saving EUR 1.00.
4. A 100% discount gives zero; a fractional 12.5% discount on EUR 8 gives EUR 7.
5. Negative, non-integer, non-finite or unsafe cent inputs, and non-finite, zero, negative or above-100 percentages raise explicit errors rather than returning an apparently valid price.

## VERIFY

Add the named browser test, loading `check.js` and `../money.js`, with a
`check` or `checkThrows` assertion for every acceptance number.
From `group-4`, run:

```sh
sh app/check.sh lint
sh app/check.sh test
```

Both must exit zero; the test must print `ok` for each check and no `FAIL`.
The runner checks all accumulated pages; it has no individual-test selector.

## FORBIDDEN

No floating-point monetary totals, rounded-discount subtraction, silent invalid
input defaults, promotion selection, UI, dependencies, Node, or build tools.
Do not weaken, remove or skip existing tests.

## REPORT

Follow [REPORT.md](../graph/REPORT.md): report this ticket as done or blocked,
list changed files, give the exact commands, exit statuses and assertion output,
and state anything not completed. Do not claim done without passing VERIFY.
