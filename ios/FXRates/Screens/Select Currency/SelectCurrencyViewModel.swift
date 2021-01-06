//
//  SelectCurrencyViewModel.swift
//  FXRates
//
//  Created by Eric Sean Turner on 1/5/21.
//

import Foundation

class SelectCurrencyViewModel : ObservableObject {
    @Published var currencies : [Currency] = []
    var selectedCurrencyIDs = Queue(items: [])
    
    init(){
        
        let c1 = Currency(symbol: "USD", rateEUR: 123.00, date: Date())
        let c2 = Currency(symbol: "GBP", rateEUR: 123.00, date: Date())
        let c3 = Currency(symbol: "JPY", rateEUR: 123.00, date: Date())
        let c4 = Currency(symbol: "CAD", rateEUR: 123.00, date: Date())
        let c5 = Currency(symbol: "AUD", rateEUR: 123.00, date: Date())
        
        currencies.append(c1)
        currencies.append(c2)
        currencies.append(c3)
        currencies.append(c4)
        currencies.append(c5)
        
    }
    
    func selectedCurrencyCount() -> Int {
        return selectedCurrencyIDs.items.count
    }
    
    func isCurrencySelected(_ currency: Currency) -> Bool {
        return selectedCurrencyIDs.items.contains(currency.symbol)
    }
    
    func addSelectedCurrency(_ currency: Currency){
        if selectedCurrencyIDs.items.contains(currency.symbol) == false {
            selectedCurrencyIDs.enqueue(element: currency.symbol)
            if selectedCurrencyIDs.items.count > 2 {
                _ = selectedCurrencyIDs.dequeue()
            }
        } else {
            selectedCurrencyIDs.items.removeAll { $0 == currency.symbol }
        }
        self.objectWillChange.send()
    }
    
    struct Queue{
        var items:[String] = []
        mutating func enqueue(element: String)
        {
            items.append(element)
        }
        mutating func dequeue() -> String?
        {
            if items.isEmpty {
                return nil
            }
            else{
                let tempElement = items.first
                items.remove(at: 0)
                return tempElement
            }
        }
    }
}
