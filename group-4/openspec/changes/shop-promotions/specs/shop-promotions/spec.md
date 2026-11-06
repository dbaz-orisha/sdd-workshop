# Shop promotions - specification delta

## Purpose

Enable marketing to define promotions once and have tills apply the best
eligible non-stacking offer automatically, with clear savings for customers.

## ADDED Requirements

### Requirement: Marketing defines promotions

The system SHALL allow marketing to create promotions on a page so that weekly
offers do not depend on IT maintaining a file.

#### Scenario: Marketing creates an offer

- **GIVEN** marketing has agreed an offer
- **WHEN** a marketing user creates its promotion through the page
- **THEN** the promotion is defined for use by the tills
- **AND** IT does not need to edit a promotion file to define that offer.

### Requirement: Invalid promotion definitions are rejected visibly

The system SHALL require a name, supported type, positive whole-number priority,
nonempty valid product and shop selections, and valid start and end dates with
start no later than end. Percentage discounts SHALL be greater than 0 and at
most 100. Multi-unit offers SHALL require valid grouping, discounted-unit, and
repetition settings. Invalid input SHALL show an error and SHALL NOT create or
replace a promotion.

#### Scenario: Valid promotion definition

- **GIVEN** marketing supplies all required values for a supported promotion
- **WHEN** marketing submits the definition
- **THEN** the promotion is accepted with a stable identifier.

#### Scenario: Invalid promotion definition

- **GIVEN** a definition has a missing required value, unknown selection, invalid
  setting, invalid priority, reversed date range, or percentage outside its range
- **WHEN** marketing submits that definition
- **THEN** a specific validation error is visible
- **AND** no invalid promotion is created or replaces an existing valid one.

### Requirement: Marketing defines product eligibility

The system SHALL let marketing link each promotion to its eligible products.
A product SHALL be allowed to be linked to multiple promotions; those links
SHALL NOT override the non-stacking rule.

#### Scenario: Marketing links overlapping promotions

- **WHEN** marketing links a product to two promotions
- **THEN** both promotions are candidates for that product
- **AND** the till selects the best eligible offer without stacking.

### Requirement: Marketing defines shop and date eligibility

The system SHALL let marketing define the shops and date range for each
promotion. A promotion SHALL apply only at a selected shop and within its
configured date range.

#### Scenario: Purchase at an eligible shop during the offer period

- **GIVEN** marketing has selected a shop and date range for a promotion
- **WHEN** an otherwise qualifying purchase is priced at that shop within the range
- **THEN** the promotion is eligible for automatic selection.

#### Scenario: Purchase at an unselected shop

- **WHEN** a purchase is priced at a shop not selected for a promotion
- **THEN** that promotion is not applied.

#### Scenario: Purchase outside the offer period

- **WHEN** a purchase is priced outside a promotion's configured date range
- **THEN** that promotion is not applied.

#### Scenario: Offer dates include both boundaries

- **GIVEN** a promotion runs from 2026-11-01 through 2026-11-07
- **WHEN** pricing uses the selected shop's local date
- **THEN** the promotion can apply on November 1 and November 7
- **AND** it cannot apply on October 31 or November 8.

### Requirement: Money is calculated in EUR cents

The system SHALL calculate EUR prices in cents and round each discounted unit's
final price to the nearest cent, with half-cent values rounded up. Basket
totals and savings SHALL be calculated from those rounded unit prices.

#### Scenario: A half-cent discounted price rounds up

- **GIVEN** a qualifying pair costs EUR 1.01 per unit
- **WHEN** one unit receives a half-price discount
- **THEN** that unit costs EUR 0.51
- **AND** the pair costs EUR 1.52 with savings of EUR 0.50.

#### Scenario: Repeated units use rounded unit prices

- **GIVEN** two EUR 1.01 units each receive a selected 50% percentage discount
- **WHEN** the till calculates the basket
- **THEN** each unit costs EUR 0.51
- **AND** the basket costs EUR 1.02 with savings of EUR 1.00.

