# DzisWLodzi

**DzisWLodzi** ("Today in Łódź") is a native iOS application for discovering events, attractions, and local points of interest in **Łódź, Poland**. It surfaces real-time data from [dziswlodzi.pl](https://www.dziswlodzi.pl) and presents it through an interactive map and a categorised events browser — all wrapped in a clean, brand-consistent UI.

> **Note:** This project was originally built during the COVID-19 pandemic, when live event data from the source API was sparse. For a richer dataset that better showcases the UI and user flows, check out the **`covid19`** branch.

![DzisWLodzi app screenshot](https://github.com/cyvn7/DzisWLodzi/assets/42326412/68479e0c-e08d-4fa2-9051-3f58fb4a0045)

---

## Table of Contents

- [Overview & Motivation](#overview--motivation)
- [Features](#features)
- [Tech Stack & Dependencies](#tech-stack--dependencies)
- [Architecture Overview](#architecture-overview)
- [Data Sources & Networking](#data-sources--networking)
- [Caching & Persistence](#caching--persistence)
- [UI & Navigation](#ui--navigation)
- [Setup & Run Instructions](#setup--run-instructions)
- [Screenshots](#screenshots)
- [Testing & Quality](#testing--quality)
- [Roadmap & Future Improvements](#roadmap--future-improvements)
- [License](#license)

---

## Overview & Motivation

Łódź is Poland's third-largest city, home to a rich cultural scene, architecture, and events. **DzisWLodzi** was built to make it easy for residents and visitors to answer one simple question: *"What can I do in Łódź today?"*

The app fetches live data from the city's dedicated cultural portal and presents it in two complementary ways:

1. **An interactive map** — browse attractions, monuments, museums, sports venues, and more, filtered by category, with inline details and one-tap routing.
2. **An events browser** — explore upcoming happenings organised by category, with dates, descriptions, images, and links to purchase tickets or visit official pages.

The project demonstrates a complete, end-to-end iOS client built against a real-world REST API, covering networking, JSON parsing, image caching, location services, and a polished custom UI.

---

## Features

| Feature | Description |
|---------|-------------|
| 🗺️ **Interactive Map** | Browse the city's attractions on a full-screen Apple Maps view with custom category pins |
| 📍 **Location Services** | Centres the map on the user's current position with permission handling |
| 🎫 **Events Browser** | Hierarchical category → event list → event detail navigation flow |
| 🏛️ **Place Details** | Address, opening hours, prices, phone number, description, and website for every location |
| 🎨 **Category Filtering** | Filter map pins by Monuments, Attractions, Sports, Museums, Eco, Shopping, and Amusement |
| 🔀 **One-Tap Routing** | Hand off a selected location to Apple Maps for turn-by-turn navigation |
| 🌐 **Website Integration** | Deep-link directly to a place's or event's webpage from within the app |
| 📸 **Cached Remote Images** | Event and place images are downloaded and cached for fast, seamless loading |
| ⏳ **Loading States** | A full-screen spinner overlay signals network activity so the user is never left guessing |
| 🇵🇱 **Polish Date Formatting** | Event dates are rendered with localised Polish day and month names |

---

## Tech Stack & Dependencies

### Language & Platform

| Item | Value |
|------|-------|
| Language | Swift 5 |
| Platform | iOS 10.0+ |
| UI Framework | UIKit (Storyboard-based) |
| Dependency Manager | CocoaPods |

### Apple Frameworks

| Framework | Usage |
|-----------|-------|
| **MapKit** | Interactive map, custom annotations, region management |
| **CoreLocation** | User location tracking and authorisation |
| **CoreData** | Persistent store setup (infrastructure in place for future offline caching) |

### Third-Party Pods

| Pod | Version | Purpose |
|-----|---------|---------|
| [Alamofire](https://github.com/Alamofire/Alamofire) | `~> 5.0.0-rc.3` | HTTP networking — all JSON API requests |
| [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) | `~> 4.0` | Ergonomic JSON parsing across endpoints with varying shapes |
| [Kingfisher](https://github.com/onevcat/Kingfisher) | `~> 5.12` | Async image downloading, on-disk/in-memory caching, and downsampling |
| [JHSpinner](https://github.com/HiIamJeff/JHSpinner) | latest | Loading overlay spinner with rounded-square design |

### Custom Assets

- **Fonts:** Raleway (Bold, Regular, SemiBold) and Lato (Regular, Black, Bold, SemiBold) for consistent brand typography
- **Map Pins:** Six custom pin images (`AquaPin`, `EcoPin`, `MuseumPin`, `SportPin`, `ShopPin`, `AmuPin`) to differentiate location categories at a glance
- **Brand Colour:** `#F9AF20` — the so-called *łódzka pomarańcz* (Łódź orange), applied throughout the UI

---

## Architecture Overview

The project follows a **Model-View-Controller (MVC)** pattern, consistent with UIKit conventions, with a thin shared networking utility layer.

```
┌─────────────────────────────────────────────────────┐
│                    Presentation Layer                │
│                                                      │
│  MapView  ──►  MapObjDesc        (map flow)          │
│               MapCategoryView                        │
│                                                      │
│  EventsCategoryView  ──►  EventsView  ──►  EventDesc │
│                                   (events flow)      │
└───────────────────────┬─────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────┐
│                   Networking Layer                   │
│                                                      │
│  JSONClass  —  shared Alamofire + SwiftyJSON helper  │
└───────────────────────┬─────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────┐
│                  Data / Persistence                  │
│                                                      │
│  UserDefaults  —  category filter preferences        │
│  Kingfisher cache  —  remote images                  │
│  CoreData stack  —  ready for future offline use     │
└─────────────────────────────────────────────────────┘
```

### Key Classes

| Class | Role |
|-------|------|
| `JSONClass` | Centralised network utility; accepts an array of endpoint paths, fires concurrent Alamofire requests, and delivers `[JSON]` or an error alert via a completion closure |
| `MapViewClass` | Root map screen; owns `MKMapView`, location services, annotation rendering, and the inline detail card |
| `LodzPin` | `MKAnnotation` subclass that carries a location ID used to look up full details in a dictionary keyed by server ID |
| `MapCategoryView` | Category filter sheet; persists the user's selection to `UserDefaults` and triggers a `didChangeNotification` to re-render the map |
| `MapObjDesc` | Full-screen detail view for a map location; renders HTML-to-plaintext descriptions, handles phone calls, routing, and web links |
| `EventsCategoryView` | Table view listing event categories fetched from the API; passes the selected category ID downstream |
| `EventsView` | Table view of events for a chosen category; formats dates with Polish day names |
| `EventDesc` | Detail view for a single event; shows image, date, HTML description, and a website button |
| `EventCellClass` | Reusable `UITableViewCell` subclass with a Kingfisher-backed background image |

---

## Data Sources & Networking

All data is served by **[dziswlodzi.pl](https://www.dziswlodzi.pl)** via JSON endpoints.

### Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /company-directory/company/json` | Full list of attractions and places |
| `GET /company-directory/company/json-categories` | Category hierarchy for the map filter |
| `GET /event/event/json?dateStart={timestamp}&category_id={id}` | Events starting from a given Unix timestamp in a given category |
| `GET /event/event/json-categories` | Category list for the events browser |

### Networking Pattern

`JSONClass.getJSON(linkArray:completion:)` accepts multiple paths and fires them all with `AF.request`. Responses are collected into a `[JSON]` array; once the final request completes the array (or a `UIAlertController` describing the failure) is delivered to the caller via an `@escaping` completion closure. This keeps each view controller free of boilerplate networking code.

---

## Caching & Persistence

| Mechanism | What is stored | Lifetime |
|-----------|---------------|---------|
| **Kingfisher image cache** | Downloaded place and event images (disk + memory, with downsampling to the display size) | Managed by Kingfisher's default policy; memory cache is capped; disk cache expires automatically |
| **UserDefaults** (`selectedCategories`) | Array of category IDs the user has toggled in the map filter sheet | Persists between launches; cleared when the app session is discarded via `SceneDelegate` |
| **CoreData** | `NSPersistentContainer` is initialised in `AppDelegate` | Stack is ready; no entities are currently written — reserved for a future offline/caching feature |

---

## UI & Navigation

The app uses a **UIKit Storyboard** layout (`Main.storyboard`) with two distinct navigation flows:

### Map Flow

```
MapViewClass (full-screen map)
  │
  ├─► [Tap pin]  ──►  Inline detail card (title + image)
  │                       │
  │                       └─► "Details" segue ──► MapObjDesc (modal page sheet)
  │                                                   ├─ Route (opens Apple Maps)
  │                                                   ├─ Call phone number
  │                                                   └─ Open website
  │
  └─► [Categories button] ──► MapCategoryView (modal)
                                  └─ Segmented control: Monuments / Attractions
                                  └─ Multi-select table → saves to UserDefaults
```

### Events Flow

```
EventsCategoryView (table of categories)
  └─► EventsView (table of events for selected category)
        └─► EventDesc (event detail: image, date, description, website)
```

### Design Language

- **Primary colour:** `#F9AF20` (*łódzka pomarańcz*) used on navigation bars, buttons, and overlays
- **Typography:** Raleway for headings and UI chrome; Lato for body text
- **Map pins:** Six distinct pin assets communicating category at a glance (Museum, Eco, Sport, Aqua, Shop, Amusement)
- **Loading states:** `JHSpinnerView` displayed as a full-screen overlay during every network operation

---

## Setup & Run Instructions

### Prerequisites

| Tool | Version |
|------|---------|
| Xcode | 12 or later |
| CocoaPods | 1.10 or later |
| iOS Simulator / Device | iOS 10.0+ |

### Steps

1. **Clone the repository**

   ```bash
   git clone https://github.com/cyvn7/DzisWLodzi.git
   cd DzisWLodzi
   ```

2. **Install CocoaPods dependencies**

   ```bash
   pod install
   ```

3. **Open the workspace** (not the `.xcodeproj`)

   ```bash
   open DzisWLodzi.xcworkspace
   ```

4. **Select a scheme and destination** in Xcode — any iPhone simulator or a physical device running iOS 10+.

5. **Build and run** with **⌘R**.

### Notes

- The app fetches all data from `https://www.dziswlodzi.pl`. An active internet connection is required for content to load.
- Location services are optional — the map will still display all attractions if permission is denied.
- No API keys or additional configuration are required.
- For the richest demo experience, use the **`covid19`** branch, which was developed against a more complete dataset.

---

## Screenshots

| Map View | Place Detail | Events |
|----------|-------------|--------|
| ![App Screenshot](https://github.com/cyvn7/DzisWLodzi/assets/42326412/68479e0c-e08d-4fa2-9051-3f58fb4a0045) | *(additional screenshots placeholder)* | *(additional screenshots placeholder)* |

---

## Testing & Quality

There are currently no automated unit or UI tests in the project. Quality is maintained through:

- Explicit error handling for all network requests, with user-facing alert dialogs on failure
- Defensive `guard` / `if let` unwrapping throughout view controllers
- Kingfisher's built-in failure placeholder (`placeholder.jpg`) when image loading fails

---

## Roadmap & Future Improvements

- [ ] **Offline mode** — Persist fetched places and events to CoreData so the app is usable without connectivity
- [ ] **Unit tests** — Cover `JSONClass` networking logic and date-formatting helpers
- [ ] **UI tests** — Automate the map and events flows using XCUITest
- [ ] **SwiftUI rewrite** — Migrate the UI layer to SwiftUI for declarative, testable view code
- [ ] **Accessibility** — Add VoiceOver labels to map pins and custom cells
- [ ] **Localisation** — Add English locale strings alongside the existing Polish copy
- [ ] **Deep links** — Support universal links from the dziswlodzi.pl website into the app
- [ ] **Push notifications** — Notify users about new events matching their category preferences
- [ ] **Alamofire version** — Update to Alamofire 5 stable release (currently pinned to `5.0.0-rc.3`)

---

## License

This project is provided for educational and portfolio purposes. No explicit license file is included in the repository. If you intend to use or build on this code, please contact the author for clarification.

© 2020 Maciej Przybylski. All rights reserved.
