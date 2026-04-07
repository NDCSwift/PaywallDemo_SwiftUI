//
        //
    //  Project: PaywallDemo_SwiftUI
    //  File: SubscriptionManager.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding97
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    
import StoreKit
import SwiftUI

@Observable

class SubscriptionManager{
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading = false
    var errorMessage: String?
    var usageCount: Int = 0
    let freeUsageLimit = 3
    
    private let productIDs: [String] = [
        "com.yourapp.monthly",
        "com.yourapp.yearly"
    ]
    
    private var transactionListener: Task<Void, Error>?
    
    
    init() {
        transactionListener = listenForTransactions()
        Task{
            await fetchProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    
    func recordUsage(){
        usageCount += 1
    }
    
    func fetchProducts() async {
        isLoading = true
        do {
            products = try await Product.products(for: productIDs)
            products.sort { $0.price < $1.price }
        }
        catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    @discardableResult
    func purchase(_ product: Product) async throws -> StoreKit.Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            return transaction
            
            
        case .userCancelled:
            return nil
            
        case .pending:
            return nil
        
        @unknown default:
            return nil
        }
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }
    
    var hasActiveSubscription: Bool {
        !purchasedProductIDs.isEmpty
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result) else { continue }
            if transaction.revocationDate == nil {
                purchasedProductIDs.insert(transaction.productID)
            } else {
                purchasedProductIDs.remove(transaction.productID)
            }
        }
    }
    
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
      
        switch result{
        case .unverified:
            throw StoreError.failedVerification
            
        case .verified(let value):
            return value
        }
    }
    
 private func listenForTransactions() -> Task<Void, Error> {
     Task.detached {
         for await result in Transaction.updates{
             guard let transaction = try? self.checkVerified(result) else { continue }
             await self.updatePurchasedProducts()
             await transaction.finish()
         }
     }
    }
    
}

enum StoreError: Error {
    case failedVerification
}
