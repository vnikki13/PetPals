//
//  Message.swift
//  PetPals
//
//  Created by Nikki Vaughan on 7/9/20.
//  Copyright © 2020 Nikki Vaughan. All rights reserved.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct SearchResult {
    let name: String
    let email: String
}

