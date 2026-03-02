//
//  WebSocketService.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-04.
//

import Foundation
import Starscream

/// Receives raw websocket messages from a device and forwards them to higher-level services.
protocol WebSocketServiceDelegate: AnyObject {
    func didReceiveMessage(_ message: String)
}

/// Lightweight wrapper around Starscream for connecting and sending messages to one WLED host.
class WebSocketService: WebSocketDelegate {
    private var socket: WebSocket?
    weak var delegate: WebSocketServiceDelegate?

    private var isConnected = false

    init(ipAddress: String) {
        var request = URLRequest(url: URL(string: "ws://\(ipAddress)/ws")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.delegate = self
    }

    func connect() {
        socket?.connect()
    }

    func disconnect() {
        socket?.disconnect()
    }

    func sendMessage(_ message: String) {
        if !isConnected {
            connect()
        }

        socket?.write(string: message)
    }

    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected:
            isConnected = true
        case .disconnected:
            isConnected = false
        case .text(let string):
            delegate?.didReceiveMessage(string)
        case .binary:
            break
        case .error:
            isConnected = false
        case .cancelled:
            break
        case .viabilityChanged:
            break
        case .reconnectSuggested(let shouldReconnect):
            if shouldReconnect {
                connect()
            }
        default:
            break
        }
    }
}
