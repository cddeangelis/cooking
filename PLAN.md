# iOS Cooking App - Development Plan

A personal iOS app for managing recipes, meal planning, and cooking assistance.

## Overview

**Goal**: Create a simple, effective iOS app for personal recipe management and cooking assistance.

**Target**: Personal use only (single user, no App Store release)

**Deployment**: Direct installation via Xcode to personal device(s)

---

## Core Features

### Phase 1: Foundation (MVP)

#### 1.1 Recipe Management
- [ ] Create, view, edit, and delete recipes
- [ ] Recipe fields:
  - Title
  - Description/notes
  - Ingredients list (with quantities and units)
  - Step-by-step instructions
  - Prep time and cook time
  - Servings/yield
  - Category/cuisine type
  - Difficulty level
- [ ] Recipe images (camera or photo library)
- [ ] Favorite/bookmark recipes

#### 1.2 Recipe Organization
- [ ] Browse all recipes in a list/grid view
- [ ] Filter by category (e.g., breakfast, dinner, dessert)
- [ ] Search recipes by name or ingredient
- [ ] Sort by date added, name, or favorites

#### 1.3 Data Persistence
- [ ] Local storage using SwiftData (modern, Apple-native)
- [ ] iCloud sync via CloudKit (automatic backup across devices)

### Phase 2: Cooking Assistance

#### 2.1 Cook Mode
- [ ] Step-by-step instruction view (large text, easy to read while cooking)
- [ ] Keep screen awake during cooking
- [ ] Voice readout of current step (accessibility)
- [ ] Swipe/tap to navigate between steps

#### 2.2 Timers
- [ ] Multiple concurrent timers
- [ ] Timer presets from recipe steps
- [ ] Background notifications when timer completes
- [ ] Named timers (e.g., "Boil pasta", "Preheat oven")

#### 2.3 Ingredient Scaling
- [ ] Adjust servings and auto-scale ingredients
- [ ] Fraction handling (1/2 cup, 1/4 tsp, etc.)

### Phase 3: Planning & Shopping

#### 3.1 Meal Planning
- [ ] Weekly calendar view
- [ ] Drag-and-drop recipes to days
- [ ] Quick view of planned meals

#### 3.2 Shopping List
- [ ] Generate shopping list from selected recipes
- [ ] Combine duplicate ingredients
- [ ] Check off items while shopping
- [ ] Organize by store section (produce, dairy, etc.)
- [ ] Manual item addition

### Phase 4: Import & Discovery

#### 4.1 Recipe Import
- [ ] Import from URL (parse recipe websites)
- [ ] Import from plain text
- [ ] Import from JSON format
- [ ] Share extension (import from Safari/other apps)

#### 4.2 Quick Add
- [ ] Photo-to-recipe using on-device ML (iOS 17+ features)
- [ ] Voice input for quick recipe capture

---

## Technical Architecture

### Tech Stack

| Component | Technology | Rationale |
|-----------|------------|-----------|
| UI Framework | SwiftUI | Modern, declarative, less boilerplate |
| Data Layer | SwiftData | Apple's latest persistence framework, seamless SwiftUI integration |
| Cloud Sync | CloudKit | Free, automatic iCloud sync, no backend needed |
| Architecture | MVVM | Clean separation, testable, SwiftUI-friendly |
| Minimum iOS | iOS 17.0 | SwiftData support, latest SwiftUI features |
| Language | Swift 5.9+ | Latest language features |

### Project Structure

```
Cooking/
├── App/
│   ├── CookingApp.swift              # App entry point
│   └── ContentView.swift             # Root navigation
│
├── Features/
│   ├── Recipes/
│   │   ├── Models/
│   │   │   └── Recipe.swift          # SwiftData model
│   │   ├── Views/
│   │   │   ├── RecipeListView.swift
│   │   │   ├── RecipeDetailView.swift
│   │   │   ├── RecipeEditView.swift
│   │   │   └── RecipeRowView.swift
│   │   └── ViewModels/
│   │       └── RecipeViewModel.swift
│   │
│   ├── CookMode/
│   │   ├── Views/
│   │   │   ├── CookModeView.swift
│   │   │   └── StepView.swift
│   │   └── ViewModels/
│   │       └── CookModeViewModel.swift
│   │
│   ├── Timers/
│   │   ├── Models/
│   │   │   └── CookingTimer.swift
│   │   ├── Views/
│   │   │   └── TimerView.swift
│   │   └── Services/
│   │       └── TimerManager.swift
│   │
│   ├── MealPlanning/
│   │   ├── Models/
│   │   │   └── MealPlan.swift
│   │   └── Views/
│   │       └── MealPlannerView.swift
│   │
│   └── Shopping/
│       ├── Models/
│       │   └── ShoppingItem.swift
│       └── Views/
│           └── ShoppingListView.swift
│
├── Shared/
│   ├── Components/
│   │   ├── ImagePicker.swift
│   │   ├── SearchBar.swift
│   │   └── RatingView.swift
│   ├── Extensions/
│   │   ├── Color+Extensions.swift
│   │   └── String+Extensions.swift
│   └── Utilities/
│       ├── FractionFormatter.swift
│       └── RecipeParser.swift
│
├── Resources/
│   ├── Assets.xcassets/
│   ├── Localizable.strings
│   └── SampleRecipes.json
│
└── Tests/
    ├── RecipeTests.swift
    └── ParserTests.swift
```

