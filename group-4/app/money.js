(function () {
  "use strict";

  var root = window.ShopPromotions = window.ShopPromotions || {};

  function validatePriceCents(priceCents) {
    if (!Number.isSafeInteger(priceCents) || priceCents < 0) {
      throw new Error("priceCents must be a nonnegative safe integer");
    }
  }

  function validatePercentage(percentage) {
    if (typeof percentage !== "number" || !Number.isFinite(percentage) ||
        percentage <= 0 || percentage > 100) {
      throw new Error("percentage must be finite, greater than 0, and at most 100");
    }
  }

  function percentageFraction(percentage) {
    var match = String(percentage).match(/^(\d+)(?:\.(\d+))?(?:e([+-]?\d+))?$/i);
    var digits;
    var scale;

    if (!match) {
      throw new Error("percentage must be a decimal number");
    }

    digits = match[1] + (match[2] || "");
    scale = (match[2] || "").length - Number(match[3] || 0);
    if (scale < 0) {
      digits += "0".repeat(-scale);
      scale = 0;
    }

    return {
      numerator: BigInt(digits),
      denominator: 10n ** BigInt(scale)
    };
  }

  function discountedUnitPrice(priceCents, percentage) {
    var discount;
    var remainingNumerator;
    var denominator;
    var finalCents;

    validatePriceCents(priceCents);
    validatePercentage(percentage);
    discount = percentageFraction(percentage);
    remainingNumerator = 100n * discount.denominator - discount.numerator;
    denominator = 100n * discount.denominator;
    finalCents = (BigInt(priceCents) * remainingNumerator + denominator / 2n) / denominator;

    if (finalCents > BigInt(Number.MAX_SAFE_INTEGER)) {
      throw new Error("discounted price exceeds the safe integer range");
    }

    return Number(finalCents);
  }

  root.money = {
    discountedUnitPrice: discountedUnitPrice
  };
}());
