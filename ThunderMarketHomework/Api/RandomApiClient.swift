//
//  RandomApiClient.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/22/26.
//

import Foundation
import Dependencies

public struct RequestModel: Equatable, Sendable {
    var page: Int
    var param: RandomUserParam
}

public struct RandomApiClient: Sendable {
    public var fetchData: @Sendable (RequestModel) async throws -> RandomResponse<RandomData>
}

extension RandomApiClient: DependencyKey {
    public static var liveValue: RandomApiClient {
        let usecase = RandomUsecase()
        return Self(
            fetchData: { param in
                try await usecase.fetchData(page: param.page, param: param.param)
            }
        )
    }
}

extension DependencyValues {
    public var randomApiClient: RandomApiClient {
        get {
            self[RandomApiClient.self]
        } set {
            self[RandomApiClient.self] = newValue
        }
    }
}
