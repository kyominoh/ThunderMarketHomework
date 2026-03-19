//
//  NetworkWorker.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/18/26.
//

import Foundation
import Moya
internal import Alamofire

enum RandomUserApi {
    case fetchMale
    case fetchFemale
    case fetchSeed
    case fetchNat
    case fetchInc
    case fetchExc
}

extension RandomUserApi: TargetType {
    var baseURL: URL {
        URL(string: "https://randomuser.me")!
    }
    
    var task: Moya.Task {
        var params: [String: String] = [:]
        switch self {
        case .fetchMale:
            params["gender"] = "male"
        case .fetchFemale:
            params["gender"] = "female"
        case .fetchSeed:
            params["seed"] = "wealth"
        case .fetchNat:
            params["nat"] = "US"
        case .fetchInc:
            params["inc"] = "gender,dob,nat"
        case .fetchExc:
            params["exc"] = "dob,nat,email"
        }
        return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
    }
    
    var headers: [String : String]? {
        ["Accept": "application/json"]
    }
    
    var path: String {
        return "/api"
    }
    
    var method: Moya.Method {
        return .get
    }
}

