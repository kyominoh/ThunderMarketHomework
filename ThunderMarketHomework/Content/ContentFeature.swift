//
//  ContentFeature.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/19/26.
//

import Foundation
import ComposableArchitecture
import Dependencies

private enum CancelID {
    case request
}

@Reducer
public struct ContentFeature {
    @Dependency(RandomApiClient.self) var randomApiClient: RandomApiClient

    @ObservableState
    public struct State: Sendable {
        var items: [RandomData] = []
        var isEnd: Bool = false
        var isLoading: Bool = false
        var param: RequestModel = RequestModel(page: 1, param: .male)
    }

    public enum Action: Equatable, Sendable {
        case fetchTypeChanged(RandomUserParam)
        case refresh
        case request
        case response([RandomData])
        case delete(RandomData)
    }

    public var body: some Reducer<State, Action> {
        Reduce { [self] state, action in
            switch action {
            case .fetchTypeChanged(let newParam):
                guard !state.isLoading else { return .none }
                state.isEnd = false
                state.items.removeAll()
                state.param = RequestModel(page: 1, param: newParam)
                return .run { send in await send(.request) }

            case .refresh:
                state.isEnd = false
                state.items.removeAll()
                state.param.page = 1
                return .run { send in await send(.request) }

            case .request:
                guard !state.isEnd, !state.isLoading else { return .none }
                state.isLoading = true
                let param = state.param
                let fetchData = randomApiClient.fetchData
                return .run { send in
                    do {
                        let response = try await fetchData(param)
                        await send(.response(response.results))
                    } catch {
                        await send(.response([]))
                    }
                }
                .cancellable(id: CancelID.request, cancelInFlight: true)

            case .response(let newItems):
                state.isLoading = false
                let existingPictures = Set(state.items.flatMap {
                    [$0.picture.large, $0.picture.medium, $0.picture.thumbnail]
                })
                let filtered = newItems.filter {
                    !state.items.contains($0) &&
                    !existingPictures.contains($0.picture.large) &&
                    !existingPictures.contains($0.picture.medium) &&
                    !existingPictures.contains($0.picture.thumbnail)
                }
                if filtered.isEmpty {
                    state.isEnd = true
                } else {
                    state.items.append(contentsOf: filtered)
                    state.param.page += 1
                }
                return .none

            case .delete(let item):
                state.items.removeAll { $0 == item }
                return .none
            }
        }
    }
}
