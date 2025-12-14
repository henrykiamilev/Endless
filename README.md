# Golf Recruit App

A mobile application designed to automate and streamline the junior golf recruitment process. Built with React Native and Expo.

## Features

- **Home Dashboard**: Quick actions, plays of the week, recent sessions, and performance snapshot
- **Video Library**: Browse match videos with filtering, view stats and round history
- **Record**: Camera integration for recording golf swings and practice sessions
- **Endless AI**: AI-powered highlight reel generator and swing video management
- **Settings**: User profile, preferences, and account management

## Tech Stack

- React Native with Expo
- TypeScript
- React Navigation (Bottom Tabs)
- Expo Camera
- Expo Vector Icons

## Getting Started

### Prerequisites

- Node.js (v18 or higher)
- npm or yarn
- Expo CLI
- iOS Simulator or Android Emulator (or Expo Go app on physical device)

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd golf-recruit-app
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npx expo start
```

4. Run on your preferred platform:
- Press `i` for iOS simulator
- Press `a` for Android emulator
- Scan QR code with Expo Go app for physical device

## Project Structure

```
golf-recruit-app/
├── App.tsx                 # Main app entry point
├── src/
│   ├── components/         # Reusable UI components
│   ├── screens/            # Screen components
│   ├── navigation/         # Navigation configuration
│   ├── constants/          # Colors and theme constants
│   ├── types/              # TypeScript type definitions
│   └── assets/             # Images and static assets
├── package.json
└── tsconfig.json
```

## Screens

1. **HomeScreen** - Dashboard with quick actions, featured plays, and session history
2. **VideoLibraryScreen** - Video management with toggle between videos and stats
3. **RecordScreen** - Camera interface for recording swing videos
4. **EndlessAIScreen** - AI highlight reel generator and swing annotations
5. **SettingsScreen** - User profile and app settings

## License

MIT
