//
//  NetworkService.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-06-17.
//

import Foundation
import Combine
import AppKit

enum WLEDServiceError: Error {
    case encodingFailure
}

class WLEDService: WebSocketServiceDelegate {
    var deviceSubject = PassthroughSubject<WLEDDevice, Never>()

    var devicePublisher: AnyPublisher<WLEDDevice, Never> {
        deviceSubject.eraseToAnyPublisher()
    }

    var device: WLEDDevice
    private let webSocketService: WebSocketService

    init(ipAddr: String) {
        self.device = WLEDDevice(
            ipAddress: ipAddr,
            nickname: "",
            isOn: false,
            brightness: 0,
            effect: 0,
            effectSpeed: 0,
            effectSize: 0,
            palette: 0,
            colors: .init(
                colorOne: .init(
                    nsColor: .red
                ),
                colorTwo: .init(
                    nsColor: .green
                ),
                colorThree: .init(
                    nsColor: .blue
                )
            )
        )
        self.webSocketService = WebSocketService(ipAddress: ipAddr)
        self.webSocketService.delegate = self
        webSocketService.connect()
    }

    deinit {
        webSocketService.disconnect()
    }

    func sendStateUpdate(payload: StateUpdatePayload) async throws {
        let jsonData = try JSONEncoder().encode(payload)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw WLEDServiceError.encodingFailure
        }

        webSocketService.sendMessage(jsonString)
    }

    func didReceiveMessage(_ message: String) {
        guard let data = message.data(using: .utf8) else {
            return
        }

        if let ledState = try? JSONDecoder().decode(LEDStateWrapper.self, from: data) {
            self.updateDeviceState(from: ledState.state)
        }
    }

    func getEffects() async throws -> [Effect] {
        let url = URL(string: "http://\(device.ipAddress)/json/effects")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let effectNames = try JSONDecoder().decode([String].self, from: data)
        return effectNames.enumerated().map { Effect(name: $1, index: $0) }
    }

    func getPalettes() async throws -> [Palette] {
        let url = URL(string: "http://\(device.ipAddress)/json/palettes")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let paletteNames = try JSONDecoder().decode([String].self, from: data)
        return paletteNames.enumerated().map { Palette(name: $1, index: $0) }
    }

    private func updateDeviceState(from ledState: LEDState) {
        self.device.isOn = ledState.on
        self.device.brightness = Double(ledState.bri) / 255 * 100
        
        if let segment = ledState.seg.first {
            self.device.effectSpeed = Double(segment.sx) / 255 * 100
            self.device.effectSize = Double(segment.ix) / 255 * 100
            self.device.effect = segment.fx
            self.device.palette = segment.pal
        }

        let colorOne = ledState.seg.first?.col.first ?? [0, 0, 0]
        let colorTwo = ledState.seg.first?.col[1] ?? [0, 0, 0]
        let colorThree = ledState.seg.first?.col[2] ?? [0, 0, 0]
        self.device.colors.colorOne = WLEDColor(nsColor: NSColor(red: CGFloat(colorOne[0]) / 255, green: CGFloat(colorOne[1]) / 255, blue: CGFloat(colorOne[2]) / 255, alpha: 1.0))
        self.device.colors.colorTwo = WLEDColor(nsColor: NSColor(red: CGFloat(colorTwo[0]) / 255, green: CGFloat(colorTwo[1]) / 255, blue: CGFloat(colorTwo[2]) / 255, alpha: 1.0))
        self.device.colors.colorThree = WLEDColor(nsColor: NSColor(red: CGFloat(colorThree[0]) / 255, green: CGFloat(colorThree[1]) / 255, blue: CGFloat(colorThree[2]) / 255, alpha: 1.0))

        self.deviceSubject.send(self.device)
    }

    func disconnect() {
        webSocketService.disconnect()
    }
}
