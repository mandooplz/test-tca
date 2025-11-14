//
//  TCALoginFormView.swift
//  PdfTest
//
//  Created by 김민우 on 11/15/25.
//
import SwiftUI
import ComposableArchitecture


// MARK: View
struct TCALoginFormView: View {
    // MARK: core
    @State var store: StoreOf<TCALoginForm>
    
    
    // MARK: body
    var body: some View {
        VStack(spacing: 24) {
            Text("이메일 로그인")
                .font(.title)
                .bold()
            
            VStack(alignment: .leading, spacing: 16) {
                TextField("이메일", text: $store.email)
                    .textInputAutocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                
                SecureField("비밀번호 (6자 이상)", text: $store.password)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button {
                store.send(.submit)
            } label: {
                if store.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("로그인")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!store.isFormValid || store.isLoading)
            
            Spacer()
        }
        .padding()
    }
}