### Requirement: Percentage discounts are supported

The system SHALL support promotions that reduce eligible product prices by a
marketing-defined percentage.

#### Scenario: Twenty percent off a jacket

- **GIVEN** a jacket priced at EUR 100 qualifies for a selected 20% promotion
- **WHEN** the till calculates its promoted price
- **THEN** the jacket costs EUR 80.

### Requirement: Second unit at half price is supported

The system SHALL support promotions that charge one eligible unit in a
qualifying pair at half its undiscounted price. Marketing's discounted-unit
setting SHALL determine which unit receives that discount.

#### Scenario: Two identical eligible units

- **GIVEN** two units of the same product cost EUR 10 each
- **AND** the selected promotion is second unit at half price
- **WHEN** the till calculates the pair's promoted price
- **THEN** the pair costs EUR 15.

### Requirement: Buy three pay two is supported

The system SHALL support promotions that charge for two units instead of three
in a qualifying group of three eligible units.

#### Scenario: Three identical eligible units

- **GIVEN** three units of the same product cost EUR 10 each
- **AND** the selected promotion is buy three/pay two
- **WHEN** the till calculates the group's promoted price
- **THEN** the group costs EUR 20.

### Requirement: Multi-unit grouping is promotion-wide and configurable

The system SHALL let marketing configure each supported multi-unit promotion
to require units of the same product or allow mixing any products linked to that
promotion. This SHALL apply to buy three/pay two and second-unit-half-price
offers. One grouping setting SHALL apply to all its product links.

#### Scenario: Same-product grouping prevents mixed qualification

- **GIVEN** a buy three/pay two promotion requires the same product
- **AND** a basket has one unit of each of three different linked products
- **WHEN** the till evaluates that promotion
- **THEN** those three units do not form a qualifying group.

#### Scenario: Mixed grouping permits linked products to qualify together

- **GIVEN** a buy three/pay two promotion allows mixing linked products
- **AND** a basket has one EUR 10 unit of each of three different linked products
- **AND** that promotion is selected as the best eligible deal
- **WHEN** the till calculates the group's price
- **THEN** the three units qualify together and cost EUR 20.

#### Scenario: Same-product grouping prevents a mixed pair

- **GIVEN** a second-unit-half-price promotion requires the same product
- **AND** a basket has one unit of each of two different linked products
- **WHEN** the till evaluates that promotion
- **THEN** those units do not form a qualifying pair.

### Requirement: Marketing configures the discounted unit per promotion

The system SHALL let marketing choose the cheapest or most expensive eligible
unit as free for buy three/pay two or half price for second-unit-half-price
offers. One setting SHALL apply per promotion. Best-deal selection SHALL compare
offers using their configured discounted-unit rules without overriding them.

#### Scenario: Cheapest eligible unit is configured as free

- **GIVEN** a selected buy three/pay two promotion allows mixing linked products
- **AND** its free-unit setting is cheapest
- **AND** a qualifying group contains units priced EUR 10, EUR 20, and EUR 30
- **WHEN** the till calculates the group's promoted price
- **THEN** the EUR 10 unit is free and the group costs EUR 50.

#### Scenario: Most expensive eligible unit is configured as free

- **GIVEN** a selected buy three/pay two promotion allows mixing linked products
- **AND** its free-unit setting is most expensive
- **AND** a qualifying group contains units priced EUR 10, EUR 20, and EUR 30
- **WHEN** the till calculates the group's promoted price
- **THEN** the EUR 30 unit is free and the group costs EUR 30.

#### Scenario: Cheapest unit receives the half-price discount

- **GIVEN** a selected second-unit-half-price promotion allows mixing linked products
- **AND** its discounted-unit setting is cheapest
- **AND** a qualifying pair contains units priced EUR 10 and EUR 30
- **WHEN** the till calculates the pair's promoted price
- **THEN** the EUR 10 unit costs EUR 5 and the pair costs EUR 35.

