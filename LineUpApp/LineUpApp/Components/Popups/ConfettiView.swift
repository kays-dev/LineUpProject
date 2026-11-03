//
//  ConfettiView.swift
//  LineUpApp
//
//  Created by Apprenant131 on 01/11/2026.
//

import SwiftUI
import UIKit

struct ConfettiView: View {

    private let showSparkles = true
    private let showFlash = true
    private let useHaptics = true

    private let iconBackground: Color = .white

    private static let palette: [Color] = [
        Color(.validation),
        Color(.warning),
        Color(.danger),
        Color.tealPrimary,
    ]
    private let sparkleGold = Color(red: 1.00, green: 0.94, blue: 0.63)

    private let categories: [AppImage.Category] = [
        .theater, .movie, .kids, .musicDance, .photography, .culture,
    ]

    private let duration: Double = 4.0
    private let maxDelay: Double = 0.8

    private let timeScale: Double = 0.65

    private var totalTime: Double { (duration + maxDelay) / timeScale + 0.2 }

    // Traînée plus forte : l'éclatement ralentit vite
    private let drag: CGFloat = 3.0
    // Chute plus lente et plus flottante
    private let terminalFall: CGFloat = 70

    @State private var startTime: TimeInterval? = nil
    @State private var isFinished = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private enum Kind {
        case icon
        case rect
        case dot
        case ribbon
        case star
    }

    private struct Particle: Identifiable {
        let id: Int
        let kind: Kind
        let category: Int
        let color: Color
        let originX: CGFloat
        let originY: CGFloat
        let vx: CGFloat
        let vy: CGFloat
        let delay: Double
        let size: CGFloat
        let spin: Double
        let flipSpeed: Double
        let phase: Double
        let sway: CGFloat
    }

    private struct Jet {
        let x: CGFloat
        let y: CGFloat
        let direction: Double
        let spread: Double
        let minSpeed: CGFloat
        let maxSpeed: CGFloat
        let delay: Double
    }

    private struct Sparkle: Identifiable {
        let id: Int
        let x: CGFloat
        let y: CGFloat
        let start: Double
        let life: Double
        let radius: CGFloat
        let gold: Bool
    }

    private struct SeededRandom: RandomNumberGenerator {
        var state: UInt64
        mutating func next() -> UInt64 {
            state &+= 0x9E37_79B9_7F4A_7C15
            var z = state
            z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
            z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
            return z ^ (z >> 31)
        }
    }

    private static let jets: [Jet] = {
        let up = -Double.pi / 2
        let down = Double.pi / 2
        return [
            // canons bas gauche / bas droite, tirés vers l'intérieur
            Jet(
                x: 0.0,
                y: 1.0,
                direction: up + 0.55,
                spread: 0.35,
                minSpeed: 1400,
                maxSpeed: 2600,
                delay: 0.00
            ),
            Jet(
                x: 1.0,
                y: 1.0,
                direction: up - 0.55,
                spread: 0.35,
                minSpeed: 1400,
                maxSpeed: 2600,
                delay: 0.00
            ),
            // seconde salve, plus verticale, depuis le centre bas
            Jet(
                x: 0.5,
                y: 1.0,
                direction: up,
                spread: 0.5,
                minSpeed: 1200,
                maxSpeed: 2200,
                delay: 0.35
            ),
            // pluie lente depuis le haut
            Jet(
                x: 0.25,
                y: -0.05,
                direction: down,
                spread: 0.6,
                minSpeed: 40,
                maxSpeed: 220,
                delay: 0.7
            ),
            Jet(
                x: 0.75,
                y: -0.05,
                direction: down,
                spread: 0.6,
                minSpeed: 40,
                maxSpeed: 220,
                delay: 0.9
            ),
        ]
    }()

    private let particles: [Particle] = ConfettiView.createParticles()
    private let sparkles: [Sparkle] = ConfettiView.createSparkles()

