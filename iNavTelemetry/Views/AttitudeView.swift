//
//  AttitudeView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

struct AttitudeView: View {
    
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Image("horizon")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Image("horizon_line")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .offset(y:CGFloat(viewModel.telemetry.packet.pitch))
            Image("horizon_plane")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .rotationEffect(Angle(degrees: Double(viewModel.telemetry.packet.roll)))
        }.frame(width: 120, height: 120, alignment: .center)
    }
}

struct AttitudeView_Previews: PreviewProvider {
    static var previews: some View {
        AttitudeView(viewModel: .init())
            .previewLayout(.fixed(width: 120, height: 120))
    }
}
