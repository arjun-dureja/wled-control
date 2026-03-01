//
//  FooterView.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2024-07-04.
//

import SwiftUI

struct FooterView: View {
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Text("WLEDControl")
                Spacer()
                Text("Quit")
                    .opacity(0.8)
            }
            .padding()
        }
    }
}
