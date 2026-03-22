//
//  RandomUserApi.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/21/26.
//




public enum RandomUserParam: String, CaseIterable, Sendable {
    case male, female, seed, nat, inc, exc
    
    var key: String {
        switch self {
        case .male, .female:
            return "gender"
            
        default:
            return self.rawValue
        }
    }
    
    var value: String {
        switch self {
        case .male:     return "male"
        case .female:   return "female"
        case .seed:     return "wealth"
        case .nat:      return "US"
        case .inc:      return "gender,dob,nat"
        case .exc:      return "dob,nat,email"
        }
    }
}
