//
        //
    //  Project: PaywallDemo_SwiftUI
    //  File: PaywallView.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    
import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(SubscriptionManager.self) private var store
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    
    var body: some View {
        ZStack{
            LinearGradient(colors: [Color.purple, Color.red, Color.black], startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack{
                    HStack{
                        Spacer()
                        Button {
                            dismiss()
                        } label:{
                            Image(systemName: "xmark.circle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal)
                    VStack{
                        Text("Go Pro")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.yellow)
                        
                        Text("Unlock everything. cancel anytime")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    //Products
                    
                    if store.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        VStack{
                            ForEach(store.products, id: \.id){ product in
                                Button{
                                    selectedProduct = product
                                } label: {
                                    Text("\(product.displayName) - \(product.displayPrice)")
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(selectedProduct?.id == product.id ? Color.green : Color.blue)
                            }
                        }
                    }
                    
                    //purchase button
                    Button {
                        Task { await handlePurchase() }
                    } label: {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(selectedProduct == nil ? "Select a plan" : "Continue")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Restore Purchases") {
                        Task { await store.restorePurchases() }
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.yellow)
                    .foregroundStyle(.black)
                    
                    Text("Auto - renews. Cancel anytime in settings")
                        .foregroundStyle(.white)
                }
            }
            
        }
        .onAppear {
            selectedProduct = store.products.last
        }
        .alert("Purchase Failed", isPresented: $showError){
            Button("OK", role: .cancel) { }
        } message: {
            Text(store.errorMessage ?? "Something went Wrong")
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

#Preview {
    PaywallView()
        .environment(SubscriptionManager())
}
