//
//  LEDState.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2023-11-25.
//

import Foundation

struct LEDStateWrapper: Codable {
    let state: LEDState
}

struct LEDState: Codable {
    let on: Bool
    let bri, transition, ps, pl: Int
    let nl: Nl
    let udpn: Udpn
    let lor, mainseg: Int
    let seg: [Seg]

    struct Nl: Codable {
        let on: Bool
        let dur, mode, tbri, rem: Int
    }

    struct Udpn: Codable {
        let send, recv: Bool
    }

    struct Seg: Codable {
        let id, start, stop, len: Int
        let grp, spc, of: Int
        let on, frz: Bool
        let bri, cct: Int
        let col: [[Int]]
        let fx, sx, ix, pal: Int
        let sel, rev, mi: Bool
    }
}

struct StateUpdatePayload: Codable {
    let on: Bool?
    let bri, transition, ps, pl: Int?
    let nl: Nl?
    let udpn: Udpn?
    let lor, mainseg: Int?
    let seg: [Seg]?

    struct Nl: Codable {
        let on: Bool?
        let dur, mode, tbri, rem: Int?
    }

    struct Udpn: Codable {
        let send, recv: Bool?
    }

    struct Seg: Codable {
        let id, start, stop, len: Int?
        let grp, spc, of: Int?
        let on, frz: Bool?
        let bri, cct: Int?
        let col: [[Int]]?
        let fx, sx, ix, pal: Int?
        let sel, rev, mi: Bool?

        init(
            id: Int? = nil,
            start: Int? = nil,
            stop: Int? = nil,
            len: Int? = nil,
            grp: Int? = nil,
            spc: Int? = nil,
            of: Int? = nil,
            on: Bool? = nil,
            frz: Bool? = nil,
            bri: Int? = nil,
            cct: Int? = nil,
            col: [[Int]]? = nil,
            fx: Int? = nil,
            sx: Int? = nil,
            ix: Int? = nil,
            pal: Int? = nil,
            sel: Bool? = nil,
            rev: Bool? = nil,
            mi: Bool? = nil
        ) {
            self.id = id
            self.start = start
            self.stop = stop
            self.len = len
            self.grp = grp
            self.spc = spc
            self.of = of
            self.on = on
            self.frz = frz
            self.bri = bri
            self.cct = cct
            self.col = col
            self.fx = fx
            self.sx = sx
            self.ix = ix
            self.pal = pal
            self.sel = sel
            self.rev = rev
            self.mi = mi
        }
    }

    init(
        on: Bool? = nil,
        bri: Int? = nil,
        transition: Int? = nil,
        ps: Int? = nil,
        pl: Int? = nil,
        nl: Nl? = nil,
        udpn: Udpn? = nil,
        lor: Int? = nil,
        mainseg: Int? = nil,
        seg: [Seg]? = nil
    ) {
        self.on = on
        self.bri = bri
        self.transition = transition
        self.ps = ps
        self.pl = pl
        self.nl = nl
        self.udpn = udpn
        self.lor = lor
        self.mainseg = mainseg
        self.seg = seg
    }
}
