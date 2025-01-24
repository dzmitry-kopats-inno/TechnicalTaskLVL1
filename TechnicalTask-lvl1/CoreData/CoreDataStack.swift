//
//  CoreDataStack.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 26/11/2024.
//

import CoreData
import RxSwift

private enum Constants {
    static let modelName = "UserModel"
}

final class CoreDataStack {
    static let shared = CoreDataStack()
    private let errorSubject = PublishSubject<AppError>()
    var errorPublisher: Observable<AppError> {
        errorSubject.asObservable()
    }
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.modelName)
        container.loadPersistentStores { description, error in
            if let error {
                let appError = AppError(message: "Core Data loading error: \(error.localizedDescription)")
                self.errorSubject.onNext(appError)
                
                if let storeURL = description.url {
                    do {
                        try FileManager.default.removeItem(at: storeURL)
                        debugPrint("Removed corrupted store at \(storeURL). Attempting to recreate...")
                        
                        container.loadPersistentStores { _, recoveryError in
                            if let recoveryError {
                                let recoveryAppError = AppError(message: "Recovery failed: \(recoveryError.localizedDescription)")
                                self.errorSubject.onNext(recoveryAppError)
                            } else {
                                debugPrint("Core Data stack successfully recovered.")
                            }
                        }
                    } catch {
                        let removalError = AppError(message: "Failed to remove corrupted store: \(error.localizedDescription)")
                        self.errorSubject.onNext(removalError)
                    }
                }
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
}
