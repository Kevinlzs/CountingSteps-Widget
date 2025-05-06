//
//  ChatMessage.swift
//  CountingSteps-Widget
//
//  Created by Andy Hernandez on 4/28/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore


struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    let text: String
    let senderID: String
    let senderName: String
    let timestamp: Date
}
