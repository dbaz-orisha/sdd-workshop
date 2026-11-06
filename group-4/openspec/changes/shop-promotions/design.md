# Design

## Context

See [proposal.md](proposal.md) for the motivation and
[the specification](specs/shop-promotions/spec.md) for business rules.
The existing app is a titled HTML page with a heading, not a working promotion
system. Its tests use `app/test/check.js` and the existing shell runner.

The app runs in a browser and nowhere else: HTML, CSS and JavaScript exactly as a browser loads them. No Node, no npm, no modules (`import`, `export`, `require`), no build step, no dependency.

## Goals / Non-Goals

**Goals:** Build a small, testable pricing engine and connect it to marketing,
till, and receipt views. Preserve the existing page title and test helper.

**Non-Goals:** Additional promotion types, catalog maintenance, cashier-selected
promotions, tax calculation, actual printer integration, or changing the graph.

## Decisions

### Small browser scripts with one namespace

Use ordinary local script tags and `window.ShopPromotions` as the shared
namespace. Keep calculation separate from DOM interaction:

| File | Responsibility | First ticket |
| --- | --- | --- |
| `app/money.js` | EUR cent arithmetic and percentage pricing | 001 |
| `app/promotions.js` | Definitions, validation, catalog/shop references, eligibility | 002 |
| `app/offers.js` | Valid multi-unit and percentage applications | 003 |
| `app/pricing.js` | Best basket price and deterministic selection | 004 |
| `app/marketing.js` | Marketing definition form and visible validation | 005 |
| `app/till.js` | Basket controls, recalculation, cashier explanation | 006 |
| `app/receipt.js` | Receipt view and compact savings summary | 007 |

This is simpler than a framework and lets browser tests exercise the pricing
rules without constructing the whole UI. One large script would couple pricing
changes to every view; separate scripts give tickets precise write boundaries.

### Explicit shared inputs and outputs

Use ordinary JavaScript records:

- Product: stable `id`, display `name`, nonnegative integer `priceCents`.
- Shop: stable `id`, display `name`, local-date context.
- Promotion: stable `id`, `name`, `type` (`percentage`, `second-half`,
  `three-for-two`), `productIds`, `shopIds`, inclusive `startDate` and `endDate`
  in `YYYY-MM-DD`, positive integer `priority`, and `percentage` for percentages.
  Multi-unit records have `grouping` (`same-product` or `mixed`),
  `discountedUnit` (`cheapest` or `most-expensive`) and `repetition`
  (`once` or `repeat`).
- Basket: product IDs and nonnegative integer quantities. Zero quantity removes
  a product. Invalid records or arithmetic outside safe integer ranges produce
  explicit errors, not an undiscounted success-shaped result.
- Calculation context: selected `shopId` and that shop's local `shopDate`.
  Tests supply explicit dates so results do not depend on when tests run.
- Result: original and final totals in cents, savings in cents, selected
  promotion IDs, and per-product unit prices and applied-promotion metadata.
  All views consume this same result rather than calculating their own totals.

Fixtures may use illustrative products such as a EUR 100 jacket and EUR 10,
EUR 20, and EUR 30 items. They demonstrate the client's rules, not a restriction
on the products marketing may link. Represent Brisa's nine shops with distinct
IDs; test selections and date eligibility rather than hard-coding a particular
offer to all shops.

Internal entry points live under the shared namespace:

- `money.discountedUnitPrice(priceCents, percentage)` returns the rounded final
  unit price, never a rounded discount deducted afterward.
- `promotions.validate(record, products, shops)` validates a complete definition;
  invalid input throws an explicit error the marketing view displays.
- `promotions.isEligible(record, productId, shopId, shopDate)` evaluates valid
  definitions against explicit context.
- `offers.candidates(basket, definitions, products, context)` enumerates valid
  applications and their participating units and product claims.
- `pricing.calculate(basket, definitions, products, shops, context)` returns
  the complete result without mutating its inputs.

These contracts are documented here so later workers reuse earlier work.
DOM controllers may choose their own small helpers inside their allowed files.
For cross-view wiring, marketing exposes `marketing.getDefinitions()`, returning
the current valid definitions. The till exposes `till.currentResult` and emits
`shop-promotions:priced` with the complete result in `event.detail` after each
successful calculation. On failure it clears that result and emits
`shop-promotions:pricing-error`; receipt rendering listens to those events and
clears obsolete output on error. This contract lets ticket 007 connect the
receipt without editing the till script owned by ticket 006.

### Exact money and exact best-deal selection

Represent prices as integer cents. Percentage and half-price arithmetic round
the final discounted unit price half up; sum rounded unit prices afterward.
Validate numerical input explicitly and preserve fractional percentages rather
than silently rounding the configured percentage to a whole number.

Generate all relevant qualifying group choices, not only the first group in
basket order. Compare valid non-stacking combinations, including the unchanged
basket, to find the lowest total. Every unit participating in a group, including
the full-price units, counts toward that offer; units cannot be reused.
Different promotions cannot claim the same product, preserving the original
product-level non-stacking rule. Repeated groups of the same configured promotion
are allowed only when repetition is enabled.

Compare equal-price results using priorities of distinct selected promotions,
sorted descending. Missing entries rank below positive priorities. Resolve a
remaining tie using sorted stable promotion IDs in ascending text order, with
a fixed unit ordering for equivalent group allocations. Thus array insertion
order cannot change the selected promotion combination.

A greedy product-by-product approach is rejected because it can miss a cheaper
multi-unit basket. Enumeration is appropriate for this small exercise; prune
only when correctness is preserved, never silently cap candidate search.

### One calculation path for every view

Marketing creates or edits valid definitions with stable IDs. The till uses the
current definitions on the next calculation, after quantity, product, shop, or
local-date changes. Cashier explanation and the receipt use the same result.
Invalid definition edits leave the prior valid definition unchanged and show a
specific error.

The marketing form exposes all approved options for both multi-unit types.
The cashier manages the basket, not promotion selection. Receipt presentation
uses one summary line when savings are positive and none when zero. Preserve the
existing HTML title; put styles in `app/style.css` if needed.

### Tests land with each ticket

Each implementation ticket adds its named `app/test/*.test.html`, loads local
scripts and `check.js`, and calls `check` or `checkThrows` for every numbered
acceptance line. UI tests exercise real DOM controls, not only calculation
helpers. The last ticket checks the complete journey and interaction between
already tested parts.

From `group-4`, verification uses `sh app/check.sh lint` and
`sh app/check.sh test`. The runner has no per-page selector, so each ticket's
verification runs all accumulated app tests.

## Risks / Trade-offs

- Candidate combinations grow with basket size -> keep pure logic testable and
  use correctness-preserving pruning; do not change business rules or add
  undisclosed size limits.
- Discounting group members twice produces apparently attractive but invalid
  totals -> test unit consumption and product-level claims.
- Rounding discounts instead of final prices changes half-cent outcomes ->
  test EUR 1.01 half-price and repeated-unit examples.
- Eligibility or UI results become stale -> use one calculation path with
  explicit shop/date context and test edits, removals, and eligibility changes.

## Migration Plan

Tickets add behavior incrementally, preserving existing title checks. Run the
app checks after each ticket. The normal workshop review and delivery flow
handles accepted tickets; this planning change does not start implementation.
If a ticket fails, fix or block that ticket rather than weakening earlier tests.
