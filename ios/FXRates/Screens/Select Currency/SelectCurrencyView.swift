//
//  SelectCurrencyView.swift
//  FXRates
//
//  Created by Eric Sean Turner on 1/5/21.
//

import SwiftUI
import Combine

struct SelectCurrencyView: View {
        
    @ObservedObject var viewModel = SelectCurrencyViewModel()
    
    @State var amountEUR = ""
    @State var amountEntered = false
    
    var body: some View {
        
        VStack {
            
            Spacer()
            
            HStack {
                
                Spacer()
                
                Text("€")
                    .font(Font.system(size: 30, design: .default))
                    .foregroundColor(Color.black.opacity(0.40))

                TextField("Enter amount", text: $amountEUR)
                    .simultaneousGesture(TapGesture().onEnded {
                        self.amountEntered = false
                    })
                    .multilineTextAlignment(.center)
                    .frame(height: 55)
                    .frame(width: 125)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(Font.system(size: 20, design: .default))
                    .foregroundColor(Color.black.opacity(0.75))
                    .padding([.leading, .trailing], 10)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.25)))
                    .keyboardType(.decimalPad)
                    .onReceive(Just(amountEUR)) { newValue in
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        if filtered != newValue {
                            self.amountEUR = filtered
                        }
                    }
                
                if amountEUR.isEmpty == false {
                    SmoothButton(text:"Convert", handler: {
                        amountEntered = true
                        self.hideKeyboard()
                    })
                }
                
                Spacer()
            }
                
            
            
                
            if amountEntered == true {

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
