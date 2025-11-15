//
//  TCAAlarm.swift
//  PdfTest
//
//  Created by 김민우 on 11/15/25.
//

import SwiftUI
import ComposableArchitecture

struct TreeTestView: View {
    @Bindable var store: StoreOf<Tree_basedNavigation>
    
    var body: some View {
        VStack(spacing: 24) {
            Text("TCA Counter")
                .font(.title)
            
            Text("\(store.count)")
                .font(.system(size: 47, weight: .bold, design: .rounded))
            
            HStack(spacing: 20) {
                Button("-") {
                    store.send(.minusButtonTapped)
                }
                .font(.largeTitle)
                
                Button("+") {
                    store.send(.plusButtonTapped)
                }
                .font(.largeTitle)
            }
            
            Button("Reset") {
                store.send(.resetButtonTapped)
            }
            .padding(.top, 20)
        }
        .padding()
    }
}
