# 007 - Compact receipt savings

## GOAL

Show the customer the benefit of promotions in one short receipt summary,
without unnecessary lines when nothing was saved.

## SCOPE

Create `app/receipt.js` and `app/test/receipt-savings.test.html`.
Edit `app/index.html` and, if needed, `app/style.css`.
Do not edit calculation, marketing or till scripts, helper, runner or graph.

## CONTEXT

Requires ticket 006, which supplies the complete current pricing result.
There is no receipt view before this ticket.
Use the result contract from
[design.md](../openspec/changes/shop-promotions/design.md).
Source [specification](../openspec/changes/shop-promotions/specs/shop-promotions/spec.md):
"The receipt summarizes savings compactly" and "Zero savings omit the receipt
summary". [DOMAIN.md](../DOMAIN.md) requires one compact savings line.

## ACCEPTANCE

1. A pricing result with EUR 8.50 promotion savings produces exactly one compact summary line communicating EUR 8.50.
2. A zero-savings result produces no savings summary line, including after a formerly promoted product is removed.
3. Receipt totals and savings use the same rounded pricing result as the till; a EUR 1.01 half-price pair shows total EUR 1.52 and savings EUR 0.50.
4. Receipt rendering handles `shop-promotions:priced` and clears obsolete output on `shop-promotions:pricing-error`; repeated rendering does not append duplicate summary lines or preserve stale savings.
5. The receipt contains no lengthy promotion descriptions; exact short wording may vary without changing the amount.
6. Receipt item names render as text; rendering does not recalculate or mutate the basket or result.

## VERIFY

Add the named browser test using `check.js` and the receipt view, with positive,
zero, half-cent and rerender cases. Include a live-page case proving its total
agrees with the till. From `group-4`, run:

```sh
sh app/check.sh lint
sh app/check.sh test
```

Both must exit zero and all acceptance checks must print `ok`.

## FORBIDDEN

No separate receipt pricing engine, extra per-promotion descriptions, actual
printer integration, changes to till calculation, dependencies or test weakening.

## REPORT

Follow [REPORT.md](../graph/REPORT.md). Give done/blocked, files, commands and
outputs, and unmet criteria. Report the tested number of savings summary lines
for positive and zero savings.
