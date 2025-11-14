//
//  TestView.swift
//  PdfTest
//
//  Created by 김민우 on 11/14/25.
//

// 이것도 그냥 테스트
import SwiftUI
import ComposableArchitecture

struct CounterView: View {
    @Bindable var store: StoreOf<CounterFeature>

    var body: some View {
        VStack(spacing: 16) {
            Text("Count: \(store.count)")
                .font(.largeTitle)

            HStack(spacing: 20) {
                Button("-") {
                    store.send(.minusButtonTapped)
                }
                Button("+") {
                    store.send(.plusButtonTapped)
                }
            }
        }
        .padding()
    }
}
