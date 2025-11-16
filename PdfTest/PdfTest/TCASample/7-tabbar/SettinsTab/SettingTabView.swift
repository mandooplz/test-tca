//
//  SettingTabView.swift
//  PdfTest
//
//  Created by 김민우 on 11/17/25.
//
import Foundation
import SwiftUI
import ComposableArchitecture


// MARK: View
struct SettingTabView: View {
    // MARK: core
    let store: StoreOf<SettingTab>
    
    
    // MARK: body
    var body: some View {
        VStack {
            Button("Increment") {
                store.send(.increment)
            }
            
            Button("Decrement") {
                store.send(.decrement)
            }
        }.buttonStyle(.borderedProminent)
    }
}
