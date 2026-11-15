# Field Glance

A minimal field tool for iPhone and Apple Watch. Three panels on a black screen:

- **Local time** — date and time in your current timezone
- **UTC** — date and time in UTC
- **Magnetic declination** — current value with a compass arrow, computed from your
  location using WMM2025

No accounts, no settings, no network requests. Location is used on-device only.

## Targets

| Target | Description |
|---|---|
| FieldGlance | iPhone app |
| FieldGlanceWatch | watchOS app |
| FieldGlanceWidget | Watch complications (UTC, declination) |

## Requirements

- Xcode 27+
- iOS 17+ / watchOS 10+

## Notes

Declination is computed using the
[World Magnetic Model 2025](https://www.ncei.noaa.gov/products/world-magnetic-model)
(WMM2025), valid through 2029. The app warns when the model is out of date.

> 🤖 Generated using Claude and Kiro with a human in the loop.
