//
//  Toggle.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct AppToggle: View {

    var title: LocalizedStringKey? = nil
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            if let title {
                Text(title)
            }
        }
        .toggleStyle(AppToggleStyle(hasTitle: title != nil))
    }
}

struct AppToggleStyle: ToggleStyle {

    let hasTitle: Bool

    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: AppToken.Spacing.s12) {
            if hasTitle {
                configuration.label
                    .lineupFont(AppFont.Body.body)
                    .foregroundStyle(label)
                Spacer()
            }

            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                Capsule()
                    .fill(track(isOn: configuration.isOn))
                Capsule()
                    .strokeBorder(border, lineWidth: AppToken.Border.medium)
                Circle()
                    .fill(knob(isOn: configuration.isOn))
                    .overlay(
                        Circle()
                            .strokeBorder(knobBorder, lineWidth: AppToken.Border.medium)
                    )
                    .frame(width: AppToken.Scale.primitive20, height: AppToken.Scale.primitive20)
                    .padding(AppToken.Padding.toggleTrack.insets)
            }
            .frame(width: AppToken.Scale.primitive52, height: AppToken.Scale.primitive32)
        }
        .frame(minHeight: AppToken.Scale.primitive44)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                configuration.isOn.toggle()
            }
        }
    }

    private func track(isOn: Bool) -> Color {
        if !isOn {
            return AppColor.SettingRow.Toggle.offBackground
        }
        return isEnabled ? AppColor.SettingRow.Toggle.background : AppColor.SettingRow.Disabled.selectedBackground
    }

    private func knob(isOn: Bool) -> Color {
        if isOn {
            return AppColor.SettingRow.Toggle.knob
        }
        return isEnabled ? AppColor.SettingRow.Toggle.offKnob : AppColor.SettingRow.Disabled.content
    }

    private var border: Color {
        isEnabled ? AppColor.SettingRow.Toggle.border : AppColor.SettingRow.Disabled.border
    }

    private var knobBorder: Color {
        isEnabled ? AppColor.SettingRow.Toggle.knobBorder : AppColor.SettingRow.Disabled.border
    }

    private var label: Color {
        isEnabled ? AppColor.SettingRow.title : AppColor.SettingRow.Disabled.content
    }
}

#Preview {
    VStack(spacing: AppToken.Spacing.s16) {
        AppToggle(title: "settings.notif.news", isOn: .constant(true))
        AppToggle(title: "settings.notif.news", isOn: .constant(false))
        AppToggle(title: "settings.notif.news", isOn: .constant(true))
            .disabled(true)
        AppToggle(title: "settings.notif.news", isOn: .constant(false))
            .disabled(true)
        AppToggle(isOn: .constant(true))
    }
    .padding(AppToken.Padding.screen)
}
