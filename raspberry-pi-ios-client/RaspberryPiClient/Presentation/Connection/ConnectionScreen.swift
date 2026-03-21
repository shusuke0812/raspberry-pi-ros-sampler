//
//  ConnectionScreen.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/10/26.
//

import SwiftUI

struct ConnectionScreen<ViewModel: ConnectionViewModelProtocol>: View {
    @StateObject var viewModel: ViewModel

    private let screenWidth = UIScreen.main.bounds

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Picker("Connection Mode", selection: $viewModel.connectionMode) {
                ForEach(ConnectionMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .disabled(viewModel.connectionStatus == .connected)
            TextField("IP Address", text: $viewModel.ipAddress)
                .frame(width: screenWidth.width * 0.7)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button(action: {
                viewModel.connect()
            }) {
                Group {
                    if (viewModel.connectionStatus == .connecting) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Connect")
                    }
                }
                .frame(width: screenWidth.width * 0.65)
            }
            .disabled(viewModel.connectionStatus == .connected)
            .buttonStyle(.borderedProminent)
            Button(action: {
                viewModel.disconnect()
            }) {
                Text("Disconnect")
                    .frame(width: screenWidth.width * 0.65)
            }
            .disabled(viewModel.connectionStatus != .connected)
            .buttonStyle(.borderedProminent)
            Text("\(viewModel.connectionMode.rawValue): \(viewModel.connectionStatus.description)")
                .font(.headline)
        }
        .padding()
    }
}

#Preview {
    ConnectionScreen(viewModel: ConnectionViewModel())
}
