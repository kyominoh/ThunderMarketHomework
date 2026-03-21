//
//  NetworkWorker.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/18/26.
//

import Foundation
import Moya
internal import Alamofire

extension RandomUserApi: TargetType {
    var baseURL: URL {
        URL(string: "https://randomuser.me")!
    }
    
    var task: Moya.Task {
        var params: [String: String] = [:]
        switch self {
        case .fetchData(let page, let param):
            if let page = page { params["page"] = "\(page)" }
            if let param = param { params[param.key] = param.value }
            
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
        params["results"] = "20"
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

