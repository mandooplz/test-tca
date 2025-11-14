//
//  minwoo_NavigationTest.swift
//  PdfTest
//
//  Created by 김민우 on 11/14/25.
//
import SwiftUI
import ComposableArchitecture


// Path를 따로 분리해야 하지 않을까? -> View와 관련된 데이터, 비즈니스 로직은 아님.
// MARK: - Child Feature
@Reducer
struct MinwooAppFeature: Reducer {
    @Reducer
    struct Path {
        @ObservableState
        enum State: Equatable {
            case detail(DetailFeature.State)
            case settings(SettingsFeature.State)
        }
        
        enum Action {
            case detail(DetailFeature.Action)
            case settings(SettingsFeature.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: \.detail, action: \.detail) {
                DetailFeature()
            }
            
            Scope(state: \.settings, action: \.settings) {
                SettingsFeature()
            }
        }
    }
    
    
    // App의 상태
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
    }
    
    // App의 액션
    enum Action {
        case path(StackAction<Path.State, Path.Action>)
        case detailButtonTapped
        case settingsButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .detailButtonTapped:
                state.path.append(.detail(DetailFeature.State()))
                return .none
                
            case .settingsButtonTapped:
                state.path.append(.settings(SettingsFeature.State()))
                return .none
                
            case .path:
                return .none
                
            }
        }
        // path(StackState)에 대해서는 Path 리듀서를 forEach 로 연결
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
}


// MARK: DetailFeature
@Reducer
struct DetailFeature {
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action { }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            .none
        }
    }
}


// MARK: SettingsFeature
@Reducer
struct SettingsFeature {
    @ObservableState
    struct State: Equatable { }
    
    enum Action { }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            .none
        }
    }
}


// MARK: SampleView
struct SampleView: View {
    @Bindable var store: StoreOf<MinwooAppFeature>
    
    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            VStack(spacing: 16) {
                Text("Root View")
                    .font(.title)
                
                Button("Go to Detail") {
                    store.send(.detailButtonTapped)
                }
                
                Button("Go to Settings") {
                    store.send(.settingsButtonTapped)
                }
            }
            .padding()
            .navigationTitle("Home")
        } destination: { store in
            switch store.state {
            case .detail:
                if let detailStore = store.scope(state: \.detail, action: \.detail) {
                    DetailView(store: detailStore)
                }
            case .settings:
                if let settingsStore = store.scope(state: \.settings, action: \.settings) {
                    SettingsView(store: settingsStore)
                }
            }
        }
    }
}



// Detail 화면
struct DetailView: View {
    let store: StoreOf<DetailFeature>
    
    var body: some View {
        Text("Detail Screen")
            .font(.title)
            .navigationTitle("Detail")
    }
}

// Settings 화면
struct SettingsView: View {
    let store: StoreOf<SettingsFeature>
    
    var body: some View {
        Text("Settings Screen")
            .font(.title)
            .navigationTitle("Settings")
    }
}


// MARK: - Preview

struct SampleView_Previews: PreviewProvider {
    static var previews: some View {
        SampleView(
            store: Store(
                initialState: MinwooAppFeature.State(),
                reducer: { MinwooAppFeature() }
            )
        )
    }
}
