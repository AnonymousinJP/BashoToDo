//
//  MemoEditScreen.swift
//  BashoToDo
//
//  Created by 櫻井絵理香 on 2024/04/05.
//

import SwiftUI


struct MemoEditScreen: View {
    @State private var inputText = "入力する"
    @FocusState private var isFocused: Bool
    var body: some View {
        VStack {
            TextEditor(text: $inputText)
                .frame(width: 300, height: 300)
                .border(.gray)
                .cornerRadius(10)
            Button {
                //非同期で呼び出す
                Task {
                    do {
                        try await saveMemo(Intlatitude: 1234, Intlongitude: 09878, text: inputText)
                    } catch {
                        print("保存できませんでした")
                    }
                }
                print("データ追加した")
            } label: {
                Text("保存")
            }
            .frame(width: 160,height: 90)
            .background(.blue)
            .cornerRadius(5)
        }
    }
}

#Preview {
    MemoEditScreen()
}
