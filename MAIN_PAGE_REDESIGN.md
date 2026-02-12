# Main Page Redesign

## Overview
The main page has been completely redesigned to match the wireframe/storyboard design with a map-centric interface.

## Key Features

### 1. **OpenStreetMap Integration** (75% of screen)
- Uses `flutter_map` package with OpenStreetMap tiles
- Interactive map showing location markers
- Centered on default location (London, UK - can be updated to user's location)
- Map takes up 3/4 of the mobile page as requested

### 2. **Bottom Navigation Bar**
- Three square navigation buttons:
  - **Left**: History (chat history)
  - **Center**: Discover (Main page - highlighted with light grey background)
  - **Right**: Profile (user profile)
- Middle button is visually highlighted when on main page
- Prominent AI icon in the center button representing LocalAI branding

### 3. **User Profile Icon** (Top Right)
- White circular button with grey person icon
- Positioned in top right corner
- Navigates to user profile when tapped
- Clean, minimal design matching the wireframe

### 4. **AI Prompt Bar**
- Located below the map and above the navigation bar
- White rounded container with search functionality
- Text input: "Where do you want to go?"
- AI sparkle icon button on the right
- Submits prompt to search for locations on the map
- Integrates with chat history feature

## Design Changes

### Color Scheme
- Changed from blue theme to white/grey minimal design
- User icon: white background with grey icon (instead of blue)
- Navigation bar: white with grey shadows
- Active states: subtle grey highlights
- Primary actions: using theme's primary color for AI icon

### Layout Structure
```
┌─────────────────────────┐
│    Map (75% height)     │
│                         │
│                         │
│                         │
│                         │
│         [User 👤]       │  ← Top right
│                         │
├─────────────────────────┤
│  [AI Search Bar]  ✨   │  ← Just above nav bar
├─────────────────────────┤
│ [Hist] [AI] [Profile]  │  ← Bottom navigation
└─────────────────────────┘
```

## Dependencies Added
- `flutter_map: ^7.0.2` - For OpenStreetMap integration
- `latlong2: ^0.9.1` - For latitude/longitude coordinates

## Files Modified
- `pubspec.yaml` - Added map dependencies
- `lib/presentation/pages/home/main_page.dart` - Complete redesign
- `lib/presentation/pages/home/main_page_old.dart` - Backup of old design

## Next Steps
1. Integrate with real user location using `geolocator` package
2. Connect AI prompt to backend search API
3. Display search results as markers on the map
4. Add location detail popup when marker is tapped
5. Implement map clustering for multiple nearby locations
6. Add map controls (zoom, re-center, etc.)

## Testing
Run the app and navigate to the main page after login to see the new design:
```bash
flutter run
```
