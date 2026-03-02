//
//  DiscoveryService.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-01.
//

import Network
import SwiftUI
import Combine

/// Discovers WLED devices on the local network via Bonjour and publishes discovery state/results.
class WLEDDiscoveryService {
    private var browser: NWBrowser?
    private let devicesSubject = CurrentValueSubject<Set<DiscoveredDevice>, Never>(Set())
    private let stateSubject = CurrentValueSubject<DiscoveryState, Never>(.idle)

    enum DiscoveryState {
        case idle
        case discovering
        case error(String)
    }

    var devicesPublisher: AnyPublisher<Set<DiscoveredDevice>, Never> {
        devicesSubject.eraseToAnyPublisher()
    }

    var statePublisher: AnyPublisher<DiscoveryState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    func startDiscovery() {
        let parameters = NWParameters()
        let bonjourType = "_wled._tcp"
        let bonjourDomain = "local."

        browser = NWBrowser(for: .bonjour(type: bonjourType, domain: bonjourDomain), using: parameters)

        browser?.stateUpdateHandler = { [weak self] newState in
            switch newState {
            case .ready:
                self?.stateSubject.send(.discovering)
            case .failed(let error):
                self?.stateSubject.send(.error(error.localizedDescription))
            case .cancelled:
                self?.stateSubject.send(.idle)
            default:
                break
            }
        }

        browser?.browseResultsChangedHandler = { [weak self] results, changes in
            for result in results {
                if case let .service(name, _, _, _) = result.endpoint {
                    let connection = NWConnection(to: result.endpoint, using: .tcp)
                    connection.stateUpdateHandler = { state in
                        switch state {
                        case .ready:
                            if let innerEndpoint = connection.currentPath?.remoteEndpoint,
                               case .hostPort(let host, _) = innerEndpoint {
                                let remoteHost = "\(host)".split(separator: "%")[0]

                                let device = DiscoveredDevice(
                                    name: name,
                                    host: String(remoteHost)
                                )
                                self?.devicesSubject.send((self?.devicesSubject.value.union([device]))!)
                            }
                        default:
                            break
                        }
                    }
                    connection.start(queue: .global())
                }
            }
        }

        browser?.start(queue: .main)
    }

    func stopDiscovery() {
        browser?.cancel()
        browser = nil
        stateSubject.send(.idle)
    }

    deinit {
        stopDiscovery()
    }
}
