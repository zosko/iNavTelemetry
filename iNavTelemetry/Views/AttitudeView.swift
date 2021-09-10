//
//  AttitudeView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

struct AttitudeView: View {
    
    @Binding var roll: Double
    @Binding var pitch: CGFloat
    
    var body: some View {
        ZStack {
            Image("horizon")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Image("horizon_line")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .offset(y:pitch)
            Image("horizon_plane")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .rotationEffect(Angle(degrees: roll))
        }.frame(width: 120, height: 120, alignment: .center)
    }
}

struct AttitudeView_Previews: PreviewProvider {
    static var previews: some View {
        AttitudeView(roll: .constant(0), pitch: .constant(0))
            .previewLayout(.fixed(width: 120, height: 120))
    }
}
