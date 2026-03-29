# CLAUDE.md — CarTags iOS

## Project overview
CarTags is a license plate region lookup app.
- **Platform:** iOS 17+, SwiftUI
- **Language:** Swift 5.9+
- **Database:** SQLite via GRDB (bundled cartags.db, read-only)
- **Monetization:** StoreKit 2 (freemium)
- **Localization:** en, de, ru, uk

## Architecture: MVVM
```
View → ViewModel → Service → Database
```

- `View` — SwiftUI only. No business logic. No direct DB calls.
- `ViewModel` — `@Observable` class. Owns state, calls services.
- `Service` — pure Swift classes (DatabaseService, StoreService).
- `Model` — plain structs, no logic.

## Naming conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Types, structs, enums | UpperCamelCase | `RegionResult`, `SearchViewModel` |
| Variables, functions | lowerCamelCase | `searchCode`, `performSearch()` |
| Constants | lowerCamelCase | `let maxFreeRequests = 5` |
| Files | Same as type | `SearchView.swift`, `SearchViewModel.swift` |
| Booleans | is/has/can prefix | `isLoading`, `hasResults`, `canSearch` |
| Async functions | Noun-first, no "fetch" prefix | `regions(for:)`, `countries()` |

## File structure rules

- 1 type = 1 file
- View and ViewModel live together in `Features/FeatureName/`
- Shared models → `Models/`
- Services → `Services/ServiceName/`
```
Features/
  Search/
    SearchView.swift
    SearchViewModel.swift
  Browse/
    BrowseView.swift
    BrowseViewModel.swift
Models/
  Models.swift
Services/
  Database/
    DatabaseService.swift
  StoreKit/
    StoreService.swift
Utils/
  FlagEmoji.swift
  Extensions.swift
```

## SwiftUI patterns

**ViewModel:** use `@Observable` (iOS 17+), not `ObservableObject`.
```swift
@Observable
final class SearchViewModel {
    var searchCode = ""
    var results: [RegionResult] = []
    var isLoading = false
    var errorMessage: String?

    func search() {
        // logic here
    }
}
```

**View:** instantiate ViewModel inside View via `@State`.
```swift
struct SearchView: View {
    @State private var viewModel = SearchViewModel()
}
```

**Never:**
- Use `ObservableObject` + `@StateObject` (deprecated since iOS 17)
- Put business logic inside Views
- Call `DatabaseService` directly from a View

## Error handling

- Services throw errors via `throws`
- ViewModel catches and writes to `errorMessage: String?`
- View shows `.alert` when `errorMessage != nil`
```swift
// ViewModel
func search() {
    do {
        results = try DatabaseService.shared.searchByCode(searchCode)
    } catch {
        errorMessage = error.localizedDescription
    }
}

// View
.alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
    Button("OK") { viewModel.errorMessage = nil }
} message: {
    Text(viewModel.errorMessage ?? "")
}
```

## Localization

- All user-facing strings use `String(localized:)`
- Keys in `snake_case`
- File: `Localizable.xcstrings` (Xcode 15+ format)
```swift
// Correct
Text(String(localized: "search.placeholder"))

// Wrong
Text("Enter plate code")
```

## Freemium rules

**Free tier:**
- User picks 3 countries (stored in `UserDefaults`)
- 5 requests per day (counter in `UserDefaults`, reset by date)
- Search only works within selected countries

**Paid tier (€1/month or €12 lifetime):**
- All 19 countries
- Unlimited requests

**Rules:**
- Limit checks live only in `StoreService`
- Never duplicate limit logic in Views or ViewModels
- Show paywall via a `PaywallView` sheet

## Code style

- Use `guard let` instead of `if let` for early exits
- Always use trailing closure syntax
- Default to `private`, use `internal` only when needed
- Max 40 lines per function
- Comments only for non-obvious logic, never describe what the code does
