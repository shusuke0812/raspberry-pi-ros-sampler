//
//  CallServiceScreen.swift
//  RaspberryPiClient
//
//  Created by Shusuke Ota on 2025/12/28.
//

import SwiftUI

struct CallServiceScreen<ViewModel: CallServiceViewModelProtocol>: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        VStack(spacing: 20) {
            switch viewModel.uiState {
            case .standby, .failure:
                BodyView(viewModel: viewModel)
            case .loading:
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Spacer()
            case .success:
                BodyView(viewModel: viewModel)
            }

            FooterView(viewModel: viewModel)
                .padding()
        }
    }
}

private struct BodyView: View {
    let viewModel: any CallServiceViewModelProtocol

    var body: some View {
        VStack {
            Text(viewModel.uiState.title)
                .fontWeight(.bold)
                .foregroundColor(.gray)
                .padding()
            Spacer()
            JoystickView()
                .overlay(
                    Color.white.opacity(0.6)
                        .allowsHitTesting(viewModel.uiState.disabledJoystick)
                )
            Spacer()
        }
    }
}

private struct FooterView: View {
    let viewModel: any CallServiceViewModelProtocol

    var body: some View {
        Button(action: {
            viewModel.callSpawn()
        }) {
            Text("Spawn")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding(.bottom, 20)
    }
}

#Preview {
    CallServiceScreen(viewModel: CallServiceViewModel())
}
