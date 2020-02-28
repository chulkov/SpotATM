//
//  Partner.swift
//  SpotATM
//
//  Created by Max on 28/02/2020.
//  Copyright © 2020 chulkov. All rights reserved.
//

import Foundation


// MARK: - Partner
struct Partner: Codable {
    let resultCode: String
    let items: [Items]?
    let trackingID: String

    enum CodingKeys: String, CodingKey {
        case resultCode
        case items = "payload"
        case trackingID = "trackingId"
    }
    init?() {
        return nil
    }
}

// MARK: - Payload
struct Items: Codable {
    let externalID, partnerName: String
    let location: Location
    let workHours, phones: String?
    let fullAddress: String
    let addressInfo: String?
 //   let verificationInfo: VerificationInfo?
    let bankInfo: String?

    enum CodingKeys: String, CodingKey {
        case externalID = "externalId"
        case partnerName, location, workHours, phones, fullAddress, addressInfo, bankInfo
    }
}

// MARK: - Location
struct Location: Codable {
    let latitude, longitude: Double
}

//enum VerificationInfo: String, Codable {
//    case eurRubUsd = "EUR;RUB;USD;"
//    case rub = "RUB;"
//    case rubUsdEur = "RUB;USD;EUR;"
//}
