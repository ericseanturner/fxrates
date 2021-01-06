//
//  Currency.swift
//  FXRates
//
//  Created by Eric Sean Turner on 1/5/21.
//

import Foundation

struct Currency : Identifiable, Hashable {
    let id = UUID()
    let symbol : String
    let rateEUR: Double
    let date : Date
}
