//
//  StorePoint+CoreDataProperties.swift
//  SpotATM
//
//  Created by Max on 03/03/2020.
//  Copyright © 2020 chulkov. All rights reserved.
//
//

import Foundation
import CoreData


extension StorePoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StorePoint> {
        return NSFetchRequest<StorePoint>(entityName: "StorePoint")
    }

    @NSManaged public var addressInfo: String?
    @NSManaged public var bankInfo: String?
    @NSManaged public var fullAddress: String?
    @NSManaged public var id: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var phones: String?
    @NSManaged public var workHours: String?
    @NSManaged public var partner: Partner?

}
