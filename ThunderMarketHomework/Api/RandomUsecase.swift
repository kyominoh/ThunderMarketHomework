//
//  RandomUsecase.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/18/26.
//

import Foundation

struct RandomUsecase {
    let userRepository = RandomRepository()
    func fetchMaleUser() async throws -> RandomResponse<RandomData> {
        try await userRepository.fetchMaleUser()
    }
    func fetchFemaleUser() async throws -> RandomResponse<RandomData> {
        try await userRepository.fetchFemaleUser()
    }
}

