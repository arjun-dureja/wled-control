//
//  NetworkService.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-06-17.
//

import Foundation
import Combine
import AppKit

/// Handles direct WLED API IO (websocket + REST) and maps wire payloads into `WLEDDevice` updates.
class WLEDService: WebSocketServiceDelegate {
    private enum Endpoint: String {
        case effects
        case palettes

        var path: String {
            "/json/\(rawValue)"
        }
    }

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
        let effectNames = try await fetchNames(for: .effects)
        return effectNames.enumerated().map { Effect(name: $1, index: $0) }
    }

    func getPalettes() async throws -> [Palette] {
        let paletteNames = try await fetchNames(for: .palettes)
        return paletteNames.enumerated().map { Palette(name: $1, index: $0) }
    }

    private func updateDeviceState(from ledState: LEDState) {
        device.isOn = ledState.on
        device.brightness = percentage(fromByte: ledState.bri)
        applySegmentState(ledState.seg.first)
        deviceSubject.send(device)
    }

    func disconnect() {
        webSocketService.disconnect()
    }

    private func fetchNames(for endpoint: Endpoint) async throws -> [String] {
        let url = try endpointURL(for: endpoint)
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([String].self, from: data)
    }

    private func endpointURL(for endpoint: Endpoint) throws -> URL {
        var components = URLComponents()
        components.scheme = "http"
        components.host = device.ipAddress
        components.path = endpoint.path

        guard let url = components.url else {
            throw WLEDServiceError.invalidEndpointURL(endpoint.path)
        }
        return url
    }

    private func applySegmentState(_ segment: LEDState.Seg?) {
        if let segment {
            device.effectSpeed = percentage(fromByte: segment.sx)
            device.effectSize = percentage(fromByte: segment.ix)
            device.effect = segment.fx
            device.palette = segment.pal
        }

        device.colors.colorOne = wledColor(from: rgbValue(at: 0, in: segment))
        device.colors.colorTwo = wledColor(from: rgbValue(at: 1, in: segment))
        device.colors.colorThree = wledColor(from: rgbValue(at: 2, in: segment))
    }

    private func percentage(fromByte value: Int) -> Double {
        Double(value) / 255 * 100
    }

    private func rgbValue(at index: Int, in segment: LEDState.Seg?) -> [Int] {
        guard let colors = segment?.col, colors.indices.contains(index) else {
            return [0, 0, 0]
        }
        return colors[index]
    }

    private func wledColor(from rgb: [Int]) -> WLEDColor {
        let red = CGFloat(rgb.indices.contains(0) ? rgb[0] : 0) / 255
        let green = CGFloat(rgb.indices.contains(1) ? rgb[1] : 0) / 255
        let blue = CGFloat(rgb.indices.contains(2) ? rgb[2] : 0) / 255

        return WLEDColor(
            nsColor: NSColor(
                red: red,
                green: green,
                blue: blue,
                alpha: 1.0
            )
        )
    }
}
