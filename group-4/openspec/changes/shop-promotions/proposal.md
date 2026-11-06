# Proposal

## Why

Brisa's manually applied weekly promotions produced incorrect charges in one
promoted basket out of eight, costing approximately EUR 3,100 in one audited
month. Marketing needs to define offers once and have every till apply them
reliably before Black Friday.

## What Changes

- Marketing creates promotions on a page instead of relying on IT-maintained
  files.
- Support percentage discounts, second unit at half price, and buy three/pay two.
- Marketing configures multi-unit grouping once per promotion: same
  product only, or any mix of products linked to that promotion.
- Marketing chooses the cheapest or most expensive eligible unit as free for
  buy three/pay two or half price for second-unit-half-price offers, once per
  promotion.
- Marketing configures each multi-unit promotion to apply once per basket or
  repeat for every qualifying group.
- Marketing links promotions to eligible products and defines their shops,
  date range, and priority. Products can be linked to multiple promotions.
- Tills apply eligible promotions automatically.
- Overlapping promotions do not stack on a product; the customer receives the
  valid promotion combination yielding the lowest total basket price, with
  highest priority breaking equal-price ties.
- Discounts are recalculated when basket quantities or contents change.
- Cashiers can identify the applied promotion.
- Receipts communicate total promotion savings in one compact summary line,
  without lengthy promotion descriptions, and omit it when savings are zero.

This proposal reflects the decisions in [DOMAIN.md](../../../DOMAIN.md).
Group-4 has decided the supported types, product links, best-deal selection,
priority for ties, recalculation, zero-savings omission, and marketing-defined
shops and date ranges. Final validation, rounding, dates, and priority rules
have also been approved. The
[specification draft](specs/shop-promotions/spec.md) captures the agreed behavior.
This is a planning change; implementation requires a separately assigned ticket.

## Capabilities

### New Capabilities

- `shop-promotions`: Defines marketing-managed offers and their automatic,
  non-stacking application at the till, including cashier visibility and receipt
  savings.

### Modified Capabilities

None. The existing `home-page` capability is not changed by this proposal.

## Impact

- Marketing's offer-definition workflow and the cashier's pricing workflow.
- Group-4's web app and browser-based acceptance tests when implementation is
  separately authorized.
- Receipt savings presentation.

No external APIs, new dependencies, production deployment mechanism, or changes
to other groups are prescribed by this proposal.

## Scope and review boundary

The client is Brisa, nine sportswear shops whose marketing team sends weekly
offers to cashiers in a PDF. The agreed scope is the behaviors listed under
What Changes.

Excluded from this approach:

- IT-maintained files as the promotion-creation workflow.
- Cashier selection as the normal way to apply promotions.
- Stacking multiple promotions on the same product.
- Lengthy promotion descriptions on the receipt.

The first version supports all three promotion types from the client brief.
Best-deal selection takes precedence over priority; priority breaks ties in
customer price. Best-deal selection respects each promotion's configured
discounted-unit rule rather than overriding it. Grouping and discounted-unit
settings are agreed for both supported multi-unit types. Repetition is configurable per multi-unit
promotion. Overlapping offers are optimized for the lowest total basket price,
not independent product-level choices.
Equal-price combinations are compared by highest promotion priority, then
next-highest priorities as needed. Stable promotion identifiers resolve any
remaining tie consistently; priority never overrides a lower basket price.
The exact receipt wording is not prescribed; "You saved EUR 8.50" is an
illustration.

Status: Functional rules agreed; generated backlog awaits group review and
sign-off. No additional promotion types or production rollout guarantees are
part of this exercise.

## Final agreed rules

- Priorities are positive whole numbers, compared highest-first. Missing
  sequence entries rank below configured values; stable identifiers break
  remaining ties. Price minimization always comes first.
- Definitions require a name, supported type, valid product/shop selections,
  valid priority and date range, and the applicable multi-unit settings.
  Percentage discounts must be greater than 0 and at most 100. Invalid input
  produces a visible error and does not create or replace a promotion.
- Start and end dates are inclusive, using the selected shop's local date.
- Monetary calculation uses EUR cents and half-up rounding of each discounted
  unit's final price; totals and savings use the rounded prices.
- New or changed valid definitions are evaluated on the next basket calculation.

## Open questions

None blocking the workshop backlog. The group reviews ticket scope and
acceptance numbers before signing off the backlog.
