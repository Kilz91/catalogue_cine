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

      // ===== PROGRESS SUBCOLLECTION =====
      // Collection: users/{userId}/progress/{progressId}
      match /progress/{progressId} {
        allow read, write: if isOwner(userId);
      }
    }

    // ===== FRIEND REQUESTS COLLECTION =====
    match /friend_requests/{requestId} {
      // Lecture: seulement si on est l'expéditeur ou le destinataire
      allow read: if isAuthenticated() && 
        (resource.data.senderId == request.auth.uid || 
         resource.data.receiverId == request.auth.uid);
      
      // Création: seulement si on est l'expéditeur
      allow create: if isAuthenticated() && 
        request.resource.data.senderId == request.auth.uid;
      
      // Suppression: si on est l'expéditeur (annuler) ou le destinataire (refuser/accepter)
      allow delete: if isAuthenticated() && 
        (resource.data.senderId == request.auth.uid || 
         resource.data.receiverId == request.auth.uid);
    }

    // ===== FRIENDSHIPS COLLECTION =====
    match /friendships/{friendshipId} {
      // Lecture: seulement si on est l'un des deux amis
      allow read: if isAuthenticated() && 
        (resource.data.userId == request.auth.uid || 
         resource.data.friendId == request.auth.uid);
      
      // Création: lors de l'acceptation d'une demande
      allow create: if isAuthenticated();
      
      // Suppression: si on est l'un des deux amis
      allow delete: if isAuthenticated() && 
        (resource.data.userId == request.auth.uid || 
         resource.data.friendId == request.auth.uid);
    }

    // ===== ACTIVITIES COLLECTION (FEED) =====
    match /activities/{activityId} {
      // Lecture : tous les utilisateurs authentifiés
      allow read: if isAuthenticated();

      // Création : uniquement l'auteur de l'activité
      allow create: if isAuthenticated() && 
        request.resource.data.userId == request.auth.uid;
      
      // Suppression : uniquement l'auteur
      allow delete: if isAuthenticated() && 
        resource.data.userId == request.auth.uid;
    }

    // ===== RECOMMENDATIONS COLLECTION =====
    match /recommendations/{recommendationId} {
      // Lecture : tous les utilisateurs authentifiés
      allow read: if isAuthenticated();

      // Écriture : admin seulement (géré via Firestore Admin SDK ou Cloud Functions)
      allow write: if false;
    }

    // ===== CONVERSATIONS COLLECTION =====
    match /conversations/{conversationId} {
      // Lecture : seulement si on est participant
      allow read: if isAuthenticated() && 
        request.auth.uid in resource.data.participantIds;
      
      // Création : seulement si on est dans les participants
      allow create: if isAuthenticated() && 
        request.auth.uid in request.resource.data.participantIds;
      
      // Mise à jour/Suppression : seulement si on est participant
      allow update, delete: if isAuthenticated() && 
        request.auth.uid in resource.data.participantIds;
    }

    // ===== MESSAGES COLLECTION =====
    match /messages/{messageId} {
      // Lecture : seulement si on est dans la conversation
      allow read: if isAuthenticated() && 
        request.auth.uid in get(/databases/$(database)/documents/conversations/$(resource.data.conversationId)).data.participantIds;
      
      // Création : seulement si on est l'expéditeur et dans la conversation
      allow create: if isAuthenticated() && 
        request.resource.data.senderId == request.auth.uid &&
        request.auth.uid in get(/databases/$(database)/documents/conversations/$(request.resource.data.conversationId)).data.participantIds;
      
      // Mise à jour : seulement pour marquer comme lu
      allow update: if isAuthenticated() && 
        request.auth.uid in get(/databases/$(database)/documents/conversations/$(resource.data.conversationId)).data.participantIds;
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

### Subcollection `users/{userId}/progress/{progressId}`

```json
{
  "mediaId": 12345,
  "currentSeason": 2,
  "currentEpisode": 5,
  "percentage": 45,
  "dateStarted": "2026-01-29T10:00:00.000Z",
  "dateCompleted": null,
  "updatedAt": "2026-02-04T15:30:00.000Z"
}
```

### Collection `friend_requests/{requestId}`

```json
{
  "senderId": "userId1",
  "senderName": "Alice",
  "senderEmail": "alice@example.com",
  "receiverId": "userId2",
  "receiverName": "Bob",
  "receiverEmail": "bob@example.com",
  "status": "pending",
  "createdAt": "2026-02-04T10:00:00.000Z"
}
```

### Collection `friendships/{friendshipId}`

```json
{
  "userId": "userId1",
  "friendId": "userId2",
  "createdAt": "2026-02-04T10:00:00.000Z"
}
```

### Collection `activities/{activityId}` (Feed)

```json
{
  "userId": "abc123",
  "userName": "John Doe",
  "userImage": "https://...",
  "actionType": "completed",
  "mediaId": 12345,
  "mediaTitle": "Inception",
  "mediaPoster": "/path.jpg",
  "timestamp": "2026-02-04T15:30:00.000Z"
}
```

**actionType values** : `completed`, `started`, `recommended`

### Collection `recommendations/{recommendationId}`

```json
{
  "mediaId": 12345,
  "mediaTitle": "Inception",
  "mediaPoster": "/path.jpg",
  "mediaType": "movie",
  "description": "Un chef-d'œuvre de science-fiction...",
  "genres": ["Action", "Sci-Fi", "Thriller"],
  "rating": 8.8,
  "reason": "Très bien noté par les utilisateurs"
}
```

### Collection `conversations/{conversationId}` (Chat)

```json
{
  "participantIds": ["userId1", "userId2"],
  "participantNames": {
    "userId1": "Alice",
    "userId2": "Bob"
  },
  "participantImages": {
    "userId1": "https://...",
    "userId2": "https://..."
  },
  "lastMessage": "Salut, ça va ?",
  "lastMessageTime": "2026-02-04T15:30:00.000Z",
  "lastMessageSenderId": "userId1",
  "unreadCount": {
    "userId1": 0,
    "userId2": 3
  }
}
```

### Collection `messages/{messageId}` (Chat)

```json
{
  "conversationId": "convId",
  "senderId": "userId1",
  "senderName": "Alice",
  "senderImage": "https://...",
  "content": "Salut, ça va ?",
  "timestamp": "2026-02-04T15:30:00.000Z",
  "isRead": false
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
