//
//  AlanLLM.swift
//  PdfTest
//
//  Created by 김민우 on 11/14/25.
//
import Foundation


// MARK: Domain
nonisolated struct AlanLLM: Sendable {
    let baseURL: URL
    let client: String
    
    // MARK: flow
    @concurrent
    func summarizePDFText(_ text: String) async throws -> String {
        fatalError()
    }
    
    @concurrent
    func question(content: String) async throws -> Response {
        fatalError()
    }
    
    // MARK: value
    nonisolated struct Action: Sendable, Decodable {
        let name: String?
        let speak: String?
    }
    
    nonisolated struct Response: Sendable, Decodable {
        let action: Action?
        let content: String
    }
}
