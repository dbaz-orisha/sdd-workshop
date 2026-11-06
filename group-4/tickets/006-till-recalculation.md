# 006 - Automatic till pricing and recalculation

## GOAL

Let cashiers build a basket and see automatically calculated prices and applied
promotions, with no stale discounts after basket or eligibility changes.

## SCOPE

Create `app/till.js` and `app/test/till-recalculation.test.html`.
Edit `app/index.html` and, if needed, `app/style.css`.
Do not edit calculation or marketing scripts, helpers, runner or graph.

## CONTEXT

Requires tickets 004 and 005: a complete selector and marketing definitions on
the page. There is no working till view before this ticket.
Use the single result contract in
[design.md](../openspec/changes/shop-promotions/design.md).
Source [specification](../openspec/changes/shop-promotions/specs/shop-promotions/spec.md):
automatic application, basket recalculation, current definitions on the next
calculation, and cashier identification of applied offers.
[DOMAIN.md](../DOMAIN.md) rejects manual promotion selection.

## ACCEPTANCE

1. The cashier can add a catalog product, change quantity and remove a product; current eligible offers apply without a promotion picker.
2. The till displays the selected shop/local-date context, original and final basket totals, and the applied promotion for each participating product.
3. Two EUR 10 units under second-half cost EUR 15; reducing to one recalculates to EUR 10 with no pair savings.
4. Removing a promoted product removes its prices and savings from the remaining basket; removing the last product leaves a zero total.
5. An offer not linked to the product, shop or date is not applied; changing shop or local date recalculates eligibility including both date boundaries.
6. After marketing changes an eligible EUR 100 product's promotion from 10% to 20%, the next basket calculation shows EUR 80 rather than EUR 90.
7. The view uses the shared selector result, exposes `till.currentResult`, and emits `shop-promotions:priced` with that result; it reflects the globally best non-stacking total without separate UI discounts.
8. Invalid quantities or calculation errors are visible; the view clears its current result and emits `shop-promotions:pricing-error`, never displaying stale totals as a successful new calculation.
9. Product and promotion names are rendered as text; basket controls have labels and remain operable by keyboard.

## VERIFY

Add the named browser test loading the real page, creating valid promotions
through marketing controls and changing the actual till controls.
Use `check.js` and assert the visible prices, promotion identity and errors.
From `group-4`, run:

```sh
sh app/check.sh lint
sh app/check.sh test
```

Both must exit zero; all acceptance checks print `ok`, with no `FAIL`.

## FORBIDDEN

No promotion picker, duplicated selector logic, silent errors, receipt layout
work, additional dependencies, script edits outside SCOPE or weakened tests.
Do not hide an error behind an undiscounted or stale result.

## REPORT

Follow [REPORT.md](../graph/REPORT.md): done/blocked, changed files, commands
and outputs, and unmet criteria. Include proof of quantity reduction, removal,
shop/date changes and definition edits.
