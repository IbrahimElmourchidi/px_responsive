# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.3] - 2025-01-15
- updated the documentation

## [0.0.2] - 2025-01-15

### Added

- `maxWidth` parameter in `PxResponsiveConfig` to constrain maximum screen width
- Maximum width limiting to prevent UI elements from becoming too large on ultra-wide displays
- Automatic width capping when screen exceeds `maxWidth` threshold
- Documentation for `maxWidth` usage and best practices

### Changed

- Scale factor calculations now respect `maxWidth` constraint when specified
- Improved handling of ultra-wide screen scenarios (4K, ultrawide monitors)

## [0.0.1] - 2025-01-10

### Added

- Initial release of px_responsive
- `PxResponsiveConfig` - Configuration class for design baselines and breakpoints
- `PxResponsive` - Singleton core for calculating scale factors
- `PxResponsiveWrapper` - Widget wrapper for initializing the responsive system
- `PxResponsiveMediaQueryWrapper` - Alternative wrapper using MediaQuery
- Numeric extensions (`.w`, `.h`, `.sp`, `.r`, `.wf`, `.hf`)
- Parent-relative extensions (`.wr()`, `.hr()`)
- Clamping methods (`.wMin()`, `.wMax()`, `.wClamp()`, etc.)
- `EdgeInsets` extensions (`.w`, `.scaled`, `.r`)
- `Size` extensions (`.scaled`, `.w`, `.r`)
- `BorderRadius` extensions (`.r`)
- `PxResponsiveBuilder` - Widget for device-specific layouts
- `PxResponsiveValue` - Widget for device-specific values
- `PxResponsiveVisibility` - Widget for conditional visibility
- `BuildContext` extensions for convenient access
- Scale factor clamping to prevent extreme UI scaling
- Separate text scale factor limit (`maxTextScaleFactor`)
- Full documentation for all public APIs