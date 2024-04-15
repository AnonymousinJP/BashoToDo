//
//  MemoScreen.swift
//  BashoToDo
//
//  Created by 櫻井絵理香 on 2024/04/05.
//

import SwiftUI
import FirebaseFirestore

struct MemoScreen: View {
    @StateObject private var memoController = MemoController()
    var body: some View {
        VStack {
            ForEach(memoController.memos) { memo in
                VStack(alignment: .leading) {
                    Text("id: \(memo.documentId)")
                    Text("Latitude: \(memo.latitude)")
                    Text("Longitude: \(memo.longitude ?? "")")
                    Text("Text: \(memo.text ?? "")")
                    Text("Created At: \(formatDate(memo.createAt))")
                }
                .onTapGesture {
                    //データベース上では消えてるが、再描画はしていない、タップしたらメモ消える
                    Task {
                        await memoController.RemoveMemo(removeId: memo.documentId)
                    }
                }
            }
        }
        .onAppear {
            memoController.MemoLister()
        }


    }
    private func formatDate(_ timestamp: Timestamp) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: timestamp.dateValue())

    }
}
