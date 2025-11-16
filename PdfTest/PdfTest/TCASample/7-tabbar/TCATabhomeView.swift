//
//  TCATabhomeView.swift
//  PdfTest
//
//  Created by 김민우 on 11/16/25.
//
import SwiftUI
import ComposableArchitecture


// MARK: View
struct TCATabhomeView: View {
    // MARK: store
    @State var store: StoreOf<TCATabhome>
    
    
    // MARK: body
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Count: \(store.count)")
                    .font(.title)

                HStack {
                    Button("-") {
                        store.send(.decrement)
                    }
                    .buttonStyle(.bordered)

                    Button("+") {
                        store.send(.increment)
                    }
                    .buttonStyle(.borderedProminent)
                }

                Divider().padding(.vertical, 8)

                // Detail 화면으로 이동
                Button("Go to Detail Tab") {
                    store.send(.goToDetailTab)
                }
                .buttonStyle(.borderedProminent)

                // Settings 화면으로 이동
                Button("Go to Setting Tab") {
                    store.send(.goToSettingTab)
                }
                .buttonStyle(.bordered)

                Spacer()
            }
            .navigationTitle("Navigation Example")
            // DetailTab Presentation
            .navigationDestination(
                item: $store.scope(state: \.destination?.detail, action: \.destination.detail)
            ) { store in
                    Text("DetailTab과 연결된 View입니다.")
                }
            
            // SettingTab Presentation
            .sheet(item: $store.scope(state: \.destination?.settings, action: \.destination.settings)) { store in
                Text("SettingTab과 연결된 View입니다.")
            }
        }
    }
}


// MARK: Preivew
#Preview {
    TCATabhomeView(
        store: Store(
            initialState: TCATabhome.State(),
            reducer: { TCATabhome() })
    )
}

