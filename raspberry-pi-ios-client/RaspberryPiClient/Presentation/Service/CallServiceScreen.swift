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
            BodyView(viewModel: viewModel)
            FooterView(viewModel: viewModel)
                .padding()
        }
    }
}

private struct BodyView<ViewModel: CallServiceViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            if (viewModel.uiState.isShowProgressView) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                Text(viewModel.uiState.title)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .padding()
            }
            Spacer()
            JoystickView()
                .overlay(
                    Color.white.opacity(viewModel.uiState.joystickState.opacity)
                        .allowsHitTesting(viewModel.uiState.joystickState.isDisabled)
                )
            Spacer()
        }
    }
}

private struct FooterView<ViewModel: CallServiceViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        HStack {
            Button(action: {
                viewModel.spawnTurtle()
            }) {
                Text("Spawn")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button(action: {
                viewModel.moveTurtle()
            }) {
                Text("Move")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button(action: {
                viewModel.reset()
            }) {
                Text("Reset")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    CallServiceScreen(viewModel: CallServiceViewModel())
}
