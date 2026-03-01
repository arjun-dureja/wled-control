//
//  DeviceRow.swift
//  WLEDControl
//
//  Created by Arjun Dureja on 2025-02-28.
//

import SwiftUI

struct DeviceRow<Icon: View, Subtitle: View, Trailing: View>: View {
    let icon: Icon
    let title: String
    let subtitle: Subtitle
    let titleColor: Color
    let trailing: Trailing

    init(
        @ViewBuilder icon: () -> Icon,
        title: String,
        @ViewBuilder subtitle: () -> Subtitle,
        titleColor: Color = .primary,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.icon = icon()
        self.title = title
        self.subtitle = subtitle()
        self.titleColor = titleColor
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 8) {
            icon
                .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(titleColor)
                subtitle
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            trailing
        }
        .padding(12)
        .cardBackground()
    }
}

extension DeviceRow where Subtitle == Text {
    init(
        @ViewBuilder icon: () -> Icon,
        title: String,
        subtitle: String,
        titleColor: Color = .primary,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(
            icon: icon,
            title: title,
            subtitle: { Text(subtitle) },
            titleColor: titleColor,
            trailing: trailing
        )
    }
}
