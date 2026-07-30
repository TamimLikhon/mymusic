# MyMusic — Spotify-Inspired Premium UI Redesign Plan

## Goal
Transform the current neumorphic light-theme music app into a **premium dark-mode music player**
with a feel inspired by Spotify — immersive, polished, and energetic.

## Design Direction
- **True dark theme**: `#0A0A0F` background, `#1A1A2E` surface
- **Accent**: Indigo `#6C63FF` (brand continuity) + green `#1BDB7A` for playback indicators
- **Typography**: Inter font — bold headings, clean body
- **Glassmorphism**: Replace neumorphic shadows with frosted-glass surfaces
- **Navigation**: Bottom Navigation Bar (Home, Search, Tags) replacing the Drawer

## Key Components to Update

| Component | Change |
|-----------|--------|
| `app_colors.dart` | Full dark palette |
| `app_theme.dart` | True dark ThemeData |
| `app_typography.dart` | Inter font, bolder scale |
| `neumorphic.dart ? glass_card.dart` | Glassmorphism helper |
| `app.dart` | Bottom nav shell |
| `mini_player.dart` | Glassmorphism + progress line |
| `song_tile.dart` | Gradient icon, modern list style |
| `full_player_page.dart` | Ambient gradient, square art card, Spotify controls |
| `vibe_page.dart` | SliverAppBar, larger 'Recently Played' cards |
| `retro_seek_bar.dart` | Thin track, glowing thumb |
| `sidebar.dart` | Convert to settings overflow sheet |

## Open Questions (Awaiting User Input)
1. Bottom nav vs. keep sidebar drawer?
2. Replace VinylSpinner with square art card, or keep as fallback?
3. Color palette: Deep Space (indigo), Pure Spotify (green), or Midnight Aura (purple)?
4. Completely replace retro aesthetic, or keep subtle nods?

## Status
?? Awaiting user approval on design decisions before implementation.
