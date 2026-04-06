//
        //
    //  Project: PaywallDemo_SwiftUI
    //  File: AdvancedPaywallView.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    


import SwiftUI
import StoreKit

// MARK: - AdvancedPaywallView
// Production-ready paywall with animated background, per-feature highlights,
// plan toggle, social proof, and contextual trigger support
struct AdvancedPaywallView: View {

    @Environment(SubscriptionManager.self) private var store
    @Environment(\.dismiss) private var dismiss

    // MARK: - Optional trigger context from AdvancedView
    var trigger: PaywallTrigger = .generic

    // MARK: - Local state
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var animateGradient = false
    @State private var animateBadge = false

    // MARK: - Feature list
    private let features: [(icon: String, color: Color, title: String, description: String)] = [
        ("sparkles",            .yellow,  "AI Writing Assistant",   "Smart suggestions, rewrites, and tone adjustments"),
        ("paintpalette.fill",   .purple,  "Custom Themes",         "Personalise your editor with unlimited colour schemes"),
        ("doc.fill",            .blue,    "Unlimited Exports",     "Export as many PDFs as you need, every month"),
        ("chart.bar.fill",      .green,   "Writing Analytics",     "Track words, focus time, and productivity trends"),
        ("icloud.fill",         .cyan,    "Cloud Sync",            "Your documents across every device, always"),
        ("timer",               .orange,  "Advanced Focus Mode",   "Custom intervals, ambient sounds, and distraction blocking"),
    ]

    var body: some View {
        ZStack {

            // MARK: - Animated gradient background
            AnimatedGradientBackground(animate: $animateGradient)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // MARK: - Dismiss
                    DismissButton { dismiss() }
                        .padding(.top, 8)

                    // MARK: - Hero
                    HeroSection(trigger: trigger, animateBadge: $animateBadge)
                        .padding(.top, 8)
                        .padding(.bottom, 28)

                    // MARK: - Plan selector
                    if !store.products.isEmpty {
                        PlanSelector(
                            products: store.products,
                            selectedProduct: $selectedProduct
                        )
                        .padding(.horizontal, 42)
                        .padding(.bottom, 20)
                    }

                    // MARK: - Feature list
                    FeatureList(features: features)
                        .padding(.horizontal, 42)
                        .padding(.bottom, 24)

                    // MARK: - Social proof
                    SocialProofRow()
                        .padding(.horizontal, 42)
                        .padding(.bottom, 24)

                    // MARK: - CTA
                    CTAButton(
                        product: selectedProduct,
                        isPurchasing: isPurchasing
                    ) {
                        Task { await handlePurchase() }
                    }
                    .padding(.horizontal, 42)
                    .padding(.bottom, 12)

                    // MARK: - Footer
                    FooterLinks {
                        Task { await store.restorePurchases() }
                    }
                    .padding(.bottom, 32)
                }
            }
        }
        
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.3)) {
                animateBadge = true
            }
            // Default to best value plan
            selectedProduct = store.products.last
        }
        .alert("Purchase Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(store.errorMessage ?? "Something went wrong. Please try again.")
        }
    }

    private func handlePurchase() async {
        guard let product = selectedProduct else { return }
        isPurchasing = true
        do {
            try await store.purchase(product)
            dismiss()
        } catch {
            showError = true
        }
        isPurchasing = false
    }
}

// MARK: - AnimatedGradientBackground
private struct AnimatedGradientBackground: View {
    @Binding var animate: Bool

    var body: some View {
        ZStack {
            // Base dark layer
            Color.black

            // Shifting gradient orbs
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.purple.opacity(0.6), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: animate ? -60 : 60, y: animate ? -120 : -80)
                .blur(radius: 40)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.indigo.opacity(0.5), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: animate ? 80 : -40, y: animate ? 100 : 60)
                .blur(radius: 50)
        }
    }
}

// MARK: - DismissButton
private struct DismissButton: View {
    let action: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button(action: action) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 30, height: 30)
                    .background(.white.opacity(0.12), in: Circle())
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - HeroSection
private struct HeroSection: View {
    let trigger: PaywallTrigger
    @Binding var animateBadge: Bool

    var body: some View {
        VStack(spacing: 16) {

            // Crown with glow + pop animation
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.15))
                    .frame(width: 90, height: 90)
                    .blur(radius: 12)

                Image(systemName: "crown.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(animateBadge ? 1 : 0.4)
            }

            VStack(spacing: 8) {
                Text("FocusFlow Pro")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)

