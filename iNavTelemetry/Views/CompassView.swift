//
//  CompassView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI

struct CompassView: View {
    
    @Binding var heading: Double
    
    var body: some View {
        ZStack {
            Image("compass")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Image("compass_plane")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .rotationEffect(Angle(degrees: heading))
        }.frame(width: 120, height: 120, alignment: .center)
    }
}

struct CompassView_Previews: PreviewProvider {
    static var previews: some View {
        CompassView(heading: .constant(0))
            .previewLayout(.fixed(width: 120, height: 120))
    }
}
