# Liquid Persona — macOS Menu Bar App

A disposable identity generator with a **Liquid Glass** UI. One click creates a
random Indian name + live temporary email via Mail.tm, auto-copies to clipboard,
and polls for incoming mail every 7 seconds.

---

## Requirements

| Item | Minimum |
|---|---|
| Xcode | 14.1 + |
| macOS (build) | 13.0 Ventura + |
| macOS (run) | 13.0 Ventura + |
| Swift | 5.7 + |

---

## Project Setup in Xcode (5 minutes)

### Step 1 — Create a new macOS App project

1. Open **Xcode → File → New → Project**
2. Choose **macOS → App** → click **Next**
3. Fill in:
   - **Product Name**: `LiquidPersona`
   - **Bundle Identifier**: `com.yourname.liquidpersona`
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: None
   - Uncheck **Include Tests**
4. Choose a save location → **Create**

---

### Step 2 — Add source files

Delete the auto-generated `ContentView.swift` and `LiquidPersonaApp.swift` that
Xcode created (move to Trash). Then:

1. In the Project Navigator, right-click on the yellow `LiquidPersona` group
2. **Add Files to "LiquidPersona"…**
3. Navigate to this folder and select **all files** inside `Sources/` and
   `Resources/Info.plist` — ensure **"Copy items if needed"** is checked and
   **"Create groups"** is selected.
4. Xcode will create matching groups automatically.

Your final group tree should look like:

```
LiquidPersona/
├── App/
│   └── LiquidPersonaApp.swift
├── Views/
│   ├── ContentView.swift
│   ├── PersonaCardView.swift
│   ├── InboxView.swift
│   └── MessageDetailView.swift
├── Components/
│   ├── LiquidGlassBackground.swift
│   └── GlassButton.swift
├── Models/
│   └── MailTMModels.swift
├── Services/
│   ├── MailTMService.swift
│   └── PersonaGenerator.swift
├── ViewModels/
│   └── PersonaViewModel.swift
└── Resources/
    └── Info.plist (replace existing)
```

---

### Step 3 — Replace Info.plist

1. Select the existing `Info.plist` in Xcode's Project Navigator
2. Right-click → **Show in Finder**
3. Replace it with the `Resources/Info.plist` from this repo
4. **Important**: in the Xcode target's **Info** tab, confirm that
   `Application is agent (UIElement)` → `YES` is present.  
   If not, add key `LSUIElement` = `Boolean YES` manually.

---

### Step 4 — Add the entitlements file

1. Drag `LiquidPersona.entitlements` into the Project Navigator root group
2. Select the **LiquidPersona target** → **Signing & Capabilities** tab
3. Under **App Sandbox**, confirm **Outgoing Connections (Client)** is checked.
   If the App Sandbox capability is not present, click **+ Capability** and add it.

---

### Step 5 — Set Deployment Target

1. Select the **LiquidPersona project** (blue icon) → **Info** tab
2. Set **macOS Deployment Target** to **13.0**

---

### Step 6 — Build & Run

Press **⌘R**. The app will not appear in the Dock — look for the key-person
icon (⌨︎) in your **Menu Bar** (top-right area of the screen). Click it to open
the Liquid Glass popover.

---

## Architecture Overview

```
LiquidPersonaApp          ← @main, hosts MenuBarExtra(.window)
       │
       └── ContentView    ← ZStack: LiquidGlassBackground + .ultraThinMaterial
               │                    + PersonaCardView / InboxView / MessageDetailView
               │
       PersonaViewModel   ← @MainActor ObservableObject
               │              • generatePersona()  — domain → account → token
               │              • startPolling()     — Task loop, 7s sleep
               │              • loadMessageDetail()
               │
       MailTMService       ← async/await, URLSession
       PersonaGenerator    ← pure random name + username from built-in lists
```

### Key Design Choices

| Concern | Approach |
|---|---|
| Thread safety | `@MainActor` on ViewModel; all published writes are on main |
| Polling lifecycle | `Task` + `Task.sleep(nanoseconds:)`; cancelled on refresh |
| Stale update guard | `generation` counter — polling checks its generation before writing |
| Liquid background | `TimelineView(.animation)` + `sin`/`cos` offset `Circle` orbs |
| Glass effect | `.ultraThinMaterial` layered over the animated background |
| Transitions | `.asymmetric` slide for detail view; `.spring` for persona card |

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Build error: `@main` conflict | Delete Xcode-generated `LiquidPersonaApp.swift` before adding ours |
| App appears in Dock | Ensure `LSUIElement = true` in Info.plist |
| `noDomainAvailable` error | Mail.tm may be temporarily down; tap **Burn & Refresh** to retry |
| `accountCreationFailed(422,…)` | Username collision — tap **Burn & Refresh** again |
| Inbox stays empty | Email must be sent to the exact address shown; polling is every 7 s |
| Network sandbox error | Ensure **Outgoing Connections (Client)** is on in Signing & Capabilities |

---

## API Reference — Mail.tm

All calls go to `https://api.mail.tm`:

| Endpoint | Method | Purpose |
|---|---|---|
| `/domains` | GET | List active domains |
| `/accounts` | POST | Create inbox (address + password) |
| `/token` | POST | Exchange credentials for JWT |
| `/messages` | GET | List messages (Bearer token) |
| `/messages/{id}` | GET | Fetch full message (Bearer token) |
