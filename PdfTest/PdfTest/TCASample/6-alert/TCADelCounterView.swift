//
//  TCADelCounterView.swift
//  PdfTest
//
//  Created by 김민우 on 11/15/25.
//
import SwiftUI
import ComposableArchitecture


// MARK: View
struct TCADelCounterView: View {
    // MARK: core
    @State var store: StoreOf<TCADelCounter>

    init(store: StoreOf<TCADelCounter>) {
        self.store = store
    }

    // MARK: body
    var body: some View {
        VStack(spacing: 24) {
            Text("Count: \(store.count)")
                .font(.largeTitle)

            HStack(spacing: 16) {
                Button("Increment") {
                    store.send(.incrementButtonTapped)
                }
                .buttonStyle(.borderedProminent)

                Button("Reset") {
                    store.send(.deleteButtonTapped)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}


// MARK: Preview
#Preview {
    TCADelCounterView(
        store: Store(
            initialState: TCADelCounter.State(),
            reducer: { TCADelCounter() }
        )
    )
}

