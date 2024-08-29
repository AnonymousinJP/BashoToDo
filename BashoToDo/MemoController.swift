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

public struct Memo: Codable, Identifiable {
    public var id: String { documentId }
    let documentId: String
    let latitude: String
    let longitude: String?
    let text: String?
    var createAt: Timestamp

    enum CodingKeys: String, CodingKey {
        case documentId//id追加
        case latitude
        case longitude
        case text
        case createAt
    }
}

class MemoController: ObservableObject {
    @Published var memos: [Memo] = []
    func saveMemo(Intlatitude: Int, Intlongitude: Int, text: String) async throws {
        //IntからStringに変換する
        let latitude = String(Intlatitude)
        let longitude = String(Intlongitude)
        // Add a new document with a generated id.
        do {
            let ref = try await db.collection("memo").addDocument(data: [
                "createAt": FieldValue.serverTimestamp(),
                "latitude": latitude,
                "longitude": longitude,
                "text": text,
            ])
            print("Document added with ID: \(ref.documentID)")
        } catch {
            print("Error adding document: \(error)")
        }

    }

    func MemoLister() {
        db.collection("memo").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
                return
            }

            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }

            for document in documents {
                let source = document.metadata.hasPendingWrites ? "Local" : "Server"

                //Firestoreから取得したドキュメントをMemoインスタンスに変換し、memosに格納
                self.memos = documents.map { document in
                                let data = document.data()
                                return Memo(documentId: document.documentID,
                                            latitude: data["latitude"] as? String ?? "",
                                            longitude: data["longitude"] as? String,
                                            text: data["text"] as? String,
                                            createAt: data["createAt"] as? Timestamp ?? Timestamp())
                            }
            }
        }
    }

    func RemoveMemo(removeId: String) async {
        do {
          try await db.collection("memo").document(removeId).delete()
          print("メモ消えた")
        } catch {
          print("消えんかった: \(error)")
        }

    }

}
