//
//  CompassView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

struct CompassView: View {
    
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Image("compass")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Image("compass_plane")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .rotationEffect(Angle(degrees: Double(viewModel.telemetry.packet.heading)))
        }.frame(width: 120, height: 120, alignment: .center)
    }
}

struct CompassView_Previews: PreviewProvider {
    static var previews: some View {
        CompassView(viewModel: .init())
            .previewLayout(.fixed(width: 120, height: 120))
    }
}
