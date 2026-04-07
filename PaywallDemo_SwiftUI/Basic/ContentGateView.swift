//
        //
    //  Project: PaywallDemo_SwiftUI
    //  File: ContentGateView.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //



import SwiftUI

struct ContentGateView: View {
    @Environment(SubscriptionManager.self) private var store
    @State private var showPaywall = false

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                Text("Super Secret Pro Content")
                    .font(.title2.bold())
                Text("Revenue: $1,000,000")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.green)
            }
            .frame(maxWidth: .infinity)
            .padding(40)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .blur(radius: store.hasActiveSubscription ? 0 : 14)

            if !store.hasActiveSubscription {
                VStack(spacing: 12) {
                    Image(systemName: "lock.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Button("Unlock Pro") { showPaywall = true }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .navigationTitle("Content Gate")
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }
}

#Preview {
    ContentGateView()
        .environment(SubscriptionManager())
}