                // Contextual subtitle from the trigger
                Text(trigger.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }
}

// MARK: - PlanSelector
private struct PlanSelector: View {
    let products: [Product]
    @Binding var selectedProduct: Product?

    var body: some View {
        VStack(spacing: 10) {
            ForEach(products, id: \.id) { product in
                PlanCard(
                    product: product,
                    isSelected: selectedProduct?.id == product.id
                ) {
                    selectedProduct = product
                }
            }
        }
    }
}

// MARK: - PlanCard
private struct PlanCard: View {
    let product: Product
    let isSelected: Bool
    let onTap: () -> Void

    private var isBestValue: Bool {
        product.id.contains("yearly") || product.id.contains("annual")
    }

    // MARK: - Savings calculation
    private var savingsText: String? {
        guard isBestValue,
              let priceValue = Double(product.price.description) else { return nil }
        let monthlyEquivalent = priceValue / 12
        return String(format: "$%.2f/mo", monthlyEquivalent)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {

                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.white : Color.white.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 22, height: 22)

                    if isSelected {
                        Circle()
                            .fill(.white)
                            .frame(width: 12, height: 12)
                    }
                }

                // Plan info
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(product.displayName)
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)

                        if isBestValue {
                            Text("BEST VALUE")
                                .font(.system(size: 9, weight: .black))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.yellow, in: Capsule())
                        }
                    }

                    if let savings = savingsText {
                        Text("Only \(savings) — save vs monthly")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }

                Spacer()

                // Price
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)

                    if let period = product.subscription?.subscriptionPeriod {
                        Text(periodLabel(period))
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.white.opacity(0.18) : Color.white.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isSelected ? Color.white.opacity(0.8) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
    }

    private func periodLabel(_ period: Product.SubscriptionPeriod) -> String {
        switch period.unit {
        case .month: return "per month"
        case .year:  return "per year"
        case .week:  return "per week"
        case .day:   return "per day"
        @unknown default: return ""
        }
    }
}

// MARK: - FeatureList
private struct FeatureList: View {
    let features: [(icon: String, color: Color, title: String, description: String)]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(features.indices, id: \.self) { index in
                HStack(spacing: 14) {

                    // Icon in a rounded square
                    Image(systemName: features[index].icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(features[index].color)
                        .frame(width: 38, height: 38)
                        .background(features[index].color.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(features[index].title)
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                        Text(features[index].description)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.55))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                }
                .padding(.vertical, 10)

                if index < features.count - 1 {
                    Divider()
                        .background(.white.opacity(0.08))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

// MARK: - SocialProofRow
private struct SocialProofRow: View {

    // MARK: - Avatar placeholder initials
    private let avatars: [(initials: String, color: Color)] = [
        ("JK", .blue), ("SM", .purple), ("AL", .green), ("RD", .orange)
    ]

    var body: some View {
        HStack(spacing: 12) {

            // Overlapping avatar stack
            HStack(spacing: -10) {
                ForEach(avatars.indices, id: \.self) { index in
                    Circle()
                        .fill(avatars[index].color.opacity(0.8))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Text(avatars[index].initials)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .overlay(Circle().stroke(.black.opacity(0.4), lineWidth: 1.5))
                        .zIndex(Double(avatars.count - index))
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 2) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.yellow)
                    }
                }
                Text("Loved by 10,000+ writers")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - CTAButton
private struct CTAButton: View {
    let product: Product?
    let isPurchasing: Bool
    let action: () -> Void

    private var label: String {
        guard let product else { return "Select a Plan" }
        return product.id.contains("yearly") ? "Start Free Trial — Yearly" : "Start Free Trial — Monthly"
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                // Gradient fill
                LinearGradient(
                    colors: [Color.purple, Color.indigo],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))

                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(label)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
            .frame(height: 56)
        }
        .disabled(product == nil || isPurchasing)
        .opacity(product == nil ? 0.5 : 1)
        // Subtle pulse when a plan is selected
        .scaleEffect(product != nil ? 1 : 0.97)
        .animation(.easeInOut(duration: 0.2), value: product?.id)
    }
}

// MARK: - FooterLinks
private struct FooterLinks: View {
    let onRestore: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Button("Restore Purchases", action: onRestore)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.5))

            Text("Subscription auto-renews. Cancel anytime in Settings.")
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.3))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

// MARK: - Preview
#Preview {
    AdvancedPaywallView(trigger: .lockedFeature("Custom Themes"))
        .environment(SubscriptionManager())
}
