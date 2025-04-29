//
//  ChatView.swift
//  CountingSteps-Widget
//
//  Created by Andy Hernandez on 4/28/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    private var db = Firestore.firestore()
    
    init() {
        fetchMessages()
    }
    
    func fetchMessages() {
        db.collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.messages = documents.compactMap { doc in
                    try? doc.data(as: Message.self)
                }
            }
    }
    
    func sendMessage(text: String) {
        guard let user = Auth.auth().currentUser else {
            print("No current user")
            return
        }
        let message = Message(
            text: text,
            senderID: user.uid,
            timestamp: Date()
        )
        do {
            _ = try db.collection("messages").addDocument(from: message)
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
}
