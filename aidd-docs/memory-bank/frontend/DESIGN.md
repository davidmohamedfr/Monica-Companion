# DESIGN.md

## Design Implementation

- **Design System Approach**: Material Design 3 (Material You) implementation via Flutter's built-in theming
- **Styling Method**: Theme-based styling using ColorScheme.fromSeed with deep purple seed color

## Design System Files

- **Theme Config**: lib/main.dart - Material 3 theme with ColorScheme.fromSeed
- **Design Components**: lib/features/shared/widgets/ - Reusable state widgets
- **Style Guidelines**: Following Material Design 3 specifications

## Design System

- **Spacing Scale**: Standard Flutter spacing - 8px base unit (SizedBox(height: 8/16/24))
- **Border Radius**: Material 3 default rounded corners
- **Shadows**: Material 3 elevation system
- **Breakpoints**: Flutter responsive defaults

- **Color Palette**: Material 3 dynamic color system

  - Primary: Deep Purple (seed) - App branding, primary actions
  - Secondary: Generated from seed - Secondary actions, accents
  - Accent: Inverse Primary - App bars, highlighted elements
  - Gray: Outline/OnSurfaceVariant - Subdued text, borders, icons

- **Typography**: Material 3 typography scale
  - Primary Font: System default (Roboto on Android, SF Pro on iOS)
  - Secondary Font: None specified
  - Fallback: Platform defaults

## Component Standards and Variantes

- **Button Variants**: FilledButton.icon - Primary actions with icons
- **Input States**: Standard Material states - Focus/Error handled by theme
- **Card Patterns**: Center-aligned content with 24px padding

## Layout System

- **Grid System**: Column/Row flexbox layout - Responsive Flutter widgets
- **Container Widths**: Full width with EdgeInsets.all(16/24) - Content padding
- **Spacing Rules**: Consistent 8/16/24px spacing - SizedBox for vertical spacing

## Accessibility

- **Color Contrast**: Material 3 contrast - Built-in WCAG compliance
- **Focus Management**: Flutter semantics - Automatic keyboard navigation
- **Screen Reader**: Material widgets - Built-in ARIA equivalent support