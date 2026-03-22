//
//  MainView.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/10/13.
//

import SwiftUI

enum ScreenTab: Int {
    case connection
    case topic
    case service
}

struct MainView: View {
    @State private var selectedTab: ScreenTab = .connection
    private let connectionRepository = RosBridgeConnectionRepository()

    var body: some View {
        TabView(selection: $selectedTab) {
            ConnectionScreen(viewModel: ConnectionViewModel(rosBridgeConnectionRepository: connectionRepository))
                .tabItem {
                    Label("Connection", systemImage: "network")
                }
                .tag(ScreenTab.connection)
            TopicMonitorScreen(viewModel: TopicMonitorScreenViewModel(helloTopicRepository: HelloTopicRepository(connectionRepository: connectionRepository)))
                .tabItem {
                    Label("Topic Monitor", systemImage: "dot.radiowaves.left.and.right")
                }
                .tag(ScreenTab.topic)
            CallServiceScreen(viewModel: CallServiceViewModel(turtlesimRepository: TurtlesimRepository(connectionRepository: connectionRepository)))
                .tabItem {
                    Label("Call Service", systemImage: "wave.3.up")
                }
                .tag(ScreenTab.service)
        }
    }
}

#Preview {
    MainView()
}
