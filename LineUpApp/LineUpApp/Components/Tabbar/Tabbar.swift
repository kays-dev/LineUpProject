//
//  Tabbar.swift
//  LineUpApp
//
//  Created by Apprenant174 on 27/10/2026.
//

import SwiftUI

struct TabBar: View {
    
    @Binding var selection: LineUpTab
    let avatar: Image
    
    // Position et forme de l'encoche (animées)
    @State private var notchX: CGFloat = 151
    @State private var notchWidth: CGFloat = 102
    @State private var notchDepth: CGFloat = 1
    @State private var showsBubble = true
    @State private var isAnimating = false
    
    @State private var transitTabs: Set<LineUpTab> = []
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            // Pill
            ZStack {
                
                Capsule()
                    .fill(Color.ink)
                
                TabBarNotch(kind: .notch, centerX: notchX, width: notchWidth, depth: notchDepth)
                    .blendMode(.destinationOut)
                
            }
            .compositingGroup()
            
            // Vague
            TabBarNotch(kind: .wave, centerX: notchX, width: notchWidth, depth: notchDepth)
                .fill(Color.tealPrimary)
                .clipShape(Capsule())
            
            // Onglets au repos
            ForEach(LineUpTab.allCases, id: \.self) { tab in
                
                TabBarItem(tab: tab, avatar: avatar) {
                    select(tab)
                }
                .opacity((tab == selection && showsBubble) || transitTabs.contains(tab) ? 0 : 1)
                .offset(x: 4 + 96 * CGFloat(tab.rawValue))
                .accessibilityAddTraits(tab == selection ? .isSelected : [])
                
            }
            
            // Onglet actif
            ZStack {
                
                if selection == .aparte {
                    avatar
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .overlay(Circle().strokeBorder(Color.redPrimary, lineWidth: 2)) //
                } else {
                    
                    Circle()
                        .fill(Color.redPrimary)
                        .overlay(Circle().strokeBorder(Color.ink, lineWidth: 2))
                    
                    selection.activeIcon
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(AppColor.Text.secondary)
                    
                }
                
            }
            .frame(width: 36, height: 36)
            .scaleEffect(showsBubble ? 1 : 0.4)
            .opacity(showsBubble ? 1 : 0)
            .offset(x: notchX - 18, y: 4)
            .allowsHitTesting(false)
            
        }
        .frame(width: 302, height: 62)
        .padding(.top, 41)
        .frame(maxWidth: .infinity)
        .background {
            
            ZStack {
                
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .mask(LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom))
                
                LinearGradient(
                    stops: [
                        .init(color: .mintPrimary.opacity(0), location: 0),
                        .init(color: .mintPrimary, location: 0.28)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
            }
            .ignoresSafeArea(edges: .bottom)
            
        }
        .onAppear {
            notchX = 55 + 96 * CGFloat(selection.rawValue)
        }
        
    }
    
    // Animation
    private func select(_ tab: LineUpTab) {
        
        guard tab != selection, !isAnimating else {
            return
        }
        
        // Calul de la transition en fonction de la position sélectionnée
        let from = 55 + 96 * CGFloat(selection.rawValue)
        let to = 55 + 96 * CGFloat(tab.rawValue)
        let range = min(selection.rawValue, tab.rawValue)...max(selection.rawValue, tab.rawValue)
        
        transitTabs = reduceMotion ? [] : Set(LineUpTab.allCases.filter {
            range.contains($0.rawValue)
        })
        selection = tab
        
        guard !reduceMotion else {
            
            notchX = to
            return
            
        }
        
        // Transitions
        isAnimating = true
        Task { @MainActor in
            
            // 1. Houle - l'encoche se soulève et file à mi-chemin
            withAnimation(.timingCurve(0.3, 0, 0.2, 1, duration: 0.18)) {
                showsBubble = false
                notchX = (from + to) / 2
                notchWidth = 102 * 1.3
                notchDepth = 0.7
            }
            try? await Task.sleep(for: .milliseconds(180))
            
            // 2. Creux - elle plonge à l'arrivée, en dépassant à peine
            withAnimation(.timingCurve(0.45, 0, 0.55, 1, duration: 0.2)) {
                notchX = to + (to > from ? 1 : -1) * 0.02 * 102
                notchWidth = 102 * 1.04
                notchDepth = 1.04
            }
            try? await Task.sleep(for: .milliseconds(200))
            
            // 3. Arrivée - elle se pose en douceur, la bulle et les onglets traversés réapparaissent
            withAnimation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.45)) {
                notchX = to
                notchWidth = 102
                notchDepth = 1
                showsBubble = true
                transitTabs = []
            }
            
            isAnimating = false
        }
        
    }
    
}

// MARK: Encoche et vague
struct TabBarNotch: Shape {
    
    enum Kind {
        
        case notch
        case wave
        
    }
    
    var kind: Kind
    var centerX: CGFloat
    var width: CGFloat
    var depth: CGFloat
    
    var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>> {
        get { AnimatablePair(centerX, AnimatablePair(width, depth)) }
        set {
            centerX = newValue.first
            width = newValue.second.first
            depth = newValue.second.second
        }
        
    }
    
    func path(in rect: CGRect) -> Path {
        
        let left = centerX - width / 2
        let scale = width / 102
        
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: left + x * scale, y: y * depth)
        }
        
        var path = Path()
        switch kind {
        case .notch:
            path.move(to: p(102, 0))
            path.addCurve(to: p(51, 51), control1: p(85, 0), control2: p(92, 51))
            path.addCurve(to: p(0, 0), control1: p(10, 51), control2: p(16, 0))
            path.addCurve(to: p(51, -9), control1: p(0, -19.88), control2: p(27.5, -17))
            path.addCurve(to: p(102, 0), control1: p(75.5, -15.5), control2: p(102, -19.88))
        case .wave:
            path.move(to: p(102, 0))
            path.addCurve(to: p(51, 51), control1: p(85, 0), control2: p(92, 51))
            path.addCurve(to: p(0, 0), control1: p(10, 51), control2: p(16, 0))
            path.addCurve(to: p(51, 31), control1: p(23.5, 0), control2: p(28, 31))
            path.addCurve(to: p(102, 0), control1: p(74, 31), control2: p(78.5, 0))
        }
        
        path.closeSubpath()
        
        return path
    }
    
}

// MARK: Visibilité dans les écrans
enum TabBarVisibility {
    
    case visible
    case hidden
    
}

struct TabBarVisibilityPreferenceKey: PreferenceKey {
    
    static let defaultValue: TabBarVisibility = .visible
    
    static func reduce(value: inout TabBarVisibility, nextValue: () -> TabBarVisibility) {
        
        if nextValue() == .hidden {
            
            value = .hidden
            
        }
        
    }
    
}

// MARK: - Aperçu

#Preview {
    @Previewable @State var selection: LineUpTab = .affiche
    
    ScrollView {
        Text("Contenu de l'écran")
            .frame(maxWidth: .infinity, minHeight: 1200, alignment: .top)
    }
    .background(Color.mintPrimary)
    .safeAreaInset(edge: .bottom, spacing: 0) {
        TabBar(selection: $selection, avatar: Image("avatar-colombina"))
    }
}
