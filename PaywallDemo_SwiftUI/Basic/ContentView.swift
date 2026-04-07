//
        //
    //  Project: PaywallDemo_SwiftUI
    //  File: ContentView.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //



import SwiftUI

struct ContentView: View {
    @Environment(SubscriptionManager.self) private var store
    @State private var showPaywall = false
    @State private var hardGateActivated = false
    @State private var nudgeCount = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {

                        // Status header
                        HStack {
                            if store.hasActiveSubscription {
                                Label("Pro", systemImage: "crown.fill")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.yellow)
                            } else {
                                Label("Free Plan", systemImage: "person.fill")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Button("Upgrade to Pro") { showPaywall = true }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

                        // 1. Hard Feature Gate
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Hard Feature Gate", systemImage: "lock.fill")
                                .font(.headline)
                            Text("Pro-Only. Paywall fires on tap.")
                                .font(.caption).foregroundStyle(.secondary)

                            Button("Run Pro Feature") {
                                if store.hasActiveSubscription {
                                    hardGateActivated = true
                                } else {
                                    showPaywall = true
                                }
                            }
                            .buttonStyle(.borderedProminent)

                            if hardGateActivated {
                                Label("Feature Ran", systemImage: "checkmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.green)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

                        // 2. Usage Limit Gate
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Usage Limit Gate", systemImage: "gauge.medium")
                                .font(.headline)
                            Text("Free for \(store.freeUsageLimit) uses. Paywall fires on the next tap.")
                                .font(.caption).foregroundStyle(.secondary)

                            Text("\(store.usageCount) / \(store.freeUsageLimit)")
                                .monospacedDigit()
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Button("Use Feature") {
                                if !store.hasActiveSubscription && store.usageCount >= store.freeUsageLimit {
                                    showPaywall = true
                                } else {
                                    store.recordUsage()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

                        // 3. Content Gate
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Content Gate", systemImage: "eye.slash.fill")
                                .font(.headline)
                            Text("Content renders but is blurred behind a material overlay.")
                                .font(.caption).foregroundStyle(.secondary)

                            NavigationLink("View Pro Content") {
                                ContentGateView()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))

                        // 4. Soft Nudge
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Soft Nudge", systemImage: "hand.wave.fill")
                                .font(.headline)
                            Text("Feature works freely. A non-blocking banner surfaces upgrade value.")
                                .font(.caption).foregroundStyle(.secondary)

                            Button("Do the thing") {
                                nudgeCount += 1
                            }
                            .buttonStyle(.bordered)

                            if nudgeCount > 0 {
                                Text("Done \(nudgeCount) time(s)")
                                    .monospacedDigit()
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .padding()
                }

                // Soft nudge sticky banner
                if nudgeCount % 5 == 0 {
                    if !store.hasActiveSubscription {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Enjoying the app?")
                                    .font(.subheadline).bold()
                                Text("Go Pro to unlock everything")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Button("Go Pro") { showPaywall = true }
                                .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .background(.regularMaterial)
                    }
                }
            }
            .navigationTitle("Paywall Patterns")
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

#Preview {
    ContentView()
        .environment(SubscriptionManager())
}
