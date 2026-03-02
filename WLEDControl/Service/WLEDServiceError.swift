//
//  WLEDServiceError.swift
//  WLEDControl
//
//  Created by Codex on 2026-03-02.
//

import Foundation

/// Defines network-layer errors emitted by `WLEDService`.
enum WLEDServiceError: Error {
    case encodingFailure
    case invalidEndpointURL(String)
}
