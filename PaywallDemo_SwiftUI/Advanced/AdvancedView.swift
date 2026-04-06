//
    //
    //  Project: PaywallDemo_SwiftUI
    //  File: AdvancedView.swift
    //  Created by Noah Carpenter
    //
    //  YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //

import SwiftUI
import StoreKit

// MARK: - Sample document model
struct FocusDocument: Identifiable {
    let id = UUID()
    let title: String
    let wordCount: Int
    let lastEdited: String
    let icon: String
}

// MARK: - AdvancedView
// Demonstrates real-world paywall trigger patterns inside a realistic app.
// This is how a production app gates features — not just a single "Upgrade" button.
//
// Four paywall patterns are shown here:
//   1. Hard feature gate — Pro-only features that trigger the paywall immediately on tap
//   2. Usage limit gate — free for N uses, paywall fires when the limit is hit
//   3. Content gate     — content is rendered but blurred behind a material overlay
//   4. Soft nudge       — a non-blocking upgrade prompt for happy free users
struct AdvancedView: View {

    @Environment(SubscriptionManager.self) private var store
    @State private var showPaywall = false
    @State private var paywallTrigger: PaywallTrigger = .generic

    // MARK: - Free usage tracking (in production this lives in UserDefaults or SwiftData)
    @State private var exportCount = 0
    private let freeExportLimit = 3

    // Sample documents to give the app a realistic feel
    private let documents: [FocusDocument] = [
        .init(title: "Q2 Marketing Brief", wordCount: 1842, lastEdited: "Today", icon: "doc.text.fill"),
        .init(title: "Product Roadmap", wordCount: 3201, lastEdited: "Yesterday", icon: "doc.text.fill"),
        .init(title: "Meeting Notes – Design", wordCount: 567, lastEdited: "Apr 4", icon: "note.text"),
        .init(title: "Blog Draft: AI in 2026", wordCount: 2105, lastEdited: "Apr 2", icon: "doc.text.fill"),
    ]

    var body: some View {
        NavigationStack {
            List {
                // Dashboard stats — gives the app a real, lived-in feel
                TodayStatsSection()

                // Real content the user interacts with daily
                Section("Recent Documents") {
                    ForEach(documents) { doc in
                        DocumentRow(document: doc)
                    }
                }

                // MARK: Patterns 1 & 2 — Hard gates + Usage limits
                // Free tools, metered exports, and Pro-only features all live together
                ToolsSection(
                    store: store,
                    exportCount: $exportCount,
                    freeExportLimit: freeExportLimit,
                    showPaywall: $showPaywall,
                    paywallTrigger: $paywallTrigger
                )

                // MARK: Pattern 3 — Content gate
                // Analytics pages exist but are blurred behind a lock overlay
                AnalyticsSection(
                    store: store,
                    showPaywall: $showPaywall,
                    paywallTrigger: $paywallTrigger
                )

                // MARK: Pattern 4 — Soft contextual nudge
                // Not a gate — just a persistent, non-intrusive upgrade row for free users
                if !store.hasActiveSubscription {
                    Section {
                        UpgradePromptRow {
                            paywallTrigger = .generic
                            showPaywall = true
                        }
                    }
                }
            }
            .navigationTitle("FocusFlow")
        }
        .sheet(isPresented: $showPaywall) {
            AdvancedPaywallView(trigger: paywallTrigger)
        }
    }
}

