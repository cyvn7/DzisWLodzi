# DzisWLodzi

DzisWLodzi is an iOS app that helps you discover what’s happening in **Łódź, Poland**—events, places, and local highlights—based on data sourced from **dziswlodzi.pl**.

> Note: At the time this project was originally built, the COVID-19 pandemic significantly reduced the availability of up-to-date events from the source.  
> If you want to see the app with a dataset that better demonstrates the UI and flows, check out the **`covid19`** branch.

![dwl](https://github.com/cyvn7/DzisWLodzi/assets/42326412/68479e0c-e08d-4fa2-9051-3f58fb4a0045)

## Features

- **City discovery experience** for Łódź
- **Apple Maps integration** to browse places and view locations on the map
- **Remote content loading** (JSON + images) from the website’s endpoints
- **Loading-state UX** with a dedicated spinner overlay while network requests are in progress

## Tech Stack

- **Language:** Swift (iOS)
- **Maps:** Apple Maps / MapKit
- **Dependency Management:** CocoaPods

### Key Dependencies

- **Alamofire** — Networking layer for fetching remote content (e.g., JSON endpoints)
- **SwiftyJSON** — Convenient JSON parsing (useful when working with multiple differently-shaped endpoints)
- **Kingfisher** — Image downloading, caching, and processing
- **JHSpinner** — Loading indicator and overlay UX


## Architecture & Implementation Notes

This project focuses on building a practical, end-to-end iOS client for a real-world data source:

- **Networking** is handled via Alamofire to keep requests concise and maintainable.
- **Parsing** uses SwiftyJSON to comfortably handle inconsistent or evolving JSON structures.
- **Images** are loaded with caching to improve perceived performance and reduce redundant downloads.
- **UX during loading** is improved via an overlay spinner so the user always understands what the app is doing.
