//
//  RadioButton.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct AppRadio: View {

    let title: LocalizedStringKey
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppToken.Spacing.s12) {
                ZStack {
                    Circle()
                        .fill(background)
                    Circle()
                        .strokeBorder(border, lineWidth: AppToken.Border.medium)
                    if isSelected {
                        Circle()
                            .fill(content)
                            .frame(width: AppToken.Scale.primitive12, height: AppToken.Scale.primitive12)
                    }
                }
                .frame(width: AppToken.Scale.primitive28, height: AppToken.Scale.primitive28)

                Text(title)
                    .lineupFont(AppFont.Body.body)
                    .foregroundStyle(label)
            }
            .frame(minHeight: AppToken.Scale.primitive44)
            .contentShape(Rectangle())
        }
        .buttonStyle(AppRadioStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var background: Color {
        if !isSelected {
            return AppColor.SettingRow.Radio.unselectedBackground
        }
        return isEnabled ? AppColor.SettingRow.Radio.background : AppColor.SettingRow.Disabled.selectedBackground
    }

    private var border: Color {
        isEnabled ? AppColor.SettingRow.Radio.border : AppColor.SettingRow.Disabled.border
    }

    private var content: Color {
        isEnabled ? AppColor.SettingRow.Radio.innerCircle : AppColor.SettingRow.Disabled.content
    }

    private var label: Color {
        isEnabled ? AppColor.SettingRow.title : AppColor.SettingRow.Disabled.content
    }
}

struct AppRadioStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

#Preview {
    VStack(alignment: .leading, spacing: AppToken.Spacing.s16) {
        HStack(spacing: AppToken.Spacing.s32) {
            AppRadio(title: "filters.status.available", isSelected: true) {}
            AppRadio(title: "filters.status.available", isSelected: false) {}
        }
        HStack(spacing: AppToken.Spacing.s32) {
            AppRadio(title: "filters.status.available", isSelected: true) {}
                .disabled(true)
            AppRadio(title: "filters.status.available", isSelected: false) {}
                .disabled(true)
        }
    }
    .padding(AppToken.Padding.screen)
}
