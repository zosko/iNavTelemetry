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
                    InstrumentView(type: .latitude, value: .constant("~"))
                    InstrumentView(type: .longitude, value: .constant("~"))
                    InstrumentView(type: .satelittes, value: .constant("~"))
                    InstrumentView(type: .distance, value: .constant("~"))
                    InstrumentView(type: .altitude, value: .constant("~"))
                    InstrumentView(type: .speed, value: .constant("~"))
                    Spacer()
                }
                Spacer()
                VStack(spacing: 1) {
                    InstrumentView(type: .armed, value: .constant("~"))
                    InstrumentView(type: .signal, value: .constant("~"))
                    InstrumentView(type: .fuel, value: .constant("~"))
                    InstrumentView(type: .flymode, value: .constant("~"))
                    InstrumentView(type: .flytime, value: .constant("~"))
                    Spacer()
                }
            }
            VStack {
                Spacer()
                HStack(alignment: .bottom ,spacing: 1) {
                    InstrumentView(type: .current, value: .constant("~"))
                    InstrumentView(type: .voltage, value: .constant("~"))
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
