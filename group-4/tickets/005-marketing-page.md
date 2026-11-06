# 005 - Marketing creates and edits promotions

## GOAL

Let marketing define valid offers and control products, shops, dates, priority,
grouping, discounted units and repetition without IT editing a file.

## SCOPE

Create `app/marketing.js` and `app/test/marketing-page.test.html`.
Edit `app/index.html` and, if needed, create or edit `app/style.css`.
Do not edit earlier calculation scripts, helpers, runner or graph.

## CONTEXT

Requires ticket 002; this form does not depend on the completed pricing engine.
The starting page lacks a marketing workflow.
Use the record contract and validation from
[design.md](../openspec/changes/shop-promotions/design.md).
Source [specification](../openspec/changes/shop-promotions/specs/shop-promotions/spec.md):
"Marketing defines promotions", invalid-definition rejection, product/shop/date
eligibility and all marketing-configurable options.
[DOMAIN.md](../DOMAIN.md) assigns promotion creation to marketing.

## ACCEPTANCE

1. A marketing user can create and review a named promotion of each of the three supported types through the actual page.
2. The form permits multiple product and shop selections, inclusive dates and a positive whole-number priority; selected values are retained in the definition.
3. Both multi-unit types expose same-product/mixed grouping, cheapest/most-expensive discounted-unit choice and once/repeat settings.
4. Percentage offers accept a finite percentage greater than zero and at most 100, including fractional values.
5. Missing required values, invalid selections, settings, dates, percentage or priority produce specific visible errors; no invalid record is created.
6. Editing a valid promotion preserves its stable ID; an invalid edit shows an error and leaves the previous valid definition unchanged; `marketing.getDefinitions()` exposes the current valid definitions for the till.
7. Products may link to multiple promotions, but the form does not claim those offers stack.
8. Controls have associated labels; keyboard form submission works; promotion names and errors render as text, not executable markup.
9. The existing page title remains nonempty; all scripts/styles are local and earlier tests remain green.

## VERIFY

Add the named browser test loading the real page in a local iframe and testing
the actual form controls and visible errors. Use `check.js`; assert every
acceptance number, not just the underlying validation helper.
From `group-4`, run:

```sh
sh app/check.sh lint
sh app/check.sh test
```

Both must exit zero with complete `ok` output and no `FAIL`.

## FORBIDDEN

No pricing logic in the form, cashier promotion selection, additional offer
types, required IT files, new dependencies, remote assets, changing test
infrastructure or weakening tests.

## REPORT

Follow [REPORT.md](../graph/REPORT.md): done/blocked, changed files, exact
verification commands and outputs, and any missing behavior. Explicitly state
that browser tests exercised the form and invalid-edit preservation.
