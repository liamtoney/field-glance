# Field Glance app icon

## Files

- `icon/field-glance.svg` is the master artwork, with every layer, and no background.
  Edit it in VectorCraft, Illustrator, Inkscape, or a text editor.
- `FieldGlance/FieldGlance.icon` is the Icon Composer file that Xcode builds. It
  contains imported copies of the layer SVGs, and it is the source of truth for how they
  are composed (grouping, background fill, effects, per-platform tweaks).

Commit both. The `icon/` folder sits outside the Xcode synchronized folders on purpose,
so it never ends up in an app target.

## Layers (back to front)

| Layer | Content | Color |
|---|---|---|
| `01-f` | the letter F | `#0091ff` |
| `02-g` | the letter G | `#ff9230` |
| `03-arrow` | arrow leaning like a backslash | `#30d158` |

Rules for the SVG:

- 1024 × 1024 pixel canvas (`viewBox="0 0 1024 1024"`).
- One top-level group per layer, named `NN-name`, numbered back to front.
- No background, blur, shadows, or gradients. Those are applied in Icon Composer.
- Text converted to outlines.

## Updating the icon

1. Edit `icon/field-glance.svg`.
2. Export each layer as its own SVG, named after the group (`01-f.svg`, `02-g.svg`,
   `03-arrow.svg`):
   - Hide every other layer.
   - Export the whole page or artboard. **Do not export only the selected object.**
     Cropping to the object's bounds moves it, and the layers will no longer line up.
   - Keep the same 1024 × 1024 size for every layer.
   - These exports are temporary. Don't commit them.
3. Open `FieldGlance/FieldGlance.icon` in Icon Composer and replace the layers with the
   new files, keeping the order back to front.
4. Check the previews: Default, Dark, and watchOS. Watch icons are circular, so check
   that nothing is clipped.
5. Save, and commit the SVG and the `.icon` together.

## Xcode setup

- The **App Icon** field on the General tab of both the iPhone and watch targets must
  say `FieldGlance`, matching the file name without `.icon`.
- The watch target needs the file too. `FieldGlance.icon` lives in the iPhone folder, so
  give it the watch target under Target Membership.
- The old `AppIcon` asset-catalog entry is not used while a `.icon` file is present.

## Composition settings

These live only in the `.icon` file, so note them here if they change.

- **Background fill:** `#000000` (use the same fill for Default and Dark)
- **Groups:** All layers exist in a single group
- **Effects:** Layer-level effects can stay default; disable shadow and bump
  translucency to 40% on the group
