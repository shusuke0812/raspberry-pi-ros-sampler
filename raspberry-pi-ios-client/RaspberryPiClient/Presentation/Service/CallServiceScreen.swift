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
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    CallServiceScreen(viewModel: CallServiceViewModel())
}