#### Scenario: Most expensive unit receives the half-price discount

- **GIVEN** a selected second-unit-half-price promotion allows mixing linked products
- **AND** its discounted-unit setting is most expensive
- **AND** a qualifying pair contains units priced EUR 10 and EUR 30
- **WHEN** the till calculates the pair's promoted price
- **THEN** the EUR 30 unit costs EUR 15 and the pair costs EUR 25.

### Requirement: Marketing configures multi-unit offer repetition

The system SHALL let marketing configure each multi-unit promotion to apply
once per basket or repeat for every qualifying group. The till SHALL respect
that setting when calculating discounts.

#### Scenario: Buy three pay two repeats for qualifying groups

- **GIVEN** six eligible units of the same product cost EUR 10 each
- **AND** the selected buy three/pay two promotion is configured to repeat
- **WHEN** the till calculates the basket price
- **THEN** two groups qualify and the basket costs EUR 40.

#### Scenario: Buy three pay two applies only once

- **GIVEN** six eligible units of the same product cost EUR 10 each
- **AND** the selected buy three/pay two promotion is configured once per basket
- **WHEN** the till calculates the basket price
- **THEN** only one group receives the offer and the basket costs EUR 50.

#### Scenario: Second unit at half price repeats for qualifying pairs

- **GIVEN** four eligible units of the same product cost EUR 10 each
- **AND** the selected second-unit-half-price promotion is configured to repeat
- **WHEN** the till calculates the basket price
- **THEN** two pairs qualify and the basket costs EUR 30.

#### Scenario: Second unit at half price applies only once

- **GIVEN** four eligible units of the same product cost EUR 10 each
- **AND** the selected second-unit-half-price promotion is configured once per basket
- **WHEN** the till calculates the basket price
- **THEN** only one pair receives the offer and the basket costs EUR 35.

### Requirement: Tills apply eligible promotions automatically

The system SHALL apply eligible promotions automatically without requiring the
cashier to remember or select an offer.

#### Scenario: A purchase qualifies for a promotion

- **GIVEN** a purchase meets an available promotion's eligibility conditions
- **WHEN** the till calculates its price
- **THEN** the eligible promotion is applied without cashier selection.

### Requirement: Promotions do not stack

The system SHALL apply no more than one promotion to a product and SHALL select
the valid, non-stacking combination of eligible promotions that yields the
lowest total basket price. Selection SHALL respect marketing's configured
grouping, free-unit, and repetition rules rather than choose independently per
product.

#### Scenario: Two percentage promotions overlap

- **GIVEN** a product priced at EUR 100 qualifies for both a 10% discount and a
  20% discount
- **WHEN** the till calculates its promoted price
- **THEN** the product costs EUR 80
- **AND** the 10% discount is not also applied.

#### Scenario: A jacket qualifies for two 20% promotions

- **GIVEN** a jacket priced at EUR 100 qualifies for two separate 20% promotions
- **WHEN** the till calculates its promoted price
- **THEN** the jacket costs EUR 80
- **AND** it does not receive a second discount.

#### Scenario: A group offer beats an isolated product discount

- **GIVEN** a basket contains one EUR 10 unit of each of three different products
- **AND** a buy three/pay two promotion allows those products to qualify together
- **AND** a competing 50% promotion applies only to the first product
- **AND** no other promotions are eligible
- **WHEN** the till selects the best non-stacking combination
- **THEN** it selects buy three/pay two and the basket costs EUR 20
- **AND** it does not select the isolated discount that would leave a EUR 25 basket
- **AND** it does not stack the 50% discount on the group offer.

### Requirement: Promotion priority resolves equal-price ties

The system SHALL let marketing define a priority for each promotion. When
valid combinations produce the same lowest basket price, the system SHALL
compare their highest promotion priorities, then their next-highest priorities
as needed. If priority comparison still ties, stable promotion identifiers
SHALL determine a consistent winner. Priority SHALL NOT override a lower
basket price.

