//
//  Logbook.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

struct Logbook: View {
    
    var log: URL
    @Binding var screen: Screen
    
    var body: some View {
        return ZStack(alignment: .topLeading)  {
            MapView()
            Button(action: {
                screen = .dashboard
            }){
                Image("back")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }.frame(width: 50, height: 50)
        }
    }
}

struct Logbook_Previews: PreviewProvider {
    static var previews: some View {
        Logbook(log: URL(string: "")! , screen: .constant(.dashboard))
    }
}
