//
//  ConnectionViewModel.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/7/21.
//

import Foundation
import Combine

class ConnectionViewModel: ObservableObject {
    
    @Published var selectedProtocol = ConnectionView.ProtocolType.smartPort
    @Published var showingActionSheetLogs = false
    @Published var savedLogs = ["1","2","3","4"]
    
}
