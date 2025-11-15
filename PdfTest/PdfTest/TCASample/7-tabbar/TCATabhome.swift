//
//  TCATabhome.swift
//  PdfTest
//
//  Created by 김민우 on 11/15/25.
//
import Foundation
import ComposableArchitecture


// MARK: Object
enum Tab: Hashable {
    case home
    case settings
}


@Reducer
struct TCATabhome {
    @ObservableState
    struct State: Equatable {
        
    }
    
    
    enum Action: Equatable {
        case selectTab(Tab) // 사용자가 선택한
    }
}
