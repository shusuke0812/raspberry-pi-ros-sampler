//
//  ConnectionScreen.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/26.
//

import SwiftUI

struct ConnectionScreen<ViewModel: ConnectionViewModelProtocol>: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("接続状態: \(viewModel.connectionStatus)")
                .font(.headline)
            TextField("IP Address", text: $viewModel.ipAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Connect") {
                viewModel.connect()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    ConnectionScreen(viewModel: ConnectionViewModel())
}
