//
//  TCAMainCView.swift
//  PdfTest
//
//  Created by 김민우 on 11/17/25.
//
import SwiftUI
import ComposableArchitecture


// MARK: View
struct TCAMainCView: View {
    @Bindable var store: StoreOf<TCAMainC>

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sibling 상태 공유")
                            .font(.title3.bold())

                        Text("형제 피처 간 state를 공유하는 방법을 확인하세요. 컨트롤러의 액션이 부모 피처를 거쳐 뷰어의 카운터를 즉시 업데이트합니다.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    TCAViewerView(
                        store: store.scope(state: \.viewer, action: \.viewer)
                    )

                    TCAControllerView(
                        store: store.scope(state: \.controller, action: \.controller)
                    )
                }
                .padding()
            }
            .navigationTitle("Sibling 샘플")
        }
    }
}


// MARK: Preview
#Preview {
    TCAMainCView(
        store: Store(
            initialState: TCAMainC.State(),
            reducer: { TCAMainC() }
        )
    )
}