// MARK: - TodayStatsSection
private struct TodayStatsSection: View {
    var body: some View {
        Section {
            VStack(spacing: 12) {
                HStack {
                    Text("Today")
                        .font(.headline)
                    Spacer()
                    Text(Date.now, format: .dateTime.month(.abbreviated).day())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 0) {
                    StatItem(value: "1,247", label: "Words", icon: "character.cursor.ibeam", color: .blue)
                    StatItem(value: "45m", label: "Focus", icon: "timer", color: .green)
                    StatItem(value: "7", label: "Streak", icon: "flame.fill", color: .orange)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - StatItem
private struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold().monospacedDigit())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - DocumentRow
private struct DocumentRow: View {
    let document: FocusDocument

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: document.icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(document.title)
                    .font(.subheadline.weight(.medium))
                Text("\(document.wordCount) words \u{00B7} \(document.lastEdited)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - ToolsSection
// Mixes free tools, metered features, and hard-gated Pro features in one section.
// This is how real apps present it — the gate is woven into the feature list,
// not a separate "Pro Features" page.
private struct ToolsSection: View {
    let store: SubscriptionManager
    @Binding var exportCount: Int
    let freeExportLimit: Int
    @Binding var showPaywall: Bool
    @Binding var paywallTrigger: PaywallTrigger

    var body: some View {
        Section("Tools") {

            // Free tool — always accessible, no gate at all
            Label("Focus Timer", systemImage: "timer")

            // MARK: Pattern 2 — Usage limit gate
            // Export is free — but only N times per month.
            // Showing the remaining count upfront reduces frustration —
            // the user always knows where they stand.
            Button { handleExport() } label: {
                HStack {
                    Label("Export to PDF", systemImage: "doc.fill")
                    Spacer()
                    if !store.hasActiveSubscription {
                        // Remaining free uses — transparency before the gate
                        Text("\(max(0, freeExportLimit - exportCount)) free left")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // MARK: Pattern 1 — Hard feature gates
            // PRO badge on the right signals the gate before they even tap.
            // Free users can see these features exist — they just can't use them.
            // That visibility is intentional: you want free users to know what they're missing.
            ProFeatureButton(title: "AI Writing Assistant", icon: "sparkles", isSubscribed: store.hasActiveSubscription) {
                paywallTrigger = .lockedFeature("AI Writing Assistant")
                showPaywall = true
            }

            ProFeatureButton(title: "Custom Themes", icon: "paintpalette.fill", isSubscribed: store.hasActiveSubscription) {
                paywallTrigger = .lockedFeature("Custom Themes")
                showPaywall = true
            }

            ProFeatureButton(title: "Cloud Sync", icon: "icloud.fill", isSubscribed: store.hasActiveSubscription) {
                paywallTrigger = .lockedFeature("Cloud Sync")
                showPaywall = true
            }
        }
    }

    private func handleExport() {
        if store.hasActiveSubscription {
            // Pro user — no limit, just do the action
            exportCount += 1
        } else if exportCount < freeExportLimit {
            // Free user under the limit — allow it
            exportCount += 1
        } else {
            // Limit hit — show paywall with usage-specific context
            paywallTrigger = .usageLimit("You've used all \(freeExportLimit) free exports this month.")
            showPaywall = true
        }
    }
}

// MARK: - ProFeatureButton
// Reusable row for hard-gated features.
// Shows a PRO badge for free users; tapping fires the paywall immediately.
// Pro users see the feature at full opacity with no badge — the gate disappears.
private struct ProFeatureButton: View {
    let title: String
    let icon: String
    let isSubscribed: Bool
    let action: () -> Void

    var body: some View {
        Button {
            if !isSubscribed { action() }
        } label: {
            HStack {
                Label(title, systemImage: icon)
                Spacer()
                // Pro badge signals the gate before they even tap
                if !isSubscribed { ProBadge() }
            }
        }
        .foregroundStyle(isSubscribed ? .primary : .secondary)
    }
}

// MARK: - AnalyticsSection
// Pattern 3 — Content gate.
// These pages navigate normally — but the content is blurred behind a material
// overlay with a lock icon. The actual data is rendered underneath.
// This works really well for content-heavy apps — the user gets a glimpse
// of what they're paying for before they commit.
private struct AnalyticsSection: View {
    let store: SubscriptionManager
    @Binding var showPaywall: Bool
    @Binding var paywallTrigger: PaywallTrigger

    var body: some View {
        Section("Analytics") {
            NavigationLink {
                LockedAnalyticsView(showPaywall: $showPaywall, trigger: $paywallTrigger)
            } label: {
                HStack {
                    Label("Writing Analytics", systemImage: "chart.bar.fill")
                    Spacer()
                    if !store.hasActiveSubscription { ProBadge() }
                }
            }

            NavigationLink {
                LockedAnalyticsView(showPaywall: $showPaywall, trigger: $paywallTrigger)
            } label: {
                HStack {
                    Label("Weekly Report", systemImage: "calendar.badge.clock")
                    Spacer()
                    if !store.hasActiveSubscription { ProBadge() }
                }
            }
        }
    }
}

// MARK: - UpgradePromptRow
// Pattern 4 — Soft contextual nudge.
// Not a gate at all — just a persistent but non-intrusive upgrade row
// that only appears for free users. It sits at the bottom of the list,
// it's not blocking anything, and it's always one tap away from the paywall.
// This is the pattern that drives upgrades from happy free users
// who just decide they want more.
private struct UpgradePromptRow: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "crown.fill")
                    .foregroundStyle(.yellow)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Upgrade to Pro")
                        .font(.subheadline.bold())
                    Text("Unlock all tools. Cancel anytime.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - PaywallTrigger
// Carries context into the paywall so the subtitle copy can be customised
// depending on exactly what triggered it.
// "AI Writing Assistant is a Pro feature" hits differently than a generic
// upgrade pitch — because it's specific to what the user was trying to do.
enum PaywallTrigger {
    case lockedFeature(String)   // Hard gate — names the feature that was tapped
    case usageLimit(String)      // Metered gate — explains what ran out
    case generic                 // Soft nudge — general upgrade pitch

    var subtitle: String {
        switch self {
        case .lockedFeature(let name):
            return "\(name) is a Pro feature."
        case .usageLimit(let message):
            return message
        case .generic:
            return "Unlock everything. Cancel anytime."
        }
    }
}

// MARK: - ProBadge
// Reusable badge — visual signal that a feature requires Pro.
// Appears inline in the row so the gate is obvious before the user taps.
struct ProBadge: View {
    var body: some View {
        Text("PRO")
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.purple, in: Capsule())
    }
}

// MARK: - LockedAnalyticsView
// Pattern 3 in action — the actual analytics content is always rendered.
// For free users, a .ultraThinMaterial overlay blurs it and presents
// a lock icon with an unlock button. The user can see the data exists —
// they just can't read it. This "glimpse" effect is what makes
// content gates so effective at driving conversions.
struct LockedAnalyticsView: View {
    @Binding var showPaywall: Bool
    @Binding var trigger: PaywallTrigger
    @Environment(SubscriptionManager.self) private var store

    private let weekData: [(day: String, height: CGFloat)] = [
        ("Mon", 60), ("Tue", 95), ("Wed", 45),
        ("Thu", 110), ("Fri", 80), ("Sat", 35), ("Sun", 50)
    ]

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    AnalyticsSummary()
                    WeeklyBarChart(weekData: weekData)
                }
                .padding()
            }

            if !store.hasActiveSubscription {
                AnalyticsLockOverlay {
                    trigger = .lockedFeature("Writing Analytics")
                    showPaywall = true
                }
            }
        }
        .navigationTitle("Analytics")
    }
}

// MARK: - AnalyticsSummary
private struct AnalyticsSummary: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This Week")
                .font(.title2.bold())

            HStack(spacing: 32) {
                VStack(alignment: .leading) {
                    Text("8,432")
                        .font(.title.bold().monospacedDigit())
                    Text("Words Written")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading) {
                    Text("3h 12m")
                        .font(.title.bold().monospacedDigit())
                    Text("Focus Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Most productive day: Tuesday")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Top project: Q2 Marketing Brief")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - WeeklyBarChart
private struct WeeklyBarChart: View {
    let weekData: [(day: String, height: CGFloat)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Words")
                .font(.subheadline.bold())

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(Array(weekData.enumerated()), id: \.offset) { _, entry in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.blue.opacity(0.6))
                            .frame(width: 30, height: entry.height)
                        Text(entry.day)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - AnalyticsLockOverlay
private struct AnalyticsLockOverlay: View {
    let action: () -> Void

    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .overlay {
                VStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .font(.largeTitle)
                    Text("Pro Feature")
                        .font(.headline)
                    Text("Unlock detailed writing analytics\nwith a Pro subscription.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Unlock Pro", action: action)
                        .buttonStyle(.borderedProminent)
                }
                .padding()
            }
    }
}

// MARK: - Preview
#Preview {
    AdvancedView()
        .environment(SubscriptionManager())
}

