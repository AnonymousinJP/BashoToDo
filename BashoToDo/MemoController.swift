//
//  MemoController.swift
//  BashoToDo
//
//  Created by 櫻井絵理香 on 2024/04/12.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

let db = Firestore.firestore()

public struct Memo: Codable {
    let latitude: String
    let longitude: String?
    let text: String?

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case text
    }
}

func saveMemo(latitude: String, longitude: String, text: String) async throws {
    // Add a new document with a generated id.
    do {
      let ref = try await db.collection("memo").addDocument(data: [
        "lastUpdated": FieldValue.serverTimestamp(),
        "latitude": latitude,
        "longitude": longitude,
        "text": text,
      ])
      print("Document added with ID: \(ref.documentID)")
    } catch {
      print("Error adding document: \(error)")
    }
}
