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

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

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
                .keyboardType(.decimalPad)
                .frame(width: screenWidth.width * 0.7)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 30)
            Button(action: {
                dismissKeyboard()
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            dismissKeyboard()
        }
        .padding()
    }
}

#Preview {
    ConnectionScreen(viewModel: ConnectionViewModel())
}
