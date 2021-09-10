//
//  Logbook.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

struct Logbook: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
        ZStack(alignment: .topLeading)  {
            MapView()
            Button(action: {
                viewRouter.currentPage = .dashboard
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
        Logbook()
    }
}
