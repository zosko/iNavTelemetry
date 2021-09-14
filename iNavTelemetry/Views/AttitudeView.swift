//
//  AttitudeView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

struct AttitudeView: View {
    
    var roll: Int
    var pitch: Int
    
    var body: some View {
        ZStack {
            Image("horizon")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Image("horizon_line")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .offset(y:CGFloat(pitch))
            Image("horizon_plane")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .rotationEffect(Angle(degrees: Double(roll)))
        }.frame(width: 120, height: 120, alignment: .center)
    }
}

struct AttitudeView_Previews: PreviewProvider {
    static var previews: some View {
        AttitudeView(roll: 0, pitch: 0)
            .previewLayout(.fixed(width: 120, height: 120))
    }
}
