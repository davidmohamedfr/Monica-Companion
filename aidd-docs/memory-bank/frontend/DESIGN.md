# DESIGN.md

## Design Implementation

- **Design System Approach**: Material Design 3 (Material You) with Monica brand identity
- **Styling Method**: Theme-based styling using `ColorScheme.fromSeed` with Monica brand color `#6366F1`

## Design System Files

- **Theme Config**: `lib/main.dart` - Material 3 theme with Monica brand color seed
- **Design Components**: `lib/features/shared/widgets/` - Reusable UI widgets (error, loading, empty states)
- **Style Guidelines**: Material Design 3 specifications with custom Monica branding

## Design System

- **Spacing Scale**: Standardized Flutter spacing with consistent patterns
  - Base unit: 8px increments (8, 16, 24, 32, 40px)
  - Main padding: 24px for primary content areas
  - Section spacing: 40px between major sections
  - Card padding: 16-24px internal spacing

- **Border Radius**: Consistent rounded corner system
  - Small radius: 12px for info containers
  - Medium radius: 16px for description cards
  - Large radius: 20px for hero elements (logo container)

- **Shadows**: Material 3 elevation system with glassmorphism effects
  - Subtle transparency overlays (`Colors.white.withValues(alpha: 0.1)`)
  - Gradient backgrounds from primary to primaryContainer

- **Breakpoints**: Flutter responsive defaults with mobile-first approach

- **Color Palette**: Monica brand-based Material 3 dynamic colors

  - Primary: Monica Indigo `#6366F1` - Brand color, primary actions, gradient backgrounds
  - Secondary: Generated from seed - Secondary actions, accents
  - Error: Theme error color - Error states, validation messages
  - Outline: Subdued elements - Icons in empty/error states, borders
  - OnSurfaceVariant: Secondary text content
  - Surface variants: Background containers with transparency

- **Typography**: Material 3 typography scale with brand personality
  - Primary Font: System defaults (Roboto on Android, San Francisco on iOS)
  - Hierarchy: `headlineLarge` for app title, `titleMedium` for taglines, `bodyLarge` for descriptions
  - Color treatment: White text on brand backgrounds, theme colors on surfaces
  - Text effects: Semi-transparent overlays for depth (`alpha: 0.6-0.9`)

## Component Standards and Variants

- **Button Variants**: Modern Material 3 button system
  - Primary: `FilledButton.icon` with icons for main actions
  - Retry actions: `FilledButton.icon` with refresh icon
  - Consistent icon-label pairing pattern

- **State Components**: Standardized feedback widgets
  - Loading: `CircularProgressIndicator` with optional message, configurable size
  - Error: Consistent error display with icon, message, optional retry button
  - Empty: Clean empty states with outline icons and descriptive messaging

- **Card Patterns**: Glassmorphism and container design
  - Transparent overlays with subtle background colors
  - Consistent internal padding (16-24px)
  - Rounded corners following radius system
  - Content center-alignment for visual balance

## Layout System

- **Grid System**: Flutter's flexible Column/Row system
  - Single-column mobile layouts with `SingleChildScrollView`
  - Center-aligned content with `MainAxisAlignment.center`
  - Responsive widget sizing with `MainAxisSize.min`

- **Container Widths**: Full-width responsive design
  - Edge padding: `EdgeInsets.all(24)` for main content
  - Internal spacing: 16-24px for nested containers
  - `SafeArea` integration for proper device handling

- **Spacing Rules**: Hierarchical spacing system
  - Major sections: 40px vertical spacing
  - Related elements: 16px spacing
  - Micro-spacing: 8px for tight groupings
  - Consistent `SizedBox` usage for vertical spacing

## Navigation Patterns

- **Screen Structure**: Single-screen welcome approach
  - Gradient background spanning full viewport
  - ScrollView for content overflow handling
  - Brand-focused hero section with logo and messaging

- **Visual Hierarchy**: Clear content progression
  - Logo and branding at top
  - Primary messaging in center
  - Supporting information at bottom
  - Development info clearly separated

## Animation and Transitions

- **Visual Effects**: Subtle material animations
  - Gradient transitions from primary to primaryContainer
  - Standard Material 3 button press animations
  - Smooth loading spinner rotations

- **Motion Design**: Platform-consistent animations
  - Material motion specifications
  - Flutter's built-in widget animations
  - Respectful of user accessibility preferences

## Accessibility

- **Color Contrast**: WCAG-compliant Material 3 system
  - High contrast on brand gradient backgrounds
  - Proper text color ratios maintained
  - Error states with distinct visual indicators

- **Focus Management**: Native Flutter accessibility
  - Automatic keyboard navigation support
  - Screen reader optimizations through Material widgets
  - Semantic labels for interactive elements

- **Screen Reader**: Built-in accessibility support
  - Material widgets provide semantic information
  - Text content properly structured for screen readers
  - Interactive elements clearly identified