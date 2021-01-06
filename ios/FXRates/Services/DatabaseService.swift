//
//  DatabaseService.swift
//  FXRates
//
//  Created by Eric Sean Turner on 1/5/21.
//

import Foundation
import Firebase
import Combine

enum DBServiceError : Error {
    case GeneralError
}

class DatabaseService {
    
    static let shared = DatabaseService()
    
    let db = Firestore.firestore()
    
    var currenciesListener : ListenerRegistration?
        
    func listenForCurrencies(completion: @escaping ([Currency]?, Error?)->()){
        self.currenciesListener = db.collection("currencies")
            .addSnapshotListener { querySnapshot, err in
            if let err = err {
                print("Error getting currencies: \(err)")
                completion(nil, DBServiceError.GeneralError)
            } else if let querySnapshot = querySnapshot {
                var currencies : [Currency] = []
                for document in querySnapshot.documents {
                    if document.exists {
                        let fields = document.data()
                        if let symbol = fields["symbol"] as? String,
                           let rateEUR = fields["lastQuoteEUR"] as? Double,
                           let timestamp = fields["lastQuoteAt"] as? Timestamp {
                            let currency = Currency(symbol: symbol,
                                                    rateEUR: rateEUR,
                                                    date: timestamp.dateValue())
                            currencies.append(currency)
                        }
                    }
                }
                completion(currencies, nil)
            } else {
                completion(nil, DBServiceError.GeneralError)
            }
        }
    }
}
