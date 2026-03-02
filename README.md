# DzisWLodzi

**DzisWLodzi** ("Today in Łódź") is a native iOS app that lets you discover events, attractions, and places of interest in **Łódź, Poland**. All content is fetched live from the [dziswlodzi.pl](https://www.dziswlodzi.pl) web service.

> **Note:** When this project was originally built, the COVID-19 pandemic significantly reduced the number of live events available from the data source.
> For a richer dataset that better exercises the UI and navigation flows, check out the **`covid19`** branch.

![dwl](https://github.com/cyvn7/DzisWLodzi/assets/42326412/68479e0c-e08d-4fa2-9051-3f58fb4a0045)

---

## Table of Contents

1. [Overview](#overview)
2. [Key Features](#key-features)
3. [Architecture & Patterns](#architecture--patterns)
4. [Project Structure](#project-structure)
5. [Networking & Data Source](#networking--data-source)
6. [Persistence & Caching](#persistence--caching)
7. [UI & Navigation](#ui--navigation)
8. [Dependencies](#dependencies)
9. [Build & Run](#build--run)
10. [Configuration](#configuration)
11. [Testing](#testing)
12. [Roadmap](#roadmap)

---

## Overview

DzisWLodzi is a city-guide companion for Łódź. The app connects directly to the public JSON endpoints exposed by **dziswlodzi.pl** to surface:

- **Upcoming events** — concerts, exhibitions, festivals, and more, filterable by category.
- **Places & attractions** — local businesses, museums, sports facilities, and points of interest plotted on an interactive map.

The project demonstrates end-to-end iOS development: live API integration, MapKit-based map interaction, image caching, category-based filtering with persisted user preferences, and clean UIKit navigation.

---

## Key Features

| Feature | Description |
|---|---|
| **Interactive map** | Apple MapKit view with custom colour-coded pin annotations for each place category. |
| **Category filtering** | Users can filter both map pins and event lists by category; selections survive app restarts via `UserDefaults`. |
| **Event listing** | Tabular list of upcoming events with cover images and formatted Polish-locale dates. |
| **Place detail sheet** | Bottom-sheet detail panel showing address, opening hours, prices, description, phone, website, and get-directions actions. |
| **Event detail view** | Full-screen event card with HTML-stripped description, date, image, and ticket/website link. |
| **Live data** | All content is fetched on demand from the dziswlodzi.pl JSON API; there is no bundled static dataset. |
| **Image caching** | Kingfisher memory-caches downloaded images with a 600-second TTL and uses `DownsamplingImageProcessor` for efficient memory use. |
| **Loading UX** | A branded spinner overlay (Łódź orange, `#F9AF20`) blocks interaction while network requests are in progress. |
| **Deep-link to Maps** | "Get directions" buttons hand off coordinates to the native Maps app via `MKMapItem`. |

---

## Architecture & Patterns

The project follows a **UIKit + MVC** approach driven by Storyboard segues, consistent with a standard entry-level iOS application.

### Networking layer (`JSONClass`)

A single static helper class (`JSONClass`) wraps Alamofire. It accepts an array of relative URL paths, fires each request concurrently, and calls a single completion closure once the last response has returned. Callers receive either an array of `SwiftyJSON.JSON` values (one per URL) or a pre-built `UIAlertController` ready to present an error message.

```swift
JSONClass.getJSON(linkArray: [...]) { jsonFiles, alert in
    if jsonFiles != [JSON]() { /* use data */ }
    else { present(alert, animated: true) }
}
```

### View controllers

Each screen is a `UIViewController` or `UITableViewController` subclass. Data flows forward through `prepare(for:sender:)` segues; there is no shared state manager or reactive binding layer.

### Category filtering

Selected category IDs are written to and read from `UserDefaults` under the key `"selectedCategories"`. `MapViewClass` observes `UserDefaults.didChangeNotification` so the map refreshes automatically when the filter sheet is dismissed.

### HTML sanitisation

Server responses may contain inline HTML in description fields. A `StringProtocol` extension provides `.html2String` and `.html2AttributedString` computed properties that use `NSAttributedString` with `.documentType: .html` to strip tags cleanly before display.

---

## Project Structure

```
DzisWLodzi/
├── DzisWLodzi/
│   ├── View Classes/
│   │   ├── JSONClass.swift          # Static networking helper (Alamofire + SwiftyJSON)
│   │   ├── MapView.swift            # Map screen: MKMapView, pin display, category filter,
│   │   │                            #   detail panel, location services (MapViewClass + LodzPin)
│   │   ├── MapObjDesc.swift         # Place detail sheet: hours, prices, phone, website, route
│   │   ├── MapCategoryView.swift    # Map category filter selector (persists to UserDefaults)
│   │   ├── EventsCategoryView.swift # Event category list (entry point to events flow)
│   │   ├── EventsView.swift         # Event list table view (UITableViewController)
│   │   ├── EventCellClass.swift     # Custom UITableViewCell for event rows
│   │   └── EventDesc.swift          # Full event detail view
│   ├── Assets.xcassets/             # Images, app icon, custom map-pin assets per category
│   ├── Fonts/                       # Bundled TTF fonts: Raleway (Bold/Regular/SemiBold),
│   │                                #   Lato (Bold/Semibold/Regular)
│   ├── Design files/                # UI design resources (not compiled into the app binary)
│   └── Other files/
│       ├── Info.plist               # App metadata, permissions, font declarations
│       └── DzisWLodzi.xcdatamodeld  # CoreData model (defined but not currently used)
├── DzisWLodzi.xcworkspace/          # Xcode workspace (open this file, not .xcodeproj)
├── DzisWLodzi.xcodeproj/            # Xcode project file
├── Podfile                          # CocoaPods dependency manifest
└── Podfile.lock                     # Locked dependency versions
```

---

## Networking & Data Source

**Base URL:** `https://www.dziswlodzi.pl`

All requests go through `JSONClass.getJSON(linkArray:completion:)`, which constructs full URLs by prepending the base URL.

| Endpoint | Used by | Description |
|---|---|---|
| `/company-directory/company/json` | `MapViewClass` | Returns a JSON object of all places keyed by integer ID. Each entry includes `geo_latitude`, `geo_longitude`, `img`, `title`, `additional_categories`, `company_www`, `company_address`, `company_city`, `company_zip`, `company_phone`, `prices_details`, `hours`, `description`. |
| `/company-directory/company/json-categories` | `MapViewClass` | Returns all place categories with `id`, `name`, `parent_id`. Used to resolve category names and assign colour-coded pin images. |
| `/event/event/json?dateStart={unix}&category_id={id}` | `EventsView` | Returns an array of upcoming events from the given Unix timestamp, optionally filtered by category. Each entry includes `title`, `date_start` (Unix timestamp), `img`, `description`, `url_buy`. |
| `/event/event/json-categories` | `EventsCategoryView` | Returns event categories; the app filters to top-level categories (`parent_id == 1`). |

HTTP image URLs returned within JSON responses are upgraded to HTTPS before use via `replacingOccurrences(of: "http", with: "https")`.

---

## Persistence & Caching

### UserDefaults

The key `"selectedCategories"` stores an `Array<Int>` of the category IDs chosen by the user for map display. An empty array means "show all categories". The map observes `UserDefaults.didChangeNotification` and re-renders annotations whenever this value changes.

### Image cache (Kingfisher)

- Memory cache TTL: **600 seconds**.
- `DownsamplingImageProcessor` resizes each image to the target view's `CGSize` before caching, keeping memory pressure low.
- A solid `#F9AF20` (Łódź orange) `UIImage` is used as a placeholder while images load.
- Fade-in transition applied on successful load (`KingfisherOptionsInfoItem.transition(.fade(1))`).

### CoreData

A `DzisWLodzi.xcdatamodeld` schema file is present in the project but the managed object context is not initialised and no entities are read or written at runtime. It was scaffolded for a potential offline-first future enhancement.

---

## UI & Navigation

The app uses a **UINavigationController**-based hierarchy driven by Storyboard segues. The navigation bar is hidden on the map screen and shown on all child screens.

```
MapViewClass  (root / first tab)
├── [segue: "goToCat"]   → UINavigationController → MapCategoryView
│                            (modal: select map category filters)
└── [segue: "toDetails"] → UINavigationController → MapObjDesc
                             (modal pageSheet: place detail)

EventsCategoryView  (second tab)
└── [segue: "goToEvents"] → UINavigationController → EventsView
                              └── [segue: "goToDesc"] → EventDesc
                                    (event detail)
```

### Screens

| Screen | Class | Description |
|---|---|---|
| **Map** | `MapViewClass` | Full-screen `MKMapView`. Loads all places on `viewDidLoad` and drops custom pins. Tapping a pin reveals a bottom panel with the place thumbnail and title. A second tap opens the full detail sheet. Action buttons: centre on user location, get directions, open website, filter categories, open detail sheet. |
| **Map category filter** | `MapCategoryView` | Modal table view. Displays Monument (`parent_id == 5`) and Attraction (`parent_id == 7`) sub-categories in two sections. Selection is saved to `UserDefaults`. |
| **Place detail** | `MapObjDesc` | Page-sheet modal. Displays cover image (passed from the map screen), title, address, opening hours (🕑), prices (💵), HTML-stripped description, and action buttons: phone, website, get directions. Phone and website buttons are disabled when the corresponding field is empty. |
| **Event categories** | `EventsCategoryView` | Table view listing top-level event categories fetched from the API. Tapping a row navigates to the event list for that category. |
| **Event list** | `EventsView` | `UITableViewController` using a custom `EventCell` nib. Displays event cover image, title, and formatted date (Polish day name + `dd-MM-yyyy HH:mm`). A `JHSpinner` overlay is shown during the network request. |
| **Event detail** | `EventDesc` | Displays the event cover image, title, formatted date, HTML-stripped description, and a button linking to the ticket or info page. |

### Custom map pins

Pin images are named `ShopPin`, `SportPin`, `AquaPin`, `EcoPin`, `MuseumPin`, `AmuPin`, and `EmptyPin` (fallback). Category assignment is performed in `mapView(_:viewFor:)` by matching against specific category IDs and parent category IDs resolved from the categories JSON.

---

## Dependencies

Managed via **CocoaPods** (`Podfile` / `Podfile.lock`).

| Pod | Version | Role |
|---|---|---|
| [Alamofire](https://github.com/Alamofire/Alamofire) | `~> 5.0.0-rc.3` | HTTP networking — concise request/response handling with built-in validation. |
| [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) | `~> 4.0` | JSON parsing — subscript-based access that handles missing or type-mismatched fields gracefully. |
| [Kingfisher](https://github.com/onevcat/Kingfisher) | `~> 5.12` | Asynchronous image downloading with memory/disk caching and on-the-fly image processing. |
| [JHSpinner](https://github.com/HiIamJeff/JHSpinnerView) | latest | Full-screen spinner overlay for loading states. |

---

## Build & Run

### Prerequisites

- **Xcode 12+** (Swift 5)
- **CocoaPods** — install with `sudo gem install cocoapods` if not already present
- An iOS device or simulator running **iOS 10.0+**
- An active internet connection (all data is fetched live)

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/cyvn7/DzisWLodzi.git
cd DzisWLodzi

# 2. Install CocoaPods dependencies
pod install

# 3. Open the workspace (not the .xcodeproj)
open DzisWLodzi.xcworkspace
```

In Xcode:

1. Select your target device or simulator from the scheme selector.
2. Press **⌘R** (or **Product → Run**) to build and launch the app.

> **Tip:** To see a fuller events dataset, switch to the `covid19` branch before running.

---

## Configuration

### Location permission

The app requests *When In Use* location access to centre the map on the user. The usage description string is declared in `Info.plist` under `NSLocationWhenInUseUsageDescription`. Update this string before submitting to the App Store.

### API base URL

The base URL is defined as a constant in `MapViewClass`:

```swift
let dwlURL = "https://www.dziswlodzi.pl"
```

And used directly in `JSONClass.getJSON`:

```swift
AF.request("https://www.dziswlodzi.pl\(link)")
```

Update both locations if the data source changes.

### Custom fonts

The following fonts are bundled and declared in `Info.plist` under `UIAppFonts`:

- `Raleway-Bold.ttf`, `Raleway-Regular.ttf`, `Raleway-SemiBold.ttf`
- `Lato-Bold.ttf`, `Lato-Semibold.ttf`, `Lato-Regular.ttf`

---

## Testing

The project does not currently include a unit-test or UI-test target. Manual testing against the live API is the primary validation method.

Potential areas for future test coverage:

- **`JSONClass`** — mock URLSession / Alamofire responses to verify correct JSON parsing and error propagation.
- **`MapViewClass.displayAnnotations()`** — unit-test the category-to-pin-image mapping logic with synthetic JSON fixtures.
- **UI tests** — verify navigation flows using `XCUITest`.

---

## Roadmap

- [ ] **Offline support** — persist fetched data using the existing CoreData schema so the app is usable without a network connection.
- [ ] **Unit tests** — add XCTest targets covering the networking helper and annotation-display logic.
- [ ] **SwiftUI migration** — rewrite views in SwiftUI for a more declarative, maintainable UI layer.
- [ ] **Alamofire version pin** — update Alamofire from the release-candidate pin (`5.0.0-rc.3`) to a stable release.
- [ ] **Localisation** — externalise the remaining Polish-language strings (error messages, day names) to `Localizable.strings`.
- [ ] **Error recovery** — replace one-shot alert dialogs with retry-capable error states in each view controller.
- [ ] **Search** — add a search bar to filter places and events by keyword without leaving the current screen.
