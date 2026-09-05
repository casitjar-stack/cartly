# Cartly

Cartly is a simple shopping list mobile application built with:

- Flutter — mobile application
- NestJS — backend REST API
- Cloud Firestore — database

The Flutter application communicates only with the NestJS API. It does not access Firestore directly.

## Project Structure

```text
cartly/
├── backend/
│   ├── src/
│   │   ├── firebase/
│   │   └── items/
│   ├── .env.example
│   └── package.json
│
├── mobile/
│   ├── lib/
│   │   ├── models/
│   │   ├── services/
│   │   └── main.dart
│   └── pubspec.yaml
│
├── DESIGN.md
└── README.md
```

## Features

Cartly supports:

- Viewing a user's shopping list
- Adding items with a name and quantity
- Marking items as bought or unbought
- Deleting individual items
- Clearing all bought items
- User-scoped lists using the `x-user-id` request header
- Loading, empty, error, and retry states
- Database-side sorting

Items are sorted by Firestore so that:

1. Unbought items appear before bought items
2. Newest items appear first within each group

## Prerequisites

Install the following before running the project:

- Node.js
- npm
- Flutter SDK
- Android Studio with Android SDK
- An Android emulator
- A Firebase project with Cloud Firestore enabled

## Firebase Setup

### 1. Create a Firebase project

Create a project in the Firebase Console and enable Cloud Firestore.

The application uses the default Firestore database.

### 2. Create a Firebase Admin service account key

In Firebase Console:

1. Open **Project Settings**
2. Open **Service accounts**
3. Select **Firebase Admin SDK**
4. Click **Generate new private key**

Save the downloaded JSON file as:

```text
backend/secrets/serviceAccountKey.json
```

Do not commit this file.

The `backend/secrets/` directory is excluded by `.gitignore`.

### 3. Create the Firestore composite index

The shopping list is sorted by Firestore using:

```text
bought     Ascending
createdAt  Descending
```

Create a composite index for the `items` collection with:

| Field | Order |
|---|---|
| `bought` | Ascending |
| `createdAt` | Descending |

Query scope:

```text
Collection
```

Wait until the index status becomes **Enabled**.

## Backend Setup

Open a terminal in the backend directory:

```bash
cd backend
```

Install dependencies:

```bash
npm install
```

Create the local environment file from the example:

### Windows PowerShell

```powershell
Copy-Item .env.example .env
```

The file should contain:

```env
FIREBASE_SERVICE_ACCOUNT_PATH=secrets/serviceAccountKey.json
PORT=3000
```

Make sure the Firebase service account JSON exists at:

```text
backend/secrets/serviceAccountKey.json
```

Start the NestJS development server:

```bash
npm run start:dev
```

The backend will run at:

```text
http://localhost:3000
```

## Mobile Setup

Open another terminal:

```bash
cd mobile
```

Install Flutter dependencies:

```bash
flutter pub get
```

Start an Android emulator.

Check available devices:

```bash
flutter devices
```

Run Cartly on the Android emulator:

```bash
flutter run
```

The Android emulator connects to the backend using:

```text
http://10.0.2.2:3000
```

`10.0.2.2` is the Android emulator address for the host machine's localhost.

The NestJS backend must be running while using the Flutter app.

## User ID

Authentication and sign-up are intentionally outside the scope of this exercise.

Cartly uses the request header:

```text
x-user-id
```

Example:

```text
x-user-id: user-1
```

Every item operation is scoped to the requesting user's Firestore path:

```text
users/{userId}/items/{itemId}
```

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/items` | Get the user's sorted shopping list |
| POST | `/items` | Add a shopping item |
| PATCH | `/items/:id/toggle` | Toggle bought/unbought |
| DELETE | `/items/:id` | Delete one item |
| DELETE | `/items/bought/clear` | Delete all bought items |

All endpoints require the `x-user-id` header.

### Example: Add an Item

Request:

```http
POST /items
x-user-id: user-1
Content-Type: application/json
```

Body:

```json
{
  "name": "Milk",
  "quantity": 2
}
```

A new item starts with:

```json
{
  "bought": false
}
```

## Validation

The NestJS backend validates incoming item data before writing to Firestore.

Rules include:

- Name cannot be empty
- Quantity must be a whole number
- Quantity must be at least 1
- `x-user-id` is required

Requests for items outside the requesting user's list return a not-found response rather than exposing another user's data.

## Tests

### Backend

Run:

```bash
cd backend
npm test
```

The backend tests cover important user-scoping behavior and controller operations.

### Flutter

Run:

```bash
cd mobile
flutter test
```

Static analysis:

```bash
flutter analyze
```

## User Story Status

| User Story | Status | Notes |
|---|---|---|
| US-1: See my list | Done | Loading, empty, error/retry states and database-side sorting implemented |
| US-2: Add an item | Done | Backend validation for name and quantity implemented |
| US-3: Mark bought/unbought | Done | Toggle works and list re-sorts after changes |
| US-4: Delete an item | Done | Individual delete and missing-item handling implemented |
| US-5: Clear all bought items | Done | Uses a Firestore batch commit and leaves unbought items untouched |
| US-6: Only see my own items | Done | Every endpoint requires `x-user-id` and operations are scoped by user |

## Security Notes

Real Firebase credentials are not committed to the repository.

The following are excluded from Git:

```text
backend/.env
backend/secrets/
```

Only `.env.example` is committed.

For this exercise, the `x-user-id` header is trusted as requested by the specification. A production application should use proper authentication instead.

## Design

See [DESIGN.md](DESIGN.md) for:

- Architecture and request flow
- Firestore data model
- API-to-user-story mapping
- Engineering trade-offs