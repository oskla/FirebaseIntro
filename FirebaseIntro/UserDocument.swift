//
//  Item.swift
//  FirebaseIntro
//
//  Created by Oskar Larsson on 2022-10-12.
//

import Foundation
import FirebaseFirestoreSwift

struct UserDocument: Codable, Identifiable {
    @DocumentID var id: String?
    var entries: [JournalEntry]
    

}

struct JournalEntry: Codable, Identifiable {
    
    var id = UUID()
    var title: String
    var description: String = "Vegetables"
    var date: Date
}
