//
//  InstrumentView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

struct InstrumentView: View {
    
    var title: String
    @Binding var value: String
    
    var body: some View {
        VStack {
            Text(title).bold()
            Text(value).bold()
        }
        .frame(width: 100, height: 40, alignment: .center)
        .background(Color.white.opacity(0.5))
        .cornerRadius(5)
    }
}

struct InstrumentView_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentView(title: "Speed", value: .constant("44"))
            .previewLayout(.fixed(width: 100, height: 50))
    }
}
