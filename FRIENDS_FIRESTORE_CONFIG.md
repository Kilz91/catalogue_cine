# Configuration Firestore pour Friends Feature

## Collections Firestore nécessaires:

### 1. Collection `users`
Stocke les informations de base de chaque utilisateur pour la recherche.

**Structure:**
```
users/{userId}
  - email: string
  - displayName: string
  - displayNameLower: string  <-- IMPORTANT pour la recherche
  - createdAt: timestamp
```

**Règles de sécurité:**
```javascript
match /users/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && request.auth.uid == userId;
}
```

### 2. Collection `friend_requests`
Stocke les demandes d'amis en attente.

**Structure:**
```
friend_requests/{requestId}
  - senderId: string
  - senderName: string
  - senderEmail: string
  - receiverId: string
  - status: string ('pending', 'accepted', 'rejected')
  - createdAt: timestamp
```

**Règles de sécurité:**
```javascript
match /friend_requests/{requestId} {
  allow read: if request.auth != null && 
    (resource.data.senderId == request.auth.uid || 
     resource.data.receiverId == request.auth.uid);
  allow create: if request.auth != null && 
    request.resource.data.senderId == request.auth.uid;
  allow delete: if request.auth != null && 
    (resource.data.senderId == request.auth.uid || 
     resource.data.receiverId == request.auth.uid);
}
```

### 3. Collection `friendships`
Stocke les amitiés établies (une entrée par utilisateur).

**Structure:**
```
friendships/{friendshipId}
  - userId: string
  - friendId: string
  - friendName: string
  - friendEmail: string
  - createdAt: timestamp
```

**Règles de sécurité:**
```javascript
match /friendships/{friendshipId} {
  allow read: if request.auth != null && 
    resource.data.userId == request.auth.uid;
  allow create: if request.auth != null;
  allow delete: if request.auth != null && 
    resource.data.userId == request.auth.uid;
}
```

## Index Firestore requis:

1. **friend_requests**: 
   - receiverId (Ascending) + status (Ascending) + createdAt (Descending)
   - senderId (Ascending) + status (Ascending) + createdAt (Descending)

2. **friendships**:
   - userId (Ascending) + createdAt (Descending)

3. **users**:
   - displayNameLower (Ascending) <-- IMPORTANT pour la recherche autocomplétée

## Configuration initiale

Lors de l'inscription d'un utilisateur, il faut créer son document dans `users`:

```dart
await FirebaseFirestore.instance.collection('users').doc(userId).set({
  'email': email,
  'displayName': displayName ?? 'Utilisateur',
  'displayNameLower': (displayName ?? 'Utilisateur').toLowerCase(),
  'createdAt': FieldValue.serverTimestamp(),
});
```

Cette création est automatiquement effectuée dans `auth_remote_data_source.dart` lors du signup.

## Fonctionnement de la recherche

La recherche utilise **displayNameLower** pour permettre une recherche case-insensitive avec autocomplétion:

- L'utilisateur tape "Joh"
- Firestore cherche tous les documents où `displayNameLower` commence par "joh"
- Résultats: "John", "Johnny", "Johanna", etc.
- Maximum 10 résultats affichés

