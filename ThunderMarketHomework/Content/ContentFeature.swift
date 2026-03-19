//
//  ContentFeature.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/19/26.
//

import Foundation
import ComposableArchitecture
import Dependencies

@Reducer
public struct ContentFeature {
    
    @ObservableState
    public struct State: Sendable {
        var results: [RandomData] = []
        var page: Int = 0
        var isEnd: Bool = false
        var isLoading: Bool = false
    }
    
    public enum Action: Equatable, Sendable {
        case fetchData
    }
    
    public var body: any Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchData:
                return .run { send in
                    
                }
            }
        }
    }
}