    private static func createParticles() -> [Particle] {
        var rng = SeededRandom(state: 42)
        let perJet = 30

        var result: [Particle] = []

        for (jetIndex, jet) in jets.enumerated() {
            for i in 0..<perJet {
                let id = jetIndex * perJet + i

                let kind: Kind
                switch id % 10 {
                case 0, 1, 2: kind = .icon
                case 3, 4, 9: kind = .rect
                case 5: kind = .dot
                case 6, 7: kind = .ribbon
                default: kind = .star
                }

                let size: CGFloat
                switch kind {
                case .icon: size = CGFloat.random(in: 38...52, using: &rng)
                case .rect: size = CGFloat.random(in: 16...26, using: &rng)
                case .dot: size = CGFloat.random(in: 12...20, using: &rng)
                case .ribbon: size = CGFloat.random(in: 14...20, using: &rng)
                case .star: size = CGFloat.random(in: 20...32, using: &rng)
                }

                let angle =
                    jet.direction
                    + Double.random(in: -jet.spread...jet.spread, using: &rng)
                let speed = CGFloat.random(
                    in: jet.minSpeed...jet.maxSpeed,
                    using: &rng
                )
                let color = palette[
                    Int.random(in: 0..<palette.count, using: &rng)
                ]

                result.append(
                    Particle(
                        id: id,
                        kind: kind,
                        category: id % 6,
                        color: color,
                        originX: jet.x,
                        originY: jet.y,
                        vx: CGFloat(cos(angle)) * speed,
                        vy: CGFloat(sin(angle)) * speed,
                        delay: jet.delay
                            + Double.random(in: 0...0.1, using: &rng),
                        size: size,
                        spin: Double.random(in: -360...360, using: &rng),
                        flipSpeed: Double.random(in: 3...7, using: &rng),
                        phase: Double.random(in: 0...(2 * .pi), using: &rng),
                        sway: CGFloat.random(in: 15...40, using: &rng)
                    )
                )
            }
        }

        return result
    }

    private static func createSparkles() -> [Sparkle] {
        var rng = SeededRandom(state: 7)

        return (0..<45).map { index in
            Sparkle(
                id: index,
                x: CGFloat.random(in: 0.03...0.97, using: &rng),
                y: CGFloat.random(in: 0.04...0.96, using: &rng),
                start: Double.random(in: 0.3...5.0, using: &rng),
                life: Double.random(in: 1.2...2.2, using: &rng),
                radius: CGFloat.random(in: 5...11, using: &rng),
                gold: Bool.random(using: &rng)
            )
        }
    }

