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
        
        DatabaseService.shared.listenForCurrencies(){
            [weak self] (currencies, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let currencies = currencies {
                self?.didUpdateCurrencies(currencies: currencies)
            }
        }
        
    }
    
    func didUpdateCurrencies(currencies: [Currency]){
        self.currencies = currencies
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
