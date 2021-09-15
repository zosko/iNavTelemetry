//
//  InsrumentView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

struct InstrumentView: View {
    
    var title: String
    var value: String
    
    var body: some View {
        VStack {
            Text(title).bold()
            Text(value).bold()
        }
    }
}

struct InsrumentView_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentView(title: "Speed", value: "44").previewLayout(.fixed(width: 100, height: 50))
    }
}
