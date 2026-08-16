//
//  Money.swift
//  ROME
//
//  Currency formatting.
//
//  The app's interface is English and prices are in US dollars, so formatting
//  is pinned to `en_US`. Left to the device locale, a Chinese or British
//  system renders the same amount as "US$10.50" — correct for that locale, but
//  wrong beside English copy.
//

import Foundation

extension Decimal {

    /// "$10.50"
    var formattedPrice: String {
        formatted(.currency(code: "USD").locale(Locale(identifier: "en_US")))
    }
}
