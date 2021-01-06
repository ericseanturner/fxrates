//
//  SelectCurrencyView.swift
//  FXRates
//
//  Created by Eric Sean Turner on 1/5/21.
//

import SwiftUI

struct SelectCurrencyView: View {
        
    @ObservedObject var viewModel = SelectCurrencyViewModel()
    
    @State var amountEUR : Double?
    
    var body: some View {
        VStack {
            
            List(viewModel.currencies) { currency in
                
                Button(action: {
                    viewModel.addSelectedCurrency(currency)
                }){
                    CurrencyCell(currency, isSelected: viewModel.isCurrencySelected(currency))
                }
            }
            .listStyle(PlainListStyle())
            
            if viewModel.selectedCurrencyCount() == 1 {
                SmoothButton(text: "View Currency", handler: {  })
            } else if viewModel.selectedCurrencyCount() == 2 {
                SmoothButton(text: "Compare Currencies", handler: {  })
            }
            
            Spacer()
        }
    }
}

struct SelectCurrencyView_Previews: PreviewProvider {
    static var previews: some View {
        SelectCurrencyView()
    }
}
