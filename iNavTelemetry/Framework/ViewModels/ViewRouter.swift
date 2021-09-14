//
//  ViewRouter.swift
//  iNavTelemetry
//
//  Created by Bosko Petreski on 9/6/21.
//

import SwiftUI

enum Screen {
    case logBook(_ log: URL)
    case dashboard
}

class ViewRouter: ObservableObject {
    @Published var currentPage: Screen = .dashboard
}
