//
//  DisplayView.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI
import Combine

struct DisplayView: View {
    
    var body: some View {
        ZStack {
            HStack {
                VStack(spacing: 1) {
                    InstrumentView(title: "Latitude", value: .constant("~"))
                    InstrumentView(title: "Longitude", value: .constant("~"))
                    InstrumentView(title: "Satellites", value: .constant("~"))
                    InstrumentView(title: "Distance", value: .constant("~"))
                    InstrumentView(title: "Altitude", value: .constant("~"))
                    InstrumentView(title: "Speed", value: .constant("~"))
                    Spacer()
                }
                Spacer()
                VStack(spacing: 1) {
                    InstrumentView(title: "Armed", value: .constant("~"))
                    InstrumentView(title: "SIgnal", value: .constant("~"))
                    InstrumentView(title: "Fuel", value: .constant("~"))
                    InstrumentView(title: "Flymode", value: .constant("~"))
                    InstrumentView(title: "Fly time", value: .constant("~"))
                    Spacer()
                }
            }
            VStack {
                Spacer()
                HStack(alignment: .bottom ,spacing: 1) {
                    InstrumentView(title: "Current", value: .constant("~"))
                    InstrumentView(title: "Voltage", value: .constant("~"))
                    Spacer()
                    ConnectionView()
                    CompassView(heading: .constant(0))
                    AttitudeView(roll: .constant(0), pitch: .constant(0))
                }
            }
        }
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView()
            .background(Color.black)
            .previewLayout(.fixed(width: 812, height: 375))
            .environment(\.horizontalSizeClass, .compact)
            .environment(\.verticalSizeClass, .compact)
    }
}
