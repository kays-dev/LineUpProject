//
//  AvatarScreen.swift
//  LineUpApp
//
//  Created by Apprenant174 on 02/11/2026.
//

import Foundation
import SwiftUI

struct AvatarScreen: View {

    @Environment(\.dismiss) private var dismiss
    @AppStorage("selectedAvatar") private var avatar: AppImage.Avatar = .colombina
    @State private var selection: AppImage.Avatar = .colombina

    private let columns = [
        GridItem(.flexible(), spacing: AppToken.Spacing.s12, alignment: .top),
        GridItem(.flexible(), spacing: AppToken.Spacing.s12, alignment: .top),
        GridItem(.flexible(), spacing: AppToken.Spacing.s12, alignment: .top)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: AppToken.Spacing.s28) {
                preview
                grid
            }
            .padding(.horizontal, AppToken.Padding.screen)
        }
        .lineupPageHeading(.secondary(title: "", heading: .avatarTitle, subtitle: .avatarSubtitle)) {}
        .tabBarVisibility(.hidden)
        .safeAreaBar(edge: .bottom) {
            AppButton(title: "common.save", type: .primary, isFullWidth: true) {
                avatar = selection
                dismiss()
            }
            .padding(.horizontal, AppToken.Padding.screen)
        }
        .background(AppColor.Screen.background)
        .onAppear {
            selection = avatar
        }
    }

    private var preview: some View {
        VStack(spacing: AppToken.Spacing.s8) {
            avatarImage(selection, size: AppToken.Avatar.preview)
                .frame(width: AppToken.Avatar.previewRing, height: AppToken.Avatar.previewRing)
                .background(Circle().fill(AppColor.AvatarPicker.previewBackground))
                .overlay {
                    Circle()
                        .strokeBorder(AppColor.AvatarPicker.selectedRing, lineWidth: AppToken.Border.medium)
                }

            Text(selection.name)
                .lineupFont(AppFont.Title.title2)
                .foregroundStyle(AppColor.Text.primary)
        }
        .accessibilityElement(children: .combine)
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: AppToken.Spacing.s16) {
            ForEach(AppImage.Avatar.allCases, id: \.self) { option in
                Button {
                    selection = option
                } label: {
                    gridItem(option)
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(option == selection ? .isSelected : [])
            }
        }
    }

    private func gridItem(_ option: AppImage.Avatar) -> some View {
        let isSelected = option == selection

        return VStack(spacing: AppToken.Spacing.s8) {
            avatarImage(option, size: AppToken.Avatar.grid)
                .frame(width: AppToken.Avatar.gridRing, height: AppToken.Avatar.gridRing)
                .overlay {
                    if isSelected {
                        Circle()
                            .strokeBorder(AppColor.AvatarPicker.selectedRing, lineWidth: AppToken.Border.medium)
                    }
                }

            Text(option.name)
                .lineupFont(isSelected ? AppFont.Label.label : AppFont.Body.body2)
                .foregroundStyle(isSelected ? AppColor.AvatarPicker.selectedName : AppColor.AvatarPicker.name)
                .multilineTextAlignment(.center)
        }
    }

    private func avatarImage(_ option: AppImage.Avatar, size: CGFloat) -> some View {
        option.image
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .strokeBorder(AppColor.AvatarPicker.photoBorder, lineWidth: AppToken.Border.medium)
            }
            .accessibilityHidden(true)
    }
}

#Preview {
    AvatarScreen()
}
