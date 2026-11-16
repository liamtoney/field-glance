# Field Glance app icon

## Files

- `icon/field-glance.svg` is the master artwork, with every layer, and no background.
  Edit it in VectorCraft, Illustrator, Inkscape, or a text editor.
- `FieldGlance/FieldGlance.icon` is the Icon Composer file that Xcode builds. It
  contains an imported copy of the full SVG, and it is the source of truth for how the
  artwork is composed (background fill, effects, per-platform tweaks).

Commit both. The `icon/` folder sits outside the Xcode synchronized folders on purpose,
so it never ends up in an app target.

## Artwork

The SVG has a 1024 × 1024 pixel canvas (`viewBox="0 0 1024 1024"`), three elements:

| Element                        | Color     |
| ------------------------------ | --------- |
| the letter F                   | `#0091ff` |
| the letter G                   | `#ff9230` |
| arrow leaning like a backslash | `#30d158` |

Rules for the SVG:

- No background, blur, shadows, or gradients. Those are applied in Icon Composer.
- Text converted to outlines.

## Updating the icon

1. Edit `icon/field-glance.svg`.
2. Open `FieldGlance/FieldGlance.icon` in Icon Composer and replace the imported SVG
   with the updated file.
3. Check the previews: Default, Dark, and watchOS. Watch icons are circular, so check
   that nothing is clipped.
4. Save, and commit the SVG and the `.icon` together.

## Xcode setup

- The **App Icon** field on the General tab of both the iPhone and watch targets must
  say `FieldGlance`, matching the file name without `.icon`.
- The watch target needs the file too. `FieldGlance.icon` lives in the iPhone folder, so
  give it the watch target under Target Membership.
- The old `AppIcon` asset-catalog entry is not used while a `.icon` file is present.

## Composition settings

These live only in the `.icon` file, so note them here if they change.

- **Background fill:** `#000000` (use the same fill for Default and Dark)
- **Groups:** The full SVG is imported as a single group
- **Effects:** Disable shadow on the _group_
