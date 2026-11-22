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
    <a href="https://field-glance.liam.earth">Website</a> ·
    <a href="https://apps.apple.com/app/field-glance/id6835746100">App Store</a>
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

The colors of the F, G, and arrow in the icon match the app's `localColor`, `utcColor`,
and `declColor` (the system blue, orange, and green in dark mode) and the `--fg-*`
colors in [`pages/stylesheets/extra.css`](pages/stylesheets/extra.css). Keep all three
in sync.

### Updating the icon

1. With Icon Composer closed, edit
   `FieldGlance/FieldGlance.icon/Assets/field-glance.svg` in VectorCraft, Illustrator,
   Inkscape, or a text editor. Keep the file name, since `icon.json` refers to it by
   name.
2. Open `FieldGlance/FieldGlance.icon` in Icon Composer and check the previews: Default,
   Dark, and watchOS. Watch icons are circular, so check that nothing is clipped. The
   icon fill should be `#000000` (use the same fill for Default and Dark).
3. Export a 128 × 128 px PNG to `pages/static/FieldGlance.png`, and commit it together
   with the `.icon`.

## Versioning and releases

Field Glance uses the [CalVer scheme](https://calver.org/) with the format
`YYYY.M[.MICRO]`, where `YYYY` is the full year, `M` is the short month (1, 2, ..., 11,
12), and `MICRO` is an optional third number covering multiple releases within a single
month. The year and month are determined from the current UTC date of the build. The
first release of a month has no `MICRO` component; later ones add `.1`, `.2`, etc. In
addition, each archive created in Xcode gets a build number. The build number starts at
1 and increases sequentially with each archive, independent of the version number. Git
**tags** are created for each archive, in the format `vYYYY.M[.MICRO]+n`, where `n` is
the build number. GitHub **releases** are created for the subset of tags which are
published on the App Store.

### Release checklist

1. **Set the version and build number.** In the project's Build Settings (shared by all
   three targets), set `MARKETING_VERSION` (the CalVer version string) from today's UTC
   date, adding or incrementing `MICRO` if this month already has a release. Increment
   `CURRENT_PROJECT_VERSION` (the build number).
2. **Retake the screenshots.** In Device Hub, run the app on an iPhone 16 and an Apple
   Watch Series 11 (46mm), and take screenshots of the iPhone screen and both watch
   pages. Save them over the files in [`screenshots/`](screenshots/), keeping the same
   names.
3. **Update the website screenshots.** Regenerate the framed images, then preview the
   site to check them (see the [**Website**](#website) section).
4. **Commit and push** the version change and screenshots to `main`. This also deploys
   the updated website.
5. **Archive and upload.** In Xcode, choose **Product > Archive**, then upload the
   archive to App Store Connect from the Organizer.
6. **Tag the archived commit** with a short annotation, and push the tag:
   ```sh
   git tag -a vYYYY.M[.MICRO]+n -m 'YYYY.M[.MICRO] (n) — <short message here>'
   git push --tags
   ```
7. **Prepare the version in App Store Connect.** Create the new version, replace the
   iPhone and Apple Watch screenshots with the raw (unframed) files from `screenshots/`,
   write the "What's New" text, select the uploaded build, and submit it for review.
8. **Create a GitHub release** from the tag once the version is live on the App Store,
   following the formatting of previous releases.

## Notes

Declination is computed with the
[World Magnetic Model 2025](https://www.ncei.noaa.gov/products/world-magnetic-model)
(WMM2025), which is valid through 2029. The app shows a warning when the model is out of
date.

> 🤖 Built using Claude and Kiro, with a human in the loop.
