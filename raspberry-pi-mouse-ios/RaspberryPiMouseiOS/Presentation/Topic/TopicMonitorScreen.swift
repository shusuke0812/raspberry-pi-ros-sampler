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
            if (viewModel.messages.isEmpty) {
                Spacer()
                Text("Not found messages")
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(viewModel.messages.enumerated()), id: \.offset) { _, message in
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
            }

            Button(action: {
                viewModel.subscribeHelloMessage()
            }) {
                Text("Start Hello Subscribe")
                    .frame(width: screenWidth.width * 0.65)
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 20)
        }
        .padding()
    }
}

#Preview {
    TopicMonitorScreen(viewModel: TopicMonitorScreenViewModel())
}
