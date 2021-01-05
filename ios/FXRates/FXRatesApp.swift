//
//  FXRatesApp.swift
//  FXRates
//
//  Created by Eric Sean Turner on 1/5/21.
//

import SwiftUI
import Firebase

@main
struct FXRatesApp: App {
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
