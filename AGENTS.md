//
//  AGENTS.md
//  CarTags
//
//  Created by Vladyslav Kekukh on 28.03.26.
//

# AGENTS.md — CarTags iOS

You are building **CarTags** — a license plate region lookup iOS app.
Read `CLAUDE.md` first. Follow every rule in it without exception.

---

## What already exists (DO NOT rewrite unless broken)

- `Models/Models.swift` — `RegionResult`, `CountryItem` structs (GRDB FetchableRecord)
- `Services/Database/DatabaseService.swift` — singleton, methods: `searchByCode(_:language:)`, `fetchCountries(language:)`, `fetchRegions(countryId:language:)`
- `Features/Search/SearchView.swift` — search UI with search bar, results list, empty/placeholder states
- `Features/Search/SearchViewModel.swift` — `@Observable`, `search()`, `clear()`
- `Resources/cartags.db` — bundled SQLite database (read-only)

---

## What you must build

### 1. Fix ContentView.swift

Replace the default Hello World with a `TabView` containing Search and Browse tabs:

```
TabView
├── SearchView()   — tab icon: magnifyingglass,  label: "Search"
└── BrowseView()   — tab icon: globe,             label: "Browse"
```

File: `App/ContentView.swift` (currently at root, move or update in place)

---

### 2. BrowseView + BrowseViewModel

**File:** `Features/Browse/BrowseViewModel.swift`

```swift
@Observable
final class BrowseViewModel {
    var countries: [CountryItem] = []
    var errorMessage: String?

    func loadCountries() { ... } // calls DatabaseService.shared.fetchCountries()
}
```

**File:** `Features/Browse/BrowseView.swift`

- `NavigationStack` with title "Browse"
- `List` of countries, each row shows: flag emoji + country name
- Tapping a country navigates to `RegionsView(country:)`
- Call `viewModel.loadCountries()` in `.onAppear`

---

### 3. RegionsView + RegionsViewModel

**File:** `Features/Browse/RegionsViewModel.swift`

```swift
@Observable
final class RegionsViewModel {
    var regions: [RegionResult] = []
    var errorMessage: String?
    let country: CountryItem

    init(country: CountryItem) { self.country = country }

    func loadRegions() { ... } // calls DatabaseService.shared.fetchRegions(countryId:)
}
```

**File:** `Features/Browse/RegionsView.swift`

- `NavigationStack` title = country name
- `List` of regions, each row shows: code (bold) + region name + flag emoji
- Call `viewModel.loadRegions()` in `.onAppear`

---

### 4. Utils/FlagEmoji.swift

Extract the `flagEmoji(for:)` function from `SearchView` into a shared utility:

```swift
// Utils/FlagEmoji.swift
func flagEmoji(for countryCode: String) -> String {
    countryCode.uppercased().unicodeScalars.compactMap {
        Unicode.Scalar(127397 + $0.value)
    }.map(String.init).joined()
}
```

Then update `SearchView.swift` and `RegionRow` to use this shared function.

---

### 5. StoreService

**File:** `Services/StoreKit/StoreService.swift`

```swift
@Observable
final class StoreService {
    static let shared = StoreService()

    // Product IDs
    static let monthlyID  = "com.cartags.monthly"
    static let lifetimeID = "com.cartags.lifetime"

    // Free tier limits
    static let maxFreeCountries = 3
    static let maxFreeRequestsPerDay = 5

    var isPremium: Bool { ... }          // true if active subscription or lifetime purchase
    var selectedCountries: [String] { ... } // up to 3 country codes, stored in UserDefaults
    var requestsToday: Int { ... }       // count from UserDefaults, reset daily

    func canSearch(countryCode: String) -> Bool { ... }
    // Returns true if: isPremium OR (country in selectedCountries AND requestsToday < 5)

    func recordRequest() { ... }
    // Increments requestsToday in UserDefaults (with date check to reset daily counter)

    func addCountry(_ code: String) { ... }
    // Adds to selectedCountries if count < 3, persists in UserDefaults

    func removeCountry(_ code: String) { ... }

    // StoreKit 2
    func purchase(_ productID: String) async throws { ... }
    func restorePurchases() async throws { ... }
    func checkEntitlements() async { ... } // call on app launch
}
```

Store `selectedCountries` and daily counter in `UserDefaults`:
- key `"selected_countries"` → `[String]` (JSON encoded)
- key `"requests_date"` → `String` (yyyy-MM-dd)
- key `"requests_count"` → `Int`

