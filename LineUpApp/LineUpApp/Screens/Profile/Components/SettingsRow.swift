//
//  SettingsRow.swift
//  LineUpApp
//
//  Created by Apprenant174 on 31/10/2026.
//

import Foundation
import SwiftUI

enum SettingsRowAccessory {
    case chevron
    case toggle(Binding<Bool>)
    case value(String)
}

struct SettingsRow: View {

    var icon: Image? = nil
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey? = nil
    let accessory: SettingsRowAccessory
    var showsSeparator: Bool = true

    var body: some View {
        HStack(spacing: AppToken.Spacing.s12) {
            if let icon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: AppToken.Scale.primitive20, height: AppToken.Scale.primitive20)
                    .foregroundStyle(AppColor.SettingRow.Icon.icon)
                    .frame(width: AppToken.Scale.primitive32, height: AppToken.Scale.primitive32)
                    .background(
                        RoundedRectangle(cornerRadius: AppToken.Radius.xsmall)
                            .fill(AppColor.SettingRow.Icon.background)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: AppToken.Radius.xsmall)
                            .strokeBorder(AppColor.SettingRow.Icon.border, lineWidth: AppToken.Border.thin)
                    )
            }

            VStack(alignment: .leading, spacing: AppToken.Spacing.none) {
                Text(title)
                    .lineupFont(AppFont.Body.body)
                    .foregroundStyle(AppColor.SettingRow.title)
                if let subtitle {
                    Text(subtitle)
                        .lineupFont(AppFont.Body.caption)
                        .foregroundStyle(AppColor.SettingRow.descriptionAndChevron)
                }
            }

            Spacer()

            accessoryView
        }
        .padding(AppToken.Padding.settingsRow)
        .background(AppColor.SettingRow.background)
        .overlay(alignment: .bottom) {
            if showsSeparator {
                Rectangle()
                    .fill(AppColor.SettingRow.separator)
                    .frame(height: AppToken.Border.thin)
            }
        }
    }

    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .chevron:
            chevron
        case .toggle(let isOn):
            AppToggle(isOn: isOn)
                .accessibilityLabel(Text(title))
        case .value(let value):
            HStack(spacing: AppToken.Spacing.s4) {
                Text(value)
                    .lineupFont(AppFont.Body.body2)
                    .foregroundStyle(AppColor.SettingRow.descriptionAndChevron)
                chevron
            }
        }
    }

    private var chevron: some View {
        AppImage.Icon.forward.image
            .resizable()
            .scaledToFit()
            .frame(width: AppToken.Scale.primitive12, height: AppToken.Scale.primitive12)
            .foregroundStyle(AppColor.SettingRow.descriptionAndChevron)
            .frame(width: AppToken.Scale.primitive20, height: AppToken.Scale.primitive20)
    }
}

#Preview {
    VStack(spacing: AppToken.Spacing.s32) {
        SettingsRow(
            icon: AppImage.InterfaceIcon.personSquareDuotone.image,
            title: "settings.avatar",
            subtitle: "settings.avatar.subtitle",
            accessory: .chevron
        )
        SettingsRow(
            icon: AppImage.InterfaceIcon.bellDuotone.image,
            title: "settings.notif.spot",
            subtitle: "settings.notif.spot.subtitle",
            accessory: .toggle(.constant(true))
        )
        SettingsRow(
            icon: AppImage.InterfaceIcon.infoDuotone.image,
            title: "settings.language",
            accessory: .value("Français")
        )
    }
    .padding(AppToken.Padding.screen)
}
