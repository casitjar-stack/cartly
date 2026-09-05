# Cartly Design Notes

## Architecture

Cartly uses a simple three-layer architecture:

```text
Flutter Mobile App
        |
        | HTTP + x-user-id header
        v
NestJS Backend API
        |
        | Firebase Admin SDK
        v
Cloud Firestore
```

### Request Flow

1. The user performs an action in the Flutter app.
2. Flutter calls the NestJS API through the API service layer.
3. The request includes the user's ID in the `x-user-id` header.
4. NestJS validates the request and scopes all database operations to that user.
5. The backend reads from or writes to Cloud Firestore.
6. The API returns JSON to Flutter.
7. Flutter updates the screen based on the response.

Flutter never accesses Firestore directly.

---

## Firestore Data Model

```text
users/{userId}/items/{itemId}
```

Each item document contains:

| Field | Type | Purpose |
|---|---|---|
| `name` | string | Shopping item name |
| `quantity` | number | Quantity to buy |
| `bought` | boolean | Whether the item has been bought |
| `createdAt` | timestamp | Used for database-side sorting |

Items are stored under each user's document so that all reads and mutations are naturally scoped to that user's list.

The list query is sorted by:

1. `bought` ascending — unbought items first
2. `createdAt` descending — newest items first within each group

A Firestore composite index is used for this query.

---

## API Endpoints

All endpoints require the `x-user-id` request header.

| Method | Endpoint | Purpose | User Story |
|---|---|---|---|
| GET | `/items` | Get the user's sorted shopping list | US-1, US-6 |
| POST | `/items` | Add an item | US-2, US-6 |
| PATCH | `/items/:id/toggle` | Toggle bought/unbought | US-3, US-6 |
| DELETE | `/items/:id` | Delete one item | US-4, US-6 |
| DELETE | `/items/bought/clear` | Clear all bought items | US-5, US-6 |

Invalid input is rejected by the NestJS validation layer before a Firestore write is performed.

Requests without `x-user-id` are rejected. Item lookups are performed inside the requesting user's Firestore path, so another user's item is not returned.

---

## Trade-offs

### 1. User ID header instead of authentication

The exercise explicitly excludes login and sign-up, so Cartly trusts the `x-user-id` header instead of implementing Firebase Authentication.

This keeps the solution focused on request scoping and backend authorization behavior, but it would not be sufficient authentication for a production application.

### 2. Firestore subcollections per user

Items are stored at:

```text
users/{userId}/items/{itemId}
```

instead of using one global items collection.

This makes user isolation simple and reduces the chance of accidentally querying another user's data. The trade-off is that cross-user administrative queries would be less direct.

### 3. Batched clear operation

Clear Bought first queries the user's bought items and then deletes them through a Firestore batch commit.

This avoids sending one separate database delete request for every item and keeps the operation as one backend action.