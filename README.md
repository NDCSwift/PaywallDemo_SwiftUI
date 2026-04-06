# 💳 SwiftUI Paywall — StoreKit 2 from Scratch

A production-ready iOS paywall built with SwiftUI and StoreKit 2. No third-party SDKs, no RevenueCat — just native Apple frameworks and modern Swift.

Built live on the [NoahDoesCoding YouTube channel](https://www.youtube.com/@NoahDoesCoding97) as a zero-to-hero code-along tutorial.

---

## 📺 Watch the Tutorial

[![Watch on YouTube](https://img.shields.io/badge/YouTube-Watch%20the%20Tutorial-red?style=for-the-badge&logo=youtube)](https://www.youtube.com/@NoahDoesCoding97)

---

## 🤔 What This Is

A complete SwiftUI paywall implementation using StoreKit 2 — covering product fetching, purchase flow, transaction verification, restore purchases, and local sandbox testing. The project is structured so you can drop the paywall directly into an existing app or use it as a reference for your own implementation. There are two versions included: a clean baseline and a fully polished advanced build.

---

## 💡 Why You'd Use It

- **Skip the boilerplate** — the `SubscriptionManager` handles all StoreKit 2 complexity so you start from a working foundation, not a blank file
- **Understand what's actually happening** — every function is commented with intent, not just syntax, so you know why the code is structured the way it is
- **Test without App Store Connect** — the included StoreKit configuration file lets you run a full purchase flow in the simulator with zero setup
- **Two tiers of implementation** — the basic version gets you shipping fast, the advanced version shows how a polished production paywall actually behaves
- **Real-world trigger patterns** — the advanced demo shows feature gating, usage limits, and content locks the way real apps implement them — not just an "Upgrade" button
- **No lock-in** — pure StoreKit 2, no third-party dependency.

---

## 🚀 Getting Started

### 1. Clone the Repo

```bash
git clone https://github.com/NDCSwift/REPO-NAME.git
cd REPO-NAME
```

### 2. Open in Xcode

Double-click the `.xcodeproj` file.

### 3. Set Your Development Team

Navigate to **Target → Signing & Capabilities → Team** and select your personal or organisation team.

### 4. Update the Bundle Identifier

Change `com.example.SwiftUIPaywall` to a unique identifier — e.g. `com.yourname.SwiftUIPaywall`.

### 5. Enable the StoreKit Configuration

**Edit Scheme → Run → Options → StoreKit Configuration** — select `Products.storekit`. This lets you test the full purchase flow in the simulator with no App Store Connect setup required.

### 6. Run

Select a simulator and hit **Run**. Tap the upgrade button to trigger the paywall and test a purchase.

---

## 🧪 Sandbox Testing on a Real Device

To test on a physical device with a Sandbox Apple ID:

1. Create a Sandbox tester at **App Store Connect → Users & Access → Sandbox → Testers**
2. On your iPhone go to **Settings → App Store → Sandbox Account** and sign in
3. Run the app on device — the payment sheet will show **Environment: Sandbox**
4. Sandbox subscriptions renew on compressed intervals — monthly renews every 5 minutes

Full walkthrough in the tutorial video.

---

## 🛠️ Troubleshooting

**Products don't load** — confirm the StoreKit configuration file is selected in your scheme (Edit Scheme → Run → Options).

**Purchase sheet doesn't appear** — you're likely on the simulator without a StoreKit config set. Set it in the scheme or run on a real device with a Sandbox Apple ID.

**`@Observable` compile error** — requires iOS 17+ deployment target. For iOS 16, swap to `ObservableObject` and add `@Published` to each property.

**Sandbox Account option missing in Settings** — this only appears on a real physical device running iOS 14+. It does not appear in the simulator.

---

## 📦 Requirements

- Xcode 15+
- iOS 17+
- No third-party dependencies

---

## 🔜 Follow-Up Tutorial

The next video migrates this exact project to RevenueCat — same paywall UI, same features, the StoreKit layer swapped out. Subscribe to the channel to catch it when it drops.

[![Subscribe](https://img.shields.io/badge/YouTube-Subscribe-red?style=for-the-badge&logo=youtube)](https://www.youtube.com/@NoahDoesCoding97)