    var body: some View {
        Color.clear.overlay {
            if let startTime, !isFinished, !reduceMotion {
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        draw(
                            in: &context,
                            size: size,
                            date: timeline.date,
                            startTime: startTime
                        )
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .task {
            let start = Date.timeIntervalSinceReferenceDate
            startTime = start
            isFinished = false

            guard !reduceMotion else { return }

            if useHaptics {
                let times = Self.jets.map { $0.delay / timeScale }.sorted()
                for (index, time) in times.enumerated() {
                    let wait =
                        time - (Date.timeIntervalSinceReferenceDate - start)
                    if wait > 0 {
                        try? await Task.sleep(for: .seconds(wait))
                    }
                    if Task.isCancelled { return }
                    fireHaptic(strong: index == 0)
                }
            }

            let remaining =
                totalTime - (Date.timeIntervalSinceReferenceDate - start)
            if remaining > 0 {
                try? await Task.sleep(for: .seconds(remaining))
            }
            if Task.isCancelled { return }
            isFinished = true
        }
    }

    private func fireHaptic(strong: Bool) {
            let generator = UIImpactFeedbackGenerator(
                style: strong ? .heavy : .medium
            )
            generator.impactOccurred()
    }

    private func draw(
        in context: inout GraphicsContext,
        size: CGSize,
        date: Date,
        startTime: TimeInterval
    ) {
        let real = date.timeIntervalSinceReferenceDate - startTime
        let elapsed = real * timeScale

        if showFlash {
            for jet in Self.jets {
                let age = real - jet.delay / timeScale
                guard age >= 0, age < 0.45 else { continue }

                let k = 1 - age / 0.45
                let center = CGPoint(
                    x: size.width * jet.x,
                    y: size.height * jet.y
                )
                let radius = CGFloat(200 * k + 20)
                let rect = CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )
                context.fill(
                    Path(ellipseIn: rect),
                    with: .radialGradient(
                        Gradient(colors: [
                            Color.white.opacity(0.85 * k),
                            Color.white.opacity(0),
                        ]),
                        center: center,
                        startRadius: 0,
                        endRadius: radius
                    )
                )
            }
        }

        let icons = categories.map { context.resolve($0.icon) }

        for particle in particles {
            let time = elapsed - particle.delay
            guard time >= 0, time < duration else { continue }

            let origin = CGPoint(
                x: size.width * particle.originX,
                y: size.height * particle.originY
            )

            let t = CGFloat(time)
            let progress = time / duration

            let decay = (1 - exp(-drag * t)) / drag

            // le balancement s'installe après l'éclatement
            let swayRamp = min(1, t * 1.2)
            let x =
                origin.x + particle.vx * decay
                + particle.sway * swayRamp
                * CGFloat(sin(time * 3 + particle.phase))
            let y =
                origin.y + (particle.vy - terminalFall) * decay + terminalFall
                * t

            let opacity =
                progress < 0.7 ? 1.0 : max(0, 1 - (progress - 0.7) / 0.3)

            var layer = context
            layer.opacity = opacity
            layer.translateBy(x: x, y: y)

            let s = particle.size

            switch particle.kind {

            case .icon:
                layer.rotate(by: .degrees(particle.spin * 0.2 * time))

                let disc = CGRect(
                    x: -s * 0.7,
                    y: -s * 0.7,
                    width: s * 1.4,
                    height: s * 1.4
                )
                layer.fill(Path(ellipseIn: disc), with: .color(iconBackground))

                let rect = CGRect(x: -s / 2, y: -s / 2, width: s, height: s)
                layer.draw(icons[particle.category], in: rect)

            case .rect, .ribbon, .dot, .star:
                let flip = CGFloat(
                    cos(time * particle.flipSpeed + particle.phase)
                )
                layer.rotate(by: .degrees(particle.spin * time))
                layer.scaleBy(x: 1, y: flip)

                let path: Path
                switch particle.kind {
                case .rect:
                    path = Path(
                        CGRect(
                            x: -s / 2,
                            y: -s * 0.28,
                            width: s,
                            height: s * 0.56
                        )
                    )
                case .ribbon:
                    path = Path(
                        CGRect(
                            x: -s * 0.9,
                            y: -s * 0.12,
                            width: s * 1.8,
                            height: s * 0.24
                        )
                    )
                case .dot:
                    path = Path(
                        ellipseIn: CGRect(
                            x: -s / 2,
                            y: -s / 2,
                            width: s,
                            height: s
                        )
                    )
                default:
                    path = starPath(radius: s / 2)
                }

                layer.fill(path, with: .color(particle.color))
            }
        }

        if showSparkles {
            for sparkle in sparkles {
                let age = real - sparkle.start
                guard age >= 0, age < sparkle.life else { continue }

                // Apparition puis disparition douce, avec un scintillement rapide
                let k = sin(age / sparkle.life * .pi)
                let twinkle =
                    0.55 + 0.45 * sin(age * 14 + Double(sparkle.x) * 10)

                var layer = context
                layer.opacity = k * twinkle
                layer.translateBy(
                    x: size.width * sparkle.x,
                    y: size.height * sparkle.y
                )

                let radius = sparkle.radius * CGFloat(0.6 + 0.6 * k)
                layer.fill(
                    sparklePath(radius: radius),
                    with: .color(sparkle.gold ? sparkleGold : .white)
                )
            }
        }
    }

    private func starPath(radius: CGFloat) -> Path {
        var path = Path()
        let points = 5
        for i in 0..<(points * 2) {
            let r = i.isMultiple(of: 2) ? radius : radius * 0.45
            let a = Double(i) * .pi / Double(points) - .pi / 2
            let p = CGPoint(x: CGFloat(cos(a)) * r, y: CGFloat(sin(a)) * r)
            if i == 0 {
                path.move(to: p)
            } else {
                path.addLine(to: p)
            }
        }
        path.closeSubpath()
        return path
    }

    private func sparklePath(radius r: CGFloat) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: -r))
        path.addQuadCurve(to: CGPoint(x: r, y: 0), control: .zero)
        path.addQuadCurve(to: CGPoint(x: 0, y: r), control: .zero)
        path.addQuadCurve(to: CGPoint(x: -r, y: 0), control: .zero)
        path.addQuadCurve(to: CGPoint(x: 0, y: -r), control: .zero)
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Color.mintPrimary.ignoresSafeArea()
        ConfettiView()
    }
}
