# Liquid Glass Catalyst

UIKit + **Mac Catalyst** playground for Apple **Liquid Glass** (`UIGlassEffect`, glass buttons, material demos).

**This is the recommended repo** if you want to experiment with Liquid Glass on Mac.

There is also a native AppKit attempt — **[liquid-glass-cocoa](https://github.com/martinshaw/liquid-glass-cocoa)** — but that version is **buggy and unfinished**. Prefer this Catalyst project.

## Requirements

- macOS 26+ (for Liquid Glass)
- Xcode 26+

## Run

1. Open `LiquidGlassCatalyst.xcodeproj` in Xcode.
2. Select the **LiquidGlassCatalyst** scheme.
3. Choose a Mac Catalyst / My Mac destination.
4. Press **⌘R**.

## Demos

- Fidget Kit — classic UIKit controls under glass
- Glass Buttons
- Tint & Style
- Droplet Merge
- Materialize
- Floating Cluster

## Releases

GitHub Actions builds a Mac Catalyst `.app` zip on `v*` tags, or via **Actions → Release Mac App → Run workflow**.

See the [Releases](https://github.com/martinshaw/liquid-glass-catalyst/releases) page for downloadable builds.

## Related

| Repo | Stack | Status |
|------|--------|--------|
| **liquid-glass-catalyst** (this repo) | UIKit + Mac Catalyst | Stable playground |
| [liquid-glass-cocoa](https://github.com/martinshaw/liquid-glass-cocoa) | Native AppKit | Experimental / buggy — try this repo instead |
