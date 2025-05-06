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

        let uid = user.uid

        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("Failed to fetch username: \(error.localizedDescription)")
                return
            }

            let username = snapshot?.data()?["username"] as? String ?? "Unknown"

            let message = Message(
                text: text,
                senderID: uid,
                senderName: username,
                timestamp: Date()
            )

            do {
                try Firestore.firestore().collection("messages").addDocument(from: message)
            } catch {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }

}
