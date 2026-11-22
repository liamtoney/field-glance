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

## Notes

Declination is computed with the
[World Magnetic Model 2025](https://www.ncei.noaa.gov/products/world-magnetic-model)
(WMM2025), which is valid through 2029. The app shows a warning when the model is out of
date.

The app icon is built from `icon/field-glance.svg`. See
[`icon/README.md`](icon/README.md) for how it is exported and composed.

> 🤖 Built using Claude and Kiro, with a human in the loop.
