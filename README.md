<p align="center">
  <img src="pages/static/FieldGlance.png" alt="Field Glance app icon">
</p>

<h1 align="center">Field Glance</h1>

<p align="center">
  Local time, UTC time, and magnetic declination — at a glance.<br>
  For iPhone and Apple Watch.
</p>

<p align="center">
  <b>
    <a href="https://field-glance.liam.earth">Website</a>
    <!-- TODO: Add once approved: · <a href="https://apps.apple.com/app/idXXXXXXXXXX">App Store</a> -->
  </b>
</p>

---

Three pieces of information on a black screen...

- **Local time** — date and time in your current time zone
- **UTC** — date and time in UTC
- **Magnetic declination** — the current value at your location indicated with a compass
  arrow

...and nothing else. No accounts, no settings, no network requests.

## Targets

| Target              | Description                            |
| ------------------- | -------------------------------------- |
| `FieldGlance`       | iPhone app                             |
| `FieldGlanceWatch`  | Apple Watch app                        |
| `FieldGlanceWidget` | Watch complications (UTC, declination) |

## Requirements

- Xcode 27 or later
- iOS and watchOS versions: see **Minimum Deployments** in each target's General tab

## Website

The website at [field-glance.liam.earth](https://field-glance.liam.earth) serves as the
App Store support page and hosts the privacy policy. It's built with
[Zensical](https://zensical.org) from the Markdown in [`pages/`](pages/), configured in
[`zensical.toml`](zensical.toml). To preview it locally:
```sh
uvx zensical@0.1.0 serve
```

Pushing changes under `pages/` to `main` deploys the site to GitHub Pages.

The home page screenshots are shown inside Apple's
[product bezels](https://developer.apple.com/design/resources/#product-bezels). The raw
screenshots live in [`screenshots/`](screenshots/), named for the device they match (a
screenshot must be the same size as its bezel's screen opening). The bezels aren't
checked in, so download them from Apple and place them in
`screenshots/apple-product-bezels/` under the file names that
[`scripts/frame_screenshots.py`](scripts/frame_screenshots.py) expects. Then regenerate
the framed images in `pages/static/screenshots/`:
```sh
uv run scripts/frame_screenshots.py
```

## App icon

### Files

- [`FieldGlance/FieldGlance.icon`](FieldGlance/FieldGlance.icon) is the Icon Composer
  file that Xcode builds. It's a folder: `Assets/field-glance.svg` is the artwork, and
  `icon.json` holds the composition (background fill, effects, per-platform tweaks).
- [`pages/static/FieldGlance.png`](pages/static/FieldGlance.png) is a PNG export of the
  icon for the website and this README. It isn't used in the app.

### Artwork

The SVG has a 1024 × 1024 pixel canvas (`viewBox="0 0 1024 1024"`) and three elements:

| Element                        | Color     |
| ------------------------------ | --------- |
| the letter F                   | `#0091ff` |
| the letter G                   | `#ff9230` |
| arrow leaning like a backslash | `#30d158` |

These match the app's `localColor`, `utcColor`, and `declColor` (the system blue,
orange, and green in dark mode) and the `--fg-*` colors in
[`pages/stylesheets/extra.css`](pages/stylesheets/extra.css). Keep all three in sync.

Rules for the SVG:

- No background, blur, shadows, or gradients. Those are applied in Icon Composer.
- Text converted to outlines.

### Updating the icon

1. With Icon Composer closed, edit `FieldGlance/FieldGlance.icon/Assets/field-glance.svg`
   in VectorCraft, Illustrator, Inkscape, or a text editor. Keep the file name, since
   `icon.json` refers to it by name.
2. Open `FieldGlance/FieldGlance.icon` in Icon Composer and check the previews: Default,
   Dark, and watchOS. Watch icons are circular, so check that nothing is clipped.
3. Export a 128 × 128 px PNG to `pages/static/FieldGlance.png`, and commit it together
   with the `.icon`.

### Xcode setup

- The **App Icon** field on the General tab of both the iPhone and watch targets must
  say `FieldGlance`, matching the file name without `.icon`.
- The watch target needs the file too. `FieldGlance.icon` lives in the iPhone folder, so
  give it the watch target under Target Membership.

### Composition settings

These live only in the `.icon` file's `icon.json`, so note them here if they change.

- **Background fill:** `#000000` (use the same fill for Default and Dark)
- **Groups:** The full SVG is imported as a single group
- **Effects:** Disable shadow on the _group_

## Notes

Declination is computed with the
[World Magnetic Model 2025](https://www.ncei.noaa.gov/products/world-magnetic-model)
(WMM2025), which is valid through 2029. The app shows a warning when the model is out of
date.

> 🤖 Built using Claude and Kiro, with a human in the loop.
