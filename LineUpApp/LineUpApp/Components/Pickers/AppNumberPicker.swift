//
//  Picker.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import Foundation
import SwiftUI

struct AppNumberPicker: View {

    var title: LocalizedStringKey? = nil
    @Binding var value: Int
    let minimum: Int
    let maximum: Int

    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        VStack(spacing: AppToken.Spacing.s8) {
            if let title {
                Text(title)
                    .lineupFont(AppFont.Body.section)
                    .foregroundStyle(isEnabled ? AppColor.Picker.text : AppColor.SettingRow.Disabled.content)
            }

            VStack(spacing: AppToken.Spacing.s4) {
                ForEach([-2, -1, 0, 1, 2], id: \.self) { offset in
                    row(number: value + offset, offset: offset)
                }
            }
            .padding(AppToken.Padding.smallCard)
            .frame(width: AppToken.Picker.width)
            .background(
                RoundedRectangle(cornerRadius: AppToken.Radius.small)
                    .fill(AppColor.Picker.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppToken.Radius.small)
                    .strokeBorder(border, lineWidth: AppToken.Border.medium)
            )
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: AppToken.Scale.primitive20)
                    .onEnded { drag in
                        if drag.translation.height < 0 {
                            select(value + 1)
                        } else {
                            select(value - 1)
                        }
                    }
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title ?? "")
        .accessibilityValue(Text(value, format: .number))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                select(value + 1)
            case .decrement:
                select(value - 1)
            default:
                break
            }
        }
    }

    @ViewBuilder
    private func row(number: Int, offset: Int) -> some View {
        if number < minimum || number > maximum {
            Text(number, format: .number)
                .lineupFont(AppFont.Body.body)
                .hidden()
        } else if offset == 0 {
            Text(number, format: .number)
                .lineupFont(AppFont.Title.title2)
                .foregroundStyle(isEnabled ? AppColor.Picker.text : AppColor.SettingRow.Disabled.content)
                .frame(maxWidth: .infinity, minHeight: AppToken.Scale.primitive44)
                .background(
                    Capsule()
                        .fill(isEnabled ? AppColor.Picker.selectedBackground : AppColor.SettingRow.Disabled.selectedBackground)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(border, lineWidth: AppToken.Border.medium)
                )
        } else {
            Text(number, format: .number)
                .lineupFont(AppFont.Body.body)
                .foregroundStyle(neighborColor(offset: offset))
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    select(number)
                }
        }
    }

    private var border: Color {
        isEnabled ? AppColor.Picker.border : AppColor.SettingRow.Disabled.border
    }

    private func neighborColor(offset: Int) -> Color {
        if !isEnabled {
            return AppColor.SettingRow.Disabled.content
        }
        return offset == 1 || offset == -1 ? AppColor.Picker.nearText : AppColor.Picker.farText
    }

    private func select(_ number: Int) {
        if number >= minimum && number <= maximum {
            value = number
        }
    }
}

#Preview {
    VStack(spacing: AppToken.Spacing.s32) {
        AppNumberPicker(title: "booking.places", value: .constant(3), minimum: 1, maximum: 10)
        AppNumberPicker(title: "booking.places", value: .constant(3), minimum: 1, maximum: 10)
            .disabled(true)
    }
    .padding(AppToken.Padding.screen)
}
