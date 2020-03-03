//
//  Partner+CoreDataProperties.swift
//  SpotATM
//
//  Created by Max on 03/03/2020.
//  Copyright © 2020 chulkov. All rights reserved.
//
//

import Foundation
import CoreData


extension Partner {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Partner> {
        return NSFetchRequest<Partner>(entityName: "Partner")
    }

    @NSManaged public var name: String?
    @NSManaged public var storePoints: NSSet?

}

// MARK: Generated accessors for storePoints
extension Partner {

    @objc(addStorePointsObject:)
    @NSManaged public func addToStorePoints(_ value: StorePoint)

    @objc(removeStorePointsObject:)
    @NSManaged public func removeFromStorePoints(_ value: StorePoint)

    @objc(addStorePoints:)
    @NSManaged public func addToStorePoints(_ values: NSSet)

    @objc(removeStorePoints:)
    @NSManaged public func removeFromStorePoints(_ values: NSSet)

}
