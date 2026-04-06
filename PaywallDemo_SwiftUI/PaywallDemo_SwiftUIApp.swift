//
        //
    //  Project: PaywallDemo_SwiftUI
    //  File: PaywallDemo_SwiftUIApp.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    

import SwiftUI

@main
struct PaywallDemo_SwiftUIApp: App {
    @State private var store = SubscriptionManager()
    var body: some Scene {
        WindowGroup {
            //Swap to ContentView for tutorial view and AdvancedView for app demo
            AdvancedView()
            //ContentView()
                .environment(store)
        }
    }
}
