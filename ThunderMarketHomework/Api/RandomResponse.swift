//
//  RandomResponse.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/19/26.
//


struct RandomResponse<T: Codable>: Codable {
    let results: [T]
    let info: RandomInfo
}
struct RandomData: Codable, Hashable, Equatable, Sendable {
    let gender: String
    let name: RandomName
    let location: RandomLocation
    let email: String
    let login: RandomLogin
    let dob: RandomDob
    let registered: RandomDob
    let phone: String
    let cell: String
    let `id`: RandomId
    let picture: RandomPicture
    let nat: String
    public static func == (lhs: RandomData, rhs: RandomData) -> Bool {
        lhs.name == rhs.name
    }
}
struct RandomName: Codable, Hashable, Equatable {
    let title: String
    let first: String
    let last: String
}
struct RandomLocation: Codable, Hashable, Equatable {
    let street: RandomStreet
    let city: String
    let state: String
    let country: String
    let postcode: Int
    let coordinates: RandomCoordinates
    let timezone: RandomTimezone
}
struct RandomLogin: Codable, Hashable, Equatable {
    let uuid: String
    let username: String
    let password: String
    let salt: String
    let md5: String
    let sha1: String
    let sha256: String
}
struct RandomDob: Codable, Hashable, Equatable {
    let date: String
    let age: Int
}
struct RandomStreet: Codable, Hashable, Equatable {
    let number: Int
    let name: String
}
struct RandomCoordinates: Codable, Hashable, Equatable {
    let latitude: String
    let longitude: String
}
struct RandomTimezone: Codable, Hashable, Equatable {
    let offset: String
    let description: String
}
struct RandomId: Codable, Hashable, Equatable {
    let name: String
    let value: String?
    public static func == (lhs: RandomId, rhs: RandomId) -> Bool {
        return lhs.name == rhs.name && lhs.value == rhs.value
    }
}
struct RandomPicture: Codable, Hashable, Equatable {
    let large: String
    let medium: String
    let thumbnail: String
}

struct RandomInfo: Codable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
}