### Data Models

#### Recipe (Primary Model)
```swift
@Model
class Recipe {
    var id: UUID
    var title: String
    var summary: String?
    var ingredients: [Ingredient]
    var instructions: [Instruction]
    var prepTime: Int?          // minutes
    var cookTime: Int?          // minutes
    var servings: Int?
    var category: Category?
    var tags: [String]
    var isFavorite: Bool
    var imageData: Data?
    var sourceURL: String?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
}
```

#### Supporting Models
```swift
struct Ingredient: Codable {
    var name: String
    var quantity: Double?
    var unit: String?
    var notes: String?          // e.g., "diced", "room temperature"
}

struct Instruction: Codable {
    var stepNumber: Int
    var text: String
    var timerMinutes: Int?      // optional timer for this step
}

enum Category: String, Codable, CaseIterable {
    case breakfast, lunch, dinner, dessert, snack, drink, appetizer, side
}
```

---

## Implementation Roadmap

### Step 1: Project Setup
- [ ] Create Xcode project (iOS App, SwiftUI, SwiftData)
- [ ] Configure project settings (bundle ID, minimum iOS version)
- [ ] Set up folder structure
- [ ] Enable iCloud capability for CloudKit
- [ ] Add app icon placeholder

### Step 2: Core Data Models
- [ ] Define Recipe SwiftData model
- [ ] Define Ingredient and Instruction types
- [ ] Define Category enum
- [ ] Create ModelContainer configuration
- [ ] Add sample data for development

### Step 3: Recipe List & Detail Views
- [ ] Create RecipeListView with grid/list toggle
- [ ] Implement search and filter functionality
- [ ] Create RecipeDetailView with full recipe display
- [ ] Add favorite toggle functionality
- [ ] Implement delete with swipe/context menu

### Step 4: Recipe Create/Edit
- [ ] Create RecipeEditView form
- [ ] Implement ingredient list editor (add/remove/reorder)
- [ ] Implement instruction list editor
- [ ] Add image picker integration
- [ ] Implement form validation

### Step 5: Cook Mode
- [ ] Create full-screen step-by-step view
- [ ] Implement step navigation (swipe, buttons)
- [ ] Add keep-screen-awake functionality
- [ ] Implement serving size adjustment
- [ ] Add text-to-speech for current step

### Step 6: Timers
- [ ] Create timer data model
- [ ] Build timer UI component
- [ ] Implement background timer notifications
- [ ] Allow multiple concurrent timers
- [ ] Add timer presets from recipe steps

### Step 7: Shopping List
- [ ] Create ShoppingItem model
- [ ] Build shopping list view with sections
- [ ] Implement "add ingredients from recipe" feature
- [ ] Add ingredient consolidation logic
- [ ] Implement check-off functionality

### Step 8: Meal Planning
- [ ] Create MealPlan model
- [ ] Build weekly calendar view
- [ ] Implement recipe assignment to dates
- [ ] Add quick meal overview

### Step 9: Recipe Import
- [ ] Research recipe schema (Schema.org Recipe)
- [ ] Implement URL-based recipe parser
- [ ] Create share extension for Safari import
- [ ] Add plain text import option

### Step 10: Polish & Refinement
- [ ] Refine UI/UX throughout
- [ ] Add onboarding/empty states
- [ ] Implement dark mode support
- [ ] Add haptic feedback
- [ ] Performance optimization

---

## Design Principles

### UI/UX Guidelines
- **Clean & Minimal**: Focus on content, minimal chrome
- **Easy One-Handed Use**: Important actions reachable with thumb
- **Kitchen-Friendly**: Large tap targets, works with wet/messy hands
- **Quick Access**: Favorites and recent recipes prominent
- **Visual**: Food photography as the hero element

### Color Palette (Suggestion)
- Primary: Warm orange (#FF6B35) - appetizing, energetic
- Secondary: Sage green (#8CB369) - fresh, natural
- Background: Cream/off-white (#FFF8F0) - warm, inviting
- Text: Dark brown (#3D2914) - readable, warm

---

## Development Environment

### Requirements
- macOS Sonoma or later
- Xcode 15.0 or later
- iOS 17.0+ device for testing
- Apple Developer account (free tier works for personal device deployment)

### Device Deployment (Personal Use)
Since this is for personal use only, you can deploy directly to your device:
1. Sign into Xcode with your Apple ID
2. Connect iPhone via USB
3. Select your device as the run destination
4. Build and run (⌘R)
5. Trust the developer certificate on your iPhone (Settings > General > Device Management)

No paid Apple Developer Program membership required for personal testing.

---

## Decisions Made

1. **Offline-First vs Cloud-First**: Local-first with iCloud sync ✓

2. **iPad Support**: iPhone-only initially ✓

3. **Widget Support**: Add in later phase

4. **Watch App**: Yes - watchOS companion for timers ✓

5. **Recipe Sources**: No initial import needed - recipes will be added through the app ✓

---

## Next Steps

1. **Review this plan** - Adjust features, priorities, or technical choices as needed
2. **Set up Xcode project** - Create the iOS project with proper structure
3. **Build MVP** - Focus on Phase 1 (recipe CRUD, basic organization)
4. **Iterate** - Add features based on actual usage

---

*Plan created: January 2026*
*Repository: cooking*
*Branch: claude/plan-ios-app-JSpNQ*
