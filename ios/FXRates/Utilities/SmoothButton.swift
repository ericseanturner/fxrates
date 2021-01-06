//
//  SmoothButton.swift
//  FXRates
//
//  Created by Eric Sean Turner on 1/5/21.
//

import SwiftUI

struct SmoothButton: View {
    
    let text : String
    let handler : ()->()
    
    var body: some View {
        Button(action: { self.handler() },
               label:{ Text(self.text) })
            .buttonStyle(NeumorphicButtonStyle(bgColor: .neuBackground))
    }
}
