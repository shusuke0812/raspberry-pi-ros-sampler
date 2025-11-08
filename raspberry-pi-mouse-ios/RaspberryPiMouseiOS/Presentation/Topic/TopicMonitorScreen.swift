//
//  TopicMonitorScreen.swift
//  RaspberryPiMouseiOS
//
//  Created by Shusuke Ota on 2025/10/26.
//

import SwiftUI

struct TopicMonitorScreen<ViewModel: TopicMonitorScreenViewModelProtocol>: View {
    @StateObject var viewModel: ViewModel

    private let screenWidth = UIScreen.main.bounds

    var body: some View {
        VStack(spacing: 20) {
            switch viewModel.uiState {
            case .standby:
                Spacer()
                Text(viewModel.uiState.title)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Spacer()
            case .loading:
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Spacer()
            case .success(let messages):
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(messages.enumerated()), id: \.offset) { _, message in
                            Text("\(message)")
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            case .failure(let error):
                Spacer()
                    .alert("エラー", isPresented: $viewModel.isErrorPresented) {
                        Button("OK") {
                            viewModel.hideErrorAlert()
                        }
                    } message: {
                        Text(error.description)
                    }
            }

            HStack(spacing: 16) {
                Button(action: {
                    viewModel.subscribeHelloMessage()
                }) {
                    Text("Start \nHello Subscribe")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: {
                    viewModel.unsubscribeHelloMessage()
                }) {
                    Text("End \nHello Subscribe")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.bottom, 20)
        }
        .padding()
    }
}

#Preview {
    TopicMonitorScreen(viewModel: TopicMonitorScreenViewModel())
}
