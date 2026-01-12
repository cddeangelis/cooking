# Cooking App - Xcode Setup Guide

This guide walks you through setting up the project in Xcode.

## Prerequisites

- macOS Sonoma 14.0 or later
- Xcode 15.0 or later
- iOS 17.0+ device for testing
- watchOS 10.0+ Apple Watch (optional, for watch companion app)
- Apple ID (free tier is fine for personal device deployment)

## Step 1: Create Xcode Project

1. Open Xcode
2. File > New > Project
3. Select **iOS > App**
4. Configure:
   - Product Name: `Cooking`
   - Team: Your Apple ID
   - Organization Identifier: `com.yourname` (e.g., `com.johndoe`)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **SwiftData**
   - Check: **Include Tests** (optional)
5. Click **Next** and save the project in the `cooking` repository folder
6. Delete the auto-generated files (ContentView.swift, Item.swift, etc.)

## Step 2: Add Source Files

1. In Xcode, right-click on the `Cooking` folder in the Project Navigator
2. Select **Add Files to "Cooking"...**
3. Navigate to the `Cooking` folder in your repo
4. Select all folders: `App`, `Features`, `Shared`, `Resources`
5. Ensure "Copy items if needed" is **unchecked**
6. Ensure "Create groups" is **selected**
7. Click **Add**

## Step 3: Configure iCloud for CloudKit Sync

1. Select your project in the Project Navigator
2. Select the `Cooking` target
3. Go to **Signing & Capabilities**
4. Click **+ Capability**
5. Add **iCloud**
6. Check **CloudKit**
7. Create a new container: `iCloud.com.yourname.cooking`

## Step 4: Add Watch App (Optional)

1. File > New > Target
2. Select **watchOS > App**
3. Configure:
   - Product Name: `CookingWatch`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Watch App: **Watch App**
   - Include Notification Scene: **No**
4. Click **Finish**
5. Delete auto-generated files
6. Add the `CookingWatch` folder files the same way as Step 2

## Step 5: Configure Build Settings

### iOS App (Cooking target)
- Minimum Deployments: iOS 17.0
- Supports: iPhone only

### Watch App (CookingWatch target)
- Minimum Deployments: watchOS 10.0

## Step 6: Run on Device

### First-time setup:
1. Connect your iPhone via USB
2. Select your device as the run destination
3. Build and Run (⌘R)
4. If prompted, go to Settings > General > VPN & Device Management
5. Trust your developer certificate

### Subsequent runs:
- You can run wirelessly if enabled (Window > Devices and Simulators > Connect via network)

## Project Structure

```
Cooking/
├── App/
│   ├── CookingApp.swift          # App entry point with SwiftData container
│   └── ContentView.swift         # Tab-based navigation
├── Features/
│   ├── Recipes/                  # Recipe CRUD functionality
│   ├── CookMode/                 # Step-by-step cooking mode
│   ├── Timers/                   # Timer management
│   ├── Shopping/                 # Shopping list
│   └── MealPlanning/             # Weekly meal planner
├── Shared/
│   ├── Components/               # Reusable UI components
│   └── Extensions/               # Swift extensions
└── Resources/
    └── Assets.xcassets/          # App icon, colors

CookingWatch/
├── App/
│   └── CookingWatchApp.swift     # Watch app entry point
├── Models/
│   └── WatchTimer.swift          # Watch-specific timer model
└── Views/
    ├── WatchContentView.swift    # Main timer list
    ├── WatchTimerDetailView.swift
    └── WatchNewTimerView.swift
```

## Troubleshooting

### "Untrusted Developer" error
Go to Settings > General > VPN & Device Management and trust your developer account.

### CloudKit sync not working
- Ensure you're signed into iCloud on your device
- Check that the CloudKit container is properly configured
- First sync may take a few minutes

### Watch app not installing
- Ensure Watch app is paired with iPhone
- Try restarting both devices
- Check that Watch is on watchOS 10.0+

## Notes for Personal Use

Since this is for personal use only:
- No App Store submission needed
- No paid developer account required
- App certificate expires after 7 days (free) or 1 year (paid)
- Re-run from Xcode to refresh the certificate

Enjoy cooking! 🍳
