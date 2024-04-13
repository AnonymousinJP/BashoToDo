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
    @StateObject private var memoController = MemoController()
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    TextEditor(text: $inputText)
                        .frame(width: 300, height: 300)
                        .cornerRadius(10)
                        .border(.gray)
                    Button {
                        //非同期で呼び出す
                        Task {
                            do {
                                try await memoController.saveMemo(Intlatitude: 1234, Intlongitude: 1234, text:inputText )
                            } catch {
                                print("保存できませんでした")
                            }
                        }
                        inputText = ""
                        print("データ追加した")
                    } label: {
                        Text("保存")
                            .foregroundColor(.white)
                    }
                    .frame(width: 160,height: 90)
                    .background(.blue)
                    .cornerRadius(5)
                    NavigationLink(destination: MemoScreen()) {
                        Text("移動")
                    }
                }
            }
        }
    }
}

#Preview {
    MemoEditScreen()
}
