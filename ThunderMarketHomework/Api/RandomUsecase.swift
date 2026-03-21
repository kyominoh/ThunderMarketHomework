//
//  RandomUsecase.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/18/26.
//

import Foundation

struct RandomUsecase {
    let userRepository = RandomRepository()
    func fetchData(page: Int?, param: RandomUserParam?) async throws -> RandomResponse<RandomData> {
        try await userRepository.fetchData(page: page, param: param)
    }
    func fetchFemaleUser() async throws -> RandomResponse<RandomData> {
        try await userRepository.fetchFemaleUser()
    }
}

