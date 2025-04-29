//
//  ChatView.swift
//  CountingSteps-Widget
//
//  Created by Andy Hernandez on 4/28/25.
//

import SwiftUI
import FirebaseAuth

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var messageText = ""

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.messages) { message in
                            Text(message.text)
                                .padding()
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity, alignment: message.senderID == Auth.auth().currentUser?.uid ? .trailing : .leading)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) {
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }

            }
            
            HStack {
                TextField("Type your message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    viewModel.sendMessage(text: messageText)
                    messageText = ""
                }) {
                    Text("Send")
                }
                .padding(.leading, 8)
            }
            .padding()
        }
        .navigationTitle("Global Chat 🔥")
    }
}
