//
//  CurrencyCell.swift
//  FXRates
//
//  Created by Eric Sean Turner on 1/5/21.
//

import SwiftUI

struct CurrencyCell: View {
    
    //@EnvironmentObject var viewModel : SelectCurrencyViewModel
    
    let currency : Currency
    let color : Color
        
    init(_ currency: Currency, isSelected: Bool){
        self.currency = currency
        if isSelected {
            self.color = Color.gray.opacity(0.2)
        } else {
            self.color = Color.white
        }
    }
    
    var body: some View {
        HStack {
            
            Text(currency.symbol)
                .padding(10)
            Spacer()
            Text("\(String(currency.rateEUR))")
                .padding(10)
            
        }
        .background(self.color)
        .padding(10)
    }
}

struct CurrencyCell_Previews: PreviewProvider {
    static let currency : Currency = Currency(symbol: "USD", rateEUR: 123.00, date: Date())
    static var previews: some View {
        CurrencyCell(currency, isSelected: false)
    }
}