---

### 6. PaywallView

**File:** `Features/Paywall/PaywallView.swift`

Simple paywall sheet shown when free limit is hit:

- Title: "Unlock CarTags Pro"
- Subtitle: "All countries · Unlimited searches"
- Two buttons:
  - "€1 / month" → calls `StoreService.shared.purchase(monthlyID)`
  - "€12 lifetime" → calls `StoreService.shared.purchase(lifetimeID)`
- "Restore purchases" text button at bottom
- Dismiss button (top trailing)

---

### 7. CountryPickerView

**File:** `Features/Settings/CountryPickerView.swift`

Sheet for free users to pick their 3 countries:

- List of all countries with checkmarks
- Selected countries show a checkmark
- Tapping adds/removes (max 3 enforced with alert if over limit)
- "Done" button dismisses

Show this sheet:
- On first launch (if `selectedCountries` is empty)
- From a settings gear icon in `BrowseView` toolbar (free users only)

---

### 8. Integrate StoreService into SearchViewModel

Update `Features/Search/SearchViewModel.swift`:

```swift
func search() {
    let trimmed = searchCode.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty else { return }

    // Check if result would be from an allowed country
    // After fetching results, filter by allowed countries if not premium
    // If limit hit → set showPaywall = true instead of showing results

    isLoading = true
    hasSearched = true
    errorMessage = nil

    do {
        var found = try DatabaseService.shared.searchByCode(trimmed.uppercased())

        if !StoreService.shared.isPremium {
            found = found.filter {
                StoreService.shared.canSearch(countryCode: $0.countryCode)
            }
            if found.isEmpty && !StoreService.shared.isPremium {
                showPaywall = true
                isLoading = false
                return
            }
        }

        StoreService.shared.recordRequest()
        results = found
    } catch {
        errorMessage = error.localizedDescription
        results = []
    }

    isLoading = false
}
```

Add `var showPaywall = false` to `SearchViewModel`.
Add `.sheet(isPresented: $viewModel.showPaywall) { PaywallView() }` to `SearchView`.

---

### 9. Localizable.xcstrings

Add all user-facing string keys. Create or update `Localizable.xcstrings` with these keys and English values:

| Key | English value |
|-----|--------------|
| `search.placeholder` | `Enter plate code (e.g. M, WU, KA)` |
| `search.empty_prompt` | `Enter a license plate code` |
| `search.no_results` | `No results for "%@"` |
| `browse.title` | `Browse` |
| `search.title` | `Search` |
| `paywall.title` | `Unlock CarTags Pro` |
| `paywall.subtitle` | `All countries · Unlimited searches` |
| `paywall.monthly` | `€1 / month` |
| `paywall.lifetime` | `€12 lifetime` |
| `paywall.restore` | `Restore purchases` |
| `countries.picker.title` | `Choose your 3 countries` |
| `countries.picker.limit` | `You can select up to 3 countries` |
| `error.title` | `Error` |
| `button.ok` | `OK` |
| `button.done` | `Done` |

---

## Checklist before finishing

- [ ] Project builds with `Cmd+B` — zero errors, zero warnings
- [ ] `ContentView` shows `TabView` with Search and Browse tabs
- [ ] Search tab: entering a code returns results from DB
- [ ] Browse tab: shows list of countries, tapping opens regions list
- [ ] Flag emojis render correctly in all lists
- [ ] `flagEmoji()` is defined only once in `Utils/FlagEmoji.swift`
- [ ] No business logic inside any View
- [ ] All ViewModels use `@Observable`, not `ObservableObject`
- [ ] All user-facing strings use `String(localized:)` with keys from `Localizable.xcstrings`
- [ ] `StoreService` compiles (StoreKit 2 import)
- [ ] `PaywallView` presents as sheet when free limit is hit
- [ ] `CountryPickerView` shows on first launch if no countries selected

---

## How to run

```bash
open CarTags.xcodeproj
# Then Cmd+R in Xcode to run on simulator
```

## Key constraints

- iOS 17+ only — use `@Observable`, not `ObservableObject`
- Read-only DB — never write to `cartags.db`
- GRDB is already added via SPM — do not re-add
- All new files must be added to the `CarTags` target
- `CLAUDE.md` is excluded from target (not compiled) — keep it that way
