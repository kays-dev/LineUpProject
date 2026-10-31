//
//  PrimaryButton.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

enum ButtonType {
    case primary
    case secondary
    case text
    case link
    case iconFilled
    case iconOutline
    case back
}

enum ButtonShape {
    case round
    case radius16
}

enum ButtonTone {
    case normal
    case danger
    case warning
    case success
}

enum ButtonStatus {
    case idle
    case loading
    case confirmed
}

struct AppButton: View {

    var title: LocalizedStringKey? = nil
    var icon: Image? = nil
    let type: ButtonType
    var shape: ButtonShape = .round
    var tone: ButtonTone = .normal
    var status: ButtonStatus = .idle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(AppButtonStyle(type: type, shape: shape, tone: tone, status: status))
        .accessibilityValue(statusText)
    }

    @ViewBuilder
    private var content: some View {
        switch type {
        case .back:
            iconImage(AppImage.Icon.back.image, size: AppToken.Scale.primitive16)
                .accessibilityLabel(Text("common.back"))
        case .iconFilled, .iconOutline:
            if let icon, let title {
                iconImage(icon)
                    .accessibilityLabel(Text(title))
            } else if let icon {
                iconImage(icon)
            }
        case .primary, .secondary, .text, .link:
            HStack(spacing: AppToken.Spacing.s8) {
                if let icon {
                    iconImage(icon, size: AppToken.Scale.primitive16)
                }
                if let title {
                    Text(title)
                }
            }
        }
    }

    private var statusText: LocalizedStringKey {
        switch status {
        case .idle:
            ""
        case .loading:
            "common.loading"
        case .confirmed:
            "common.done"
        }
    }

    private func iconImage(_ image: Image, size: CGFloat = AppToken.Scale.primitive24) -> some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

struct AppButtonStyle: ButtonStyle {

    let type: ButtonType
    let shape: ButtonShape
    let tone: ButtonTone
    let status: ButtonStatus

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .lineupFont(type == .link ? AppFont.Body.link : AppFont.Label.label)
            .underline(type == .link)
            .opacity(status == .idle ? 1 : 0)
            .overlay {
                statusIndicator(isPressed: configuration.isPressed)
            }
            .foregroundStyle(foreground(isPressed: configuration.isPressed))
            .padding(padding)
            .frame(minWidth: minWidth, minHeight: minHeight)
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(background(isPressed: configuration.isPressed))
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(border(isPressed: configuration.isPressed), lineWidth: AppToken.Border.medium)
            )
            .overlay(
                RoundedRectangle(cornerRadius: radius + AppToken.FocusRing.offset)
                    .stroke(AppColor.Button.focusRing, lineWidth: AppToken.Border.medium)
                    .padding(-AppToken.FocusRing.offset)
                    .opacity(isFocused ? 1 : 0)
            )
            .contentShape(Rectangle())
    }

    @ViewBuilder
    private func statusIndicator(isPressed: Bool) -> some View {
        switch status {
        case .idle:
            EmptyView()
        case .loading:
            ProgressView()
                .controlSize(.small)
                .tint(foreground(isPressed: isPressed))
        case .confirmed:
            AppImage.Icon.check.image
                .resizable()
                .scaledToFit()
                .fontWeight(.bold)
                .frame(width: AppToken.Scale.primitive16, height: AppToken.Scale.primitive16)
                .foregroundStyle(foreground(isPressed: isPressed))
        }
    }

    private var isIconButton: Bool {
        type == .iconFilled || type == .iconOutline || type == .back
    }

    private var radius: CGFloat {
        shape == .round ? AppToken.Radius.full : AppToken.Radius.small
    }

    private var padding: EdgeInsets {
        switch type {
        case .primary, .secondary:
            AppToken.Padding.button
        case .text:
            AppToken.Padding.buttonText
        case .link, .iconFilled, .iconOutline, .back:
            AppToken.Padding.none.insets
        }
    }

    private var minWidth: CGFloat? {
        isIconButton ? AppToken.Scale.primitive44 : nil
    }

    private var minHeight: CGFloat {
        type == .primary || type == .secondary ? AppToken.Scale.primitive48 : AppToken.Scale.primitive44
    }

    private func background(isPressed: Bool) -> Color {
        if type == .text || type == .link {
            return .clear
        }
        if !isEnabled {
            return AppColor.Button.Disabled.background
        }
        if isPressed {
            return AppColor.Button.Pressed.background
        }
        if status == .confirmed {
            return AppColor.Button.Confirmed.background
        }
        switch type {
        case .primary:
            switch tone {
            case .normal:
                return AppColor.Button.Primary.background
            case .danger:
                return AppColor.Button.Danger.background
            case .warning:
                return AppColor.Button.Warning.background
            case .success:
                return AppColor.Button.Success.background
            }
        case .iconFilled:
            return AppColor.Button.Primary.background
        default:
            return AppColor.Button.Secondary.background
        }
    }

    private func foreground(isPressed: Bool) -> Color {
        if type == .text {
            if !isEnabled {
                return AppColor.Button.Text.disabled
            }
            if tone == .danger {
                return isPressed ? AppColor.Button.ghostDangerTextPressed : AppColor.Button.ghostDangerText
            }
            return isPressed ? AppColor.Button.Text.pressed : AppColor.Button.Text.text
        }
        if type == .link {
            if !isEnabled {
                return AppColor.Button.Link.disabled
            }
            return isPressed ? AppColor.Button.Link.pressed : AppColor.Button.Link.text
        }
        if !isEnabled {
            return AppColor.Button.Disabled.text
        }
        if isPressed {
            return AppColor.Button.Pressed.text
        }
        if status == .confirmed {
            return AppColor.Button.Confirmed.text
        }
        switch type {
        case .primary:
            switch tone {
            case .normal:
                return AppColor.Button.Primary.text
            case .danger:
                return AppColor.Button.Danger.text
            case .warning:
                return AppColor.Button.Warning.text
            case .success:
                return AppColor.Button.Success.text
            }
        case .iconFilled:
            return AppColor.Button.Primary.text
        default:
            return AppColor.Button.Secondary.text
        }
    }

    private func border(isPressed: Bool) -> Color {
        if type == .text || type == .link {
            return .clear
        }
        if !isEnabled {
            return AppColor.Button.Disabled.border
        }
        if isPressed {
            return AppColor.Button.Pressed.border
        }
        if status == .confirmed {
            return AppColor.Button.Confirmed.border
        }
        switch type {
        case .primary:
            switch tone {
            case .normal:
                return AppColor.Button.Primary.border
            case .danger:
                return AppColor.Button.Danger.border
            case .warning:
                return AppColor.Button.Warning.border
            case .success:
                return AppColor.Button.Success.border
            }
        case .iconFilled:
            return AppColor.Button.Primary.border
        default:
            return AppColor.Button.Secondary.border
        }
    }
}

