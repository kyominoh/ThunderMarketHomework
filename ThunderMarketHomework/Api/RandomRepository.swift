//
//  RandomRepository.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/19/26.
//

import Foundation
import Moya

struct RandomRepository {
    private let provider = MoyaProvider<RandomUserApi>()
    private func fetchRequest<T: Decodable>(api: RandomUserApi) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(api) { response in
                switch response {
                case .success(let result):
                    do {
                        let data = try JSONDecoder().decode(T.self, from: result.data)
                        continuation.resume(returning: data)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    func fetchMaleUser() async throws -> RandomResponse<RandomData> {
        return try await fetchRequest(api: .fetchMale)
    }
    
    func fetchFemaleUser() async throws -> RandomResponse<RandomData> {
        return try await fetchRequest(api: .fetchFemale)
    }
}


