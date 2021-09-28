//
//  Logbook.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/5/21.
//

import SwiftUI
import MapKit

struct Logbook: View {
    
    @Binding var logBookCoordinates: [TelemetryManager.LogTelemetry]?
    
    private var coordinates: [CLLocationCoordinate2D] {
        guard let logBook = logBookCoordinates else { return [] }
        return logBook.map{ $0.location }
    }
    
    var body: some View {
        return ZStack(alignment: .topLeading)  {
            MapViewLines(coordinates: coordinates)
//              .edgesIgnoringSafeArea(.all)
            
            Button(action: {
                logBookCoordinates = nil
            }){
                Image("back")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(width: 50, height: 50)
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct Logbook_Previews: PreviewProvider {
    static var previews: some View {
        Logbook(logBookCoordinates: .constant(nil))
    }
}
