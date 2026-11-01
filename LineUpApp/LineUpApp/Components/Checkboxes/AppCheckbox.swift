//
//  Checkboxe.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct AppCheckbox: View {

    var title: LocalizedStringKey? = nil
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            if let title {
                Text(title)
            }
        }
        .toggleStyle(AppCheckboxStyle())
    }
}

struct AppCheckboxStyle: ToggleStyle {

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: AppToken.Spacing.s12) {
            ZStack {
                RoundedRectangle(cornerRadius: AppToken.Radius.xsmall)
                    .fill(background(isOn: configuration.isOn))
                RoundedRectangle(cornerRadius: AppToken.Radius.xsmall)
                    .strokeBorder(border, lineWidth: AppToken.Border.medium)
                if configuration.isOn {
                    AppImage.Icon.check.image
                        .resizable()
                        .scaledToFit()
                        .fontWeight(.bold)
                        .frame(width: AppToken.Scale.primitive16, height: AppToken.Scale.primitive16)
                        .foregroundStyle(content)
                }
            }
            .frame(width: AppToken.Scale.primitive28, height: AppToken.Scale.primitive28)

            configuration.label
                .lineupFont(AppFont.Body.body)
                .foregroundStyle(label)
        }
        .frame(minHeight: AppToken.Scale.primitive44)
        .contentShape(Rectangle())
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }

    private func background(isOn: Bool) -> Color {
        if !isOn {
            return AppColor.SettingRow.Checkbox.uncheckedBackground
        }
        return isEnabled ? AppColor.SettingRow.Checkbox.background : AppColor.SettingRow.Disabled.selectedBackground
    }

    private var border: Color {
        isEnabled ? AppColor.SettingRow.Checkbox.border : AppColor.SettingRow.Disabled.border
    }

    private var content: Color {
        isEnabled ? AppColor.SettingRow.Checkbox.icon : AppColor.SettingRow.Disabled.content
    }

    private var label: Color {
        isEnabled ? AppColor.SettingRow.title : AppColor.SettingRow.Disabled.content
    }
}

#Preview {
    VStack(alignment: .leading, spacing: AppToken.Spacing.s16) {
        HStack(spacing: AppToken.Spacing.s32) {
            AppCheckbox(title: "filters.status.available", isOn: .constant(true))
            AppCheckbox(title: "filters.status.available", isOn: .constant(false))
        }
        HStack(spacing: AppToken.Spacing.s32) {
            AppCheckbox(title: "filters.status.available", isOn: .constant(true))
                .disabled(true)
            AppCheckbox(title: "filters.status.available", isOn: .constant(false))
                .disabled(true)
        }
    }
    .padding(AppToken.Padding.screen)
}
