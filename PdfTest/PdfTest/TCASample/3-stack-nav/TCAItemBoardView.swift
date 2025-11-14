////
////  TCAItemBoardView.swift
////  PdfTest
////
////  Created by 김민우 on 11/15/25.
////
//import SwiftUI
//import ComposableArchitecture
//
//// MARK: - Item Board View
//struct TCAItemBoardView: View {
//    @State var store: StoreOf<TCAItemBoard>
//    
//    var body: some View {
//        NavigationStack(
//            path: $store.scope(state: \.path, action: \.path)
//        ) {
//            List {
//                ForEach(store.items, id: \.id) { item in
//                    Button {
//                        store.send(.itemTapped(id: item.id))
//                    } label: {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text(item.title)
//                                .font(.headline)
//                            
//                            Text(item.description)
//                                .font(.subheadline)
//                                .foregroundStyle(.secondary)
//                        }
//                        .padding(.vertical, 4)
//                    }
//                }
//            }
//            .navigationTitle("Item Board")
//        } destination: { state in
//            // Screens pushed onto the navigation stack
//            switch state.case {
//            case .addItem(let store):
//                TCAItemView(store: store)
//            }
//        }
//    }
//}
//
//// MARK: - Item Detail View
//struct TCAItemView: View {
//    let store: StoreOf<TCAItem>
//    
//    var body: some View {
//        WithViewStore(store, observe: \.item) { viewStore in
//            VStack(alignment: .leading, spacing: 16) {
//                Text(viewStore.title)
//                    .font(.title)
//                    .bold()
//                
//                Text(viewStore.description)
//                    .font(.body)
//                
//                Spacer()
//            }
//            .padding()
//            .navigationTitle("Item")
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    TCAItemBoardView(
//        store: Store(
//            initialState: TCAItemBoard.State(),
//            reducer: { TCAItemBoard() }
//        )
//    )
//}
