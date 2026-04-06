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
    var body: some View {
        NavigationStack {
            VStack{
                if store.hasActiveSubscription {
                    Text("Welcome Pro User")
                        .font(.largeTitle)
                        .bold()
                } else {
                    Text("Free plan")
                        .font(.largeTitle)
                        .italic()
                    
                    Button("Upgrade to Pro"){
                        showPaywall = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                   
            }
           
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environment(SubscriptionManager())
}
