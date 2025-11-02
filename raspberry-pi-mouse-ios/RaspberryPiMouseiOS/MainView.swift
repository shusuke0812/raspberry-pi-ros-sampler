//
//  MainView.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/13.
//

import SwiftUI

enum ScreenTab: Int {
    case connection
    case topic
}

struct MainView: View {
    @State private var selectedTab: ScreenTab = .connection

    var body: some View {
        TabView(selection: $selectedTab) {
            ConnectionScreen(viewModel: ConnectionViewModel())
                .tabItem {
                    Label("Connection", systemImage: "network")
                }
                .tag(ScreenTab.connection)
            TopicMonitorScreen(viewModel: TopicMonitorScreenViewModel())
                .tabItem {
                    Label("Topic Monitor", systemImage: "dot.radiowaves.left.and.right")
                }
                .tag(ScreenTab.topic)
        }
    }
}

#Preview {
    MainView()
}
