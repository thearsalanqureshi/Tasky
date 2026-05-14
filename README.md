# Tasky - Neo-Brutalism Offline Task Manager

## Project Overview

**Tasky** is a completely offline Flutter task management application with a striking Neo-Brutalism design language. Built for students, daily planners, and productivity enthusiasts who want a fun yet practical tool without the complexity of cloud sync, accounts, or internet requirements.

### Core Promise
-  **No Login Required**
-  **100% Offline** - No internet needed after installation
-  **Local Storage Only** - Your tasks stay on your device
-  **Bold Neo-Brutalism UI** - Playful, high-contrast design that stands out
-  **Lightweight & Fast** - No backend, no API calls, instant loading

---

##  Features

### Task Management
- **Full CRUD Operations** - Create, Read, Update, Delete tasks
- **Categories** - Organize tasks with customizable categories
- **Priority Levels** - High, Medium, Low priority indicators
- **Due Dates** - Schedule tasks with date picker
- **Subtasks** - Break down tasks into manageable steps
- **Search & Filter** - Find tasks by name, status, or date

### Planning & Productivity
- **Daily Planner** - Plan your day with top 3 priority tasks
- **Task Energy Labels** - Low, Medium, High energy requirements
- **Estimated Time** - Track time estimates for better planning
- **Study/Work Blocks** - Time block organization

### Motivation & Insights
- **Productivity Stats** - Completed tasks, weekly progress
- **Current Streaks** - Track your consistency
- **Best Category** - See where you excel
- **Productivity Messages** - Encouraging feedback on your progress
- **Recent Wins** - Celebrate your accomplishments

### Customization
- **Light/Dark/System Theme** - Choose your visual preference
- **Profile Customization** - Username and optional avatar
- **Reminder Notifications** - Local scheduled notifications
- **Daily Goals** - Set and track daily objectives

---

##  Neo-Brutalism Design

Tasky embraces the bold, playful aesthetic of Neo-Brutalism:

