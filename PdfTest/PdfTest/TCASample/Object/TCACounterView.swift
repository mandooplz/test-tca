//
//  TCACounterView.swift
//  PdfTest
//
//  Created by 김민우 on 11/15/25.
//
import SwiftUI
import ComposableArchitecture


// MARK: View
struct TCACounterView: View {
    // MARK: core
    @State var store: StoreOf<TCACounter>
    
    
    // MARK: body
    var body: some View {
        VStack(spacing: 24) {
            Text("\(store.count)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: store.count)
            
            HStack(spacing: 32) {
                Button {
                    store.send(.decrement)
                } label: {
                    Image(systemName: "minus")
                        .font(.title)
                }
                
                Button {
                    store.send(.increment)
                } label: {
                    Image(systemName: "plus")
                        .font(.title)
                }
            }
        }
        .padding(40)
    }
}


// MARK: Preview
#Preview {
    TCACounterView(
        store: Store(
            initialState: TCACounter.State(),
            reducer: { TCACounter() }
        )
    )
}
