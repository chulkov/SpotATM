//
//  CoreDataStack.swift
//  SpotATM
//
//  Created by Max on 02/03/2020.
//  Copyright © 2020 chulkov. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {

  private let modelName: String

  init(modelName: String) {
    
    self.modelName = modelName
  }

  lazy var managedContext: NSManagedObjectContext = {
    
    return self.storeContainer.viewContext
  }()

  private lazy var storeContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: self.modelName)
    container.loadPersistentStores { (storeDescription, error) in
      if let error = error as NSError? {
        print("Unresolved error \(error), \(error.userInfo)")
      }
    }
    return container
  }()

  func saveContext () {
    guard managedContext.hasChanges else { return }
    managedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    do {
        //managedContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
      try managedContext.save()
    } catch let nserror as NSError {
      print("Unresolved error \(nserror), \(nserror.userInfo)")
    }
  }
}
