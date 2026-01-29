# 🔐 Configuration Firestore - Règles de Sécurité

## Instructions

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet **catalogue-cine**
3. Menu latéral : **Firestore Database** → **Règles**
4. Remplacez le contenu par les règles ci-dessous
5. Cliquez sur **Publier**

## Règles de Sécurité Firestore

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Fonction helper pour vérifier l'authentification
    function isAuthenticated() {
      return request.auth != null;
    }

    // Fonction helper pour vérifier la propriété
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // ===== USERS COLLECTION =====
    match /users/{userId} {
      // Lecture : tous les utilisateurs authentifiés (pour voir les profils publics)
      allow read: if isAuthenticated();

      // Écriture : uniquement le propriétaire
      allow write: if isOwner(userId);

      // ===== CATALOG SUBCOLLECTION =====
      // Collection: users/{userId}/catalog/{mediaId}
      match /catalog/{mediaId} {
        // Lecture/Écriture : uniquement le propriétaire du catalogue
        allow read, write: if isOwner(userId);
      }

      // ===== FRIENDS SUBCOLLECTION (À VENIR) =====
      // Collection: users/{userId}/friends/{friendId}
      match /friends/{friendId} {
        allow read, write: if isOwner(userId);
      }

      // ===== PROGRESS SUBCOLLECTION (À VENIR) =====
      // Collection: users/{userId}/progress/{progressId}
      match /progress/{progressId} {
        allow read, write: if isOwner(userId);
      }
    }

    // ===== FEED COLLECTION (À VENIR) =====
    // Collection publique pour les activités
    match /feed/{activityId} {
      // Lecture : tous les utilisateurs authentifiés
      allow read: if isAuthenticated();

      // Écriture : uniquement l'auteur de l'activité
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      allow update, delete: if isAuthenticated() && resource.data.userId == request.auth.uid;
    }

    // ===== MESSAGES COLLECTION (À VENIR) =====
    // Collection: messages/{messageId}
    match /messages/{messageId} {
      // Lecture : participants de la conversation
      allow read: if isAuthenticated() &&
        (request.auth.uid == resource.data.senderId ||
         request.auth.uid == resource.data.receiverId);

      // Écriture : l'expéditeur
      allow create: if isAuthenticated() && request.resource.data.senderId == request.auth.uid;
      allow update, delete: if isAuthenticated() && resource.data.senderId == request.auth.uid;
    }

    // ===== DENY ALL OTHER ACCESS =====
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Structure de Données Attendue

### Collection `users/{userId}`

```json
{
  "email": "user@example.com",
  "displayName": "John Doe",
  "profileImageUrl": "https://...",
  "bio": "Je suis fan de cinéma",
  "createdAt": "2026-01-29T10:00:00.000Z",
  "isVerified": true
}
```

### Subcollection `users/{userId}/catalog/{mediaId}`

```json
{
  "userId": "abc123",
  "mediaId": 12345,
  "mediaType": "movie",
  "status": "watching",
  "media": {
    "id": 12345,
    "title": "Inception",
    "type": "movie",
    "posterPath": "/path.jpg",
    "overview": "...",
    "releaseDate": "2010-07-16",
    "genres": ["Action", "Sci-Fi"],
    "voteAverage": 8.8
  },
  "dateAdded": "2026-01-29T10:00:00.000Z",
  "dateStarted": "2026-01-29T10:00:00.000Z",
  "dateCompleted": null
}
```

## Explications

### Permissions Users

- **Read** : Tous les utilisateurs authentifiés peuvent voir les profils (nécessaire pour les fonctionnalités sociales)
- **Write** : Seul le propriétaire peut modifier son propre profil

### Permissions Catalog

- **Read/Write** : Seul le propriétaire peut voir et modifier son catalogue personnel
- Isolation totale : un utilisateur ne peut pas voir le catalogue d'un autre

### Sécurité

✅ Authentification obligatoire pour toutes les opérations  
✅ Isolation des données utilisateur  
✅ Protection contre les modifications non autorisées  
✅ Préparation pour les features futures (friends, feed, messages)

## Test des Règles

Une fois les règles publiées, testez dans la console Firebase :

1. Onglet **Règles** → **Simulateur de règles**
2. Type d'opération : `get`, `create`, `update`, `delete`
3. Chemin : `users/YOUR_USER_ID/catalog/test123`
4. Utilisateur simulé : Votre UID Firebase
5. Vérifiez que l'accès est autorisé ✅

## ⚠️ Important

- Ne jamais mettre `allow read, write: if true;` en production
- Toujours vérifier `request.auth != null`
- Toujours valider la propriété des données avec `request.auth.uid`