#### Scenario: Equal discounts have different priorities

- **GIVEN** two eligible promotions both reduce a EUR 100 product to EUR 80
- **AND** marketing has assigned one a higher priority than the other
- **WHEN** the till selects the applied promotion
- **THEN** the higher-priority promotion is identified as applied
- **AND** the product costs EUR 80 without a second discount.

#### Scenario: A higher-priority offer gives a worse price

- **GIVEN** an eligible higher-priority promotion gives a price of EUR 90
- **AND** an eligible lower-priority promotion gives a price of EUR 80
- **WHEN** the till selects the applied promotion
- **THEN** the EUR 80 offer is selected.

#### Scenario: Equal-price combinations differ in their next-highest priority

- **GIVEN** two valid promotion combinations yield the same lowest basket price
- **AND** their highest promotion priorities are equal
- **AND** one combination has a higher next-highest priority
- **WHEN** the till resolves the tie
- **THEN** it selects the combination with the higher next-highest priority.

#### Scenario: Equal prices and priorities use stable identifiers

- **GIVEN** the same basket and available promotions are evaluated repeatedly
- **AND** multiple combinations tie on lowest price and priority comparison
- **WHEN** the till selects a combination
- **THEN** stable promotion identifiers resolve the tie consistently
- **AND** the same combination is selected on each evaluation.

#### Scenario: One priority sequence has additional entries

- **GIVEN** equal-price combinations share the same highest priorities
- **AND** one has another configured positive priority while the other has no entry
- **WHEN** the till compares the next priorities
- **THEN** the configured priority outranks the missing entry.

### Requirement: Current promotion definitions are used on recalculation

The system SHALL evaluate the current valid promotion definitions on the next
basket calculation after marketing creates or changes a promotion, applying
the selected shop and inclusive local-date eligibility rules.

#### Scenario: A changed promotion is evaluated on the next calculation

- **GIVEN** a EUR 100 product currently qualifies for a 10% promotion
- **WHEN** marketing changes that promotion to 20%
- **AND** the till next calculates the qualifying basket
- **THEN** the product costs EUR 80 rather than EUR 90.

### Requirement: Basket changes recalculate discounts

The system SHALL recalculate promotion eligibility, selected discounts, prices,
and savings when basket quantities change or products are removed.

#### Scenario: Quantity drops below the qualifying threshold

- **GIVEN** two identical EUR 10 units cost EUR 15 with second unit at half price
- **AND** no other promotion is eligible
- **WHEN** the cashier reduces the quantity to one
- **THEN** the remaining unit costs EUR 10
- **AND** savings from the pair promotion are removed.

#### Scenario: A promoted product is removed

- **GIVEN** a basket includes a promoted product
- **WHEN** the cashier removes that product
- **THEN** discounts and savings are recalculated for the remaining basket
- **AND** savings from the removed product are not retained.

### Requirement: The cashier can identify the applied promotion

The system SHALL show the cashier which promotion was applied so that the
cashier can explain the price to the customer.

#### Scenario: The cashier checks a promoted purchase

- **GIVEN** the till has applied a promotion
- **WHEN** the cashier reviews the purchase
- **THEN** the cashier can identify the promotion that was applied.

### Requirement: The receipt summarizes savings compactly

The system SHALL show the customer's promotion savings in one compact summary
line rather than lengthy promotion descriptions.

#### Scenario: A customer saves EUR 8.50

- **GIVEN** the customer's promotion savings total EUR 8.50
- **WHEN** the receipt is produced
- **THEN** one compact summary line communicates the EUR 8.50 savings
- **AND** lengthy promotion descriptions are not added.

### Requirement: Zero savings omit the receipt summary

The system SHALL omit the promotion savings summary when the customer's
promotion savings total is zero.

#### Scenario: No promotion savings

- **GIVEN** the customer's promotion savings total is EUR 0
- **WHEN** the receipt is produced
- **THEN** no promotion savings summary line is printed.
