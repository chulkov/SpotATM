//
//  Partner+CoreDataProperties.swift
//  SpotATM
//
//  Created by Max on 02/03/2020.
//  Copyright © 2020 chulkov. All rights reserved.
//
//

import Foundation
import CoreData


extension Partner {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Partner> {
        return NSFetchRequest<Partner>(entityName: "Partner")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var phones: String?
    @NSManaged public var workHours: String?
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var addressInfo: String?
    @NSManaged public var fullAddress: String?
    @NSManaged public var bankInfo: String?

}