#Preview {
    ScrollView([.vertical, .horizontal]) {
        VStack(alignment: .leading, spacing: AppToken.Spacing.s16) {
            ForEach([ButtonShape.round, ButtonShape.radius16], id: \.self) { shape in
                HStack {
                    AppButton(title: "common.save", type: .primary, shape: shape) {}
                    AppButton(title: "common.save", type: .primary, shape: shape) {}
                        .disabled(true)
                    AppButton(title: "common.save", type: .primary, shape: shape, status: .loading) {}
                    AppButton(title: "common.save", type: .primary, shape: shape, status: .confirmed) {}
                }
                HStack {
                    AppButton(title: "common.save", type: .secondary, shape: shape) {}
                    AppButton(title: "common.save", type: .secondary, shape: shape) {}
                        .disabled(true)
                    AppButton(title: "common.save", type: .secondary, shape: shape, status: .loading) {}
                    AppButton(title: "common.save", type: .secondary, shape: shape, status: .confirmed) {}
                }
                ForEach([ButtonTone.danger, ButtonTone.warning, ButtonTone.success], id: \.self) { tone in
                    HStack {
                        AppButton(title: "common.save", type: .primary, shape: shape, tone: tone) {}
                        AppButton(title: "common.save", type: .primary, shape: shape, tone: tone) {}
                            .disabled(true)
                        AppButton(title: "common.save", type: .primary, shape: shape, tone: tone, status: .loading) {}
                    }
                }
                HStack {
                    AppButton(title: "common.share", icon: AppImage.Icon.share.image, type: .iconFilled, shape: shape) {}
                    AppButton(title: "common.share", icon: AppImage.Icon.share.image, type: .iconFilled, shape: shape) {}
                        .disabled(true)
                    AppButton(title: "common.share", icon: AppImage.Icon.share.image, type: .iconOutline, shape: shape) {}
                    AppButton(title: "common.share", icon: AppImage.Icon.share.image, type: .iconOutline, shape: shape) {}
                        .disabled(true)
                    AppButton(type: .back, shape: shape) {}
                    AppButton(type: .back, shape: shape) {}
                        .disabled(true)
                }
            }
            HStack {
                AppButton(title: "common.cancel", type: .text) {}
                AppButton(title: "common.cancel", type: .text) {}
                    .disabled(true)
                AppButton(title: "common.cancel", type: .text, tone: .danger) {}
            }
            HStack {
                AppButton(title: "common.close", type: .link) {}
                AppButton(title: "common.close", type: .link) {}
                    .disabled(true)
            }
        }
        .padding(AppToken.Padding.screen)
    }
}