- **Thick Black Borders** - 2-3px solid outlines on all cards
- **Offset Shadows** - Black shadows with no blur (Offset: 4px, 5px)
- **Vibrant Accents** - Yellow (#FFD84D), Pink (#F47BD5), Mint (#8CF28A)
- **Rounded Containers** - Generous border radius with raw edges
- **Bold Typography** - Space Grotesk font family, heavy weights
- **Strong Contrast** - Cream backgrounds with pure black strokes


### Screen Overview

| Screen | Purpose | Key Features |
|--------|---------|--------------|
| **Splash** | App startup | Load settings, check onboarding, route to main |
| **Onboarding** | First-time setup | 3 pages, collect username, set daily goal |
| **Home** | Daily dashboard | Greeting, progress card, quick add, focus tasks |
| **Tasks** | Task management | Search, filter, CRUD, priority/category badges |
| **Planner** | Daily planning | Top 3 tasks, time blocks, energy labels |
| **Insights** | Stats & motivation | Streaks, weekly progress, productivity messages |
| **Settings** | App configuration | Theme, profile, notifications, data management |

### Bottom Navigation
-  **Home** - Dashboard & daily overview
-  **Tasks** - Complete task management
-  **Planner** - Daily planning & scheduling
-  **Insights** - Productivity analytics

---

## Project Architecture

Tasky follows a **Clean MVC** architecture with **feature-first modules**:

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/         # App colors, strings, sizes, storage keys
│   ├── theme/            # Light/dark theme definitions
│   ├── routes/           # GetX route configuration
│   ├── widgets/          # Reusable Neo-Brutalism components
│   └── utils/            # Helper functions, validators
├── data/
│   ├── models/           # Task, Category, Subtask, UserProfile, Settings
│   ├── services/         # Local storage, notifications, avatar handling
│   └── repositories/     # Data access layer
└── modules/
    ├── splash/           # Startup logic
    ├── onboarding/       # First-time user flow
    ├── main_nav/         # Bottom navigation controller
    ├── home/             # Dashboard
    ├── tasks/            # Task CRUD
    ├── planner/          # Daily planning
    ├── insights/         # Statistics & streaks
    └── settings/         # App configuration
```

### Layer Responsibilities

| Layer | Role |
|-------|------|
| **Model** | Data structures (TaskModel, CategoryModel, etc.) |
| **View** | UI screens and widgets |
| **Controller** | GetX controllers for state management & business logic |
| **Repository** | Clean interface between controllers and storage |
| **Service** | SharedPreferences, notifications, file handling |

### State Management Flow
```
View (UI) → Controller (GetX) → Repository → Service → SharedPreferences/Local File
```

---

##  Tech Stack

| Technology | Purpose | Version |
|------------|---------|---------|
| **GetX** | State management, routing, DI | ^4.6.6 |
| **SharedPreferences** | Local key-value storage | ^2.2.2 |
| **flutter_local_notifications** | Offline reminders | ^16.3.2 |
| **image_picker** | Avatar image selection | ^1.0.7 |
| **path_provider** | Local file paths | ^2.1.1 |
| **uuid** | Unique task IDs | ^4.2.1 |
| **intl** | Date formatting | ^0.18.1 |
| **lottie** | Onboarding animations | ^2.7.0 |
| **flutter_svg** | SVG icon support | ^2.0.9 |

### Key Package Usage
- **get** - Screen navigation, state management, dependency injection without BuildContext
- **shared_preferences** - Wraps NSUserDefaults (iOS) and SharedPreferences (Android) for local persistence
- **flutter_local_notifications** - Schedule and display notifications completely offline
- **lottie** - Smooth loading animations from local assets
- **image_picker** - Gallery/camera image selection for profile avatar
- **path_provider** - App data directory access for avatar storage

---

##  Key Design Decisions

### Why No Backend?
Tasky is built for simplicity and privacy. No accounts, no cloud sync, no data collection. Everything stays on the device. This eliminates:
- Authentication complexity
- Server costs
- Internet dependency
- Privacy concerns
- Latency issues

### Why GetX?
GetX provides comprehensive state management, routing, and dependency injection in a single lightweight package. It offers:
- Reactive state without StreamControllers
- Route management without context
- Built-in dependency injection
- Minimal boilerplate

### Why SharedPreferences?
For MVP simplicity, SharedPreferences handles key-value storage efficiently. Task data is serialized to JSON and stored locally. This approach:
- Requires no database setup
- Works offline by default
- Handles simple data structures well
- Provides instant read/write access

---

##  Responsive Design

Tasky adapts to different screen sizes:

| Device | Width | Layout |
|--------|-------|--------|
| Small Phones | < 360px | Compact single column, 16px padding |
| Medium Phones | 360-430px | Main target layout, 20-24px padding |
| Large Phones | 431-600px | Centered wider cards, max 430-480px content width |
| Foldables | 600-840px | Two-column layout where useful |
| Tablets | > 840px | NavigationRail + dashboard grid |

---

##  App Routes

| Route | Screen | Parameters |
|-------|--------|------------|
| `/` | Splash | - |
| `/onboarding` | Onboarding | - |
| `/main` | Main Navigation (Bottom Nav) | - |
| `/home` | Home Dashboard | - |
| `/tasks` | Tasks List | filter, search |
| `/task/add` | Add Task | - |
| `/task/:id` | Task Detail | taskId |
| `/task/:id/edit` | Edit Task | taskId |
| `/planner` | Daily Planner | - |
| `/insights` | Insights & Stats | - |
| `/settings` | Settings | from ellipsis menu |

---

##  Local Notifications

Tasky uses `flutter_local_notifications` for completely offline reminders:

- Schedule reminders when creating/editing tasks
- Notifications fire without internet connection
- Customizable default reminder time in settings
- Enable/disable notifications globally
- Respects device Do Not Disturb settings

---

##  Data Persistence

### Storage Keys
| Key | Type | Description |
|-----|------|-------------|
| `tasks_list` | JSON String | All task data |
| `categories_list` | JSON String | Category definitions |
| `username` | String | User's display name |
| `avatar_path` | String | Local path to avatar image |
| `theme_mode` | String | 'light', 'dark', or 'system' |
| `onboarding_completed` | Bool | First-time setup flag |
| `daily_goal` | Int | User's daily task goal |
| `notifications_enabled` | Bool | Global notification toggle |
| `default_reminder_time` | String | Default reminder schedule |

---

**Made with ❤️ for productivity enthusiasts**

*No accounts. No cloud. No complexity. Just tasks.*

