//
//  NetworkMonitorServiceImplementation.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 09/12/2024.
//

import Network
import RxSwift

protocol NetworkMonitorService {
    var isNetworkAvailable: Observable<Bool> { get }
    
    func start()
}

final class NetworkMonitorServiceImplementation: NetworkMonitorService {
    // TODO: - Hide monitor?
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    private let networkStatusSubject = BehaviorSubject<Bool>(value: false)
    
    var isNetworkAvailable: Observable<Bool> {
        networkStatusSubject.asObservable()
    }
    
    init(monitor: NWPathMonitor = NWPathMonitor()) {
        self.monitor = monitor
    }
    
    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let isAvailable = path.status == .satisfied
            networkStatusSubject.onNext(isAvailable)
        }
        
        monitor.start(queue: queue)
    }
}
