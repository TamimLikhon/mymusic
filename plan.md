# Music App Implementation Plan: Playlists & History

## 1. Stream Page Updates
- **Recently Played Section**: 
  - Add a horizontally scrollable list (or grid) at the top of the stream page showing previously listened to songs.
  - Clicking a song instantly plays it and updates its position in the history to be the most recent.
- **Playlists Section**:
  - Add a section directly below "Recently Played" displaying all user-created playlists.
  - Display the playlist name and a thumbnail (derived from the first song added to it).
- **App Bar / Header**:
  - Add a "disc" icon button (e.g., `Icons.album` or similar) to the top right corner of the Stream page.
  - Clicking this icon navigates to the "Create Playlist" flow.

## 2. Playlist Creation Flow
- **Create Playlist UI**:
  - *Suggestion:* Instead of a full new page, consider using a modal bottom sheet or dialog for creating a playlist. It keeps the user in the context of their music and is a very common pattern in modern music apps.
  - The UI will consist of a simple text input field for the playlist name and a "Create" button.
  - **Thumbnail Logic**: If a playlist has no songs, it displays a default placeholder icon. Once a song is added, it automatically uses the first song's image URL as the playlist's thumbnail.

## 3. Playback & "Add to Playlist" Feature
- **Player Screen / Options Menu**:
  - While listening to a song (in the full player or mini-player options), provide an "Add to Playlist" action.
  - Clicking this action opens a bottom sheet listing all user-created playlists.
  - Tapping a playlist adds the current song to it.
  - The system will check if this is the first song in the playlist; if so, it assigns the song's thumbnail to the playlist.

## 4. Data & State Management
- **Local Storage**: 
  - Use a local database (like Hive or SQLite, depending on what you are currently using in the project) to persist data:
    - `History`: A list of recently played song objects (it's best to limit this to the 50 most recent songs to optimize storage).
    - `Playlists`: A schema holding `id`, `name`, `thumbnailUrl`, and a list of `songs`.
- **State Management**:
  - Update your Provider/state classes to manage `HistoryState` and `PlaylistState`.
  - Ensure that when a song is played or added to a playlist, the UI immediately reflects these changes (e.g., the "Recently Played" list shifts the song to the front, and the playlist thumbnail updates dynamically).

## Alternative Suggestions & Enhancements
1. **Dialog instead of a New Page**: As mentioned above, using a `showDialog` or `showModalBottomSheet` for creating a new playlist is generally faster and feels more fluid than routing to a completely new page.
2. **Duplicate Prevention**: When adding a song to a playlist, we should check if it already exists in that playlist and show a small `SnackBar` message like "Song already in playlist" to prevent duplicates.
3. **Optimistic UI Updates**: Update the UI immediately when the user clicks "Add to Playlist" while the storage operation happens in the background.
