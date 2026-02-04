# 👥 Friends Feature - Guide d'utilisation

## ✅ Feature complètement fonctionnelle!

La feature **Friends** est maintenant entièrement implémentée et prête à être utilisée.

---

## 🎯 Fonctionnalités disponibles

### 1. **Ajouter des amis**
- Cliquez sur le bouton **"Ajouter"** (FAB)
- Entrez l'email de la personne
- Envoyez la demande d'ami

### 2. **Gérer les demandes reçues**
- Onglet **"Reçues"** pour voir les demandes en attente
- Bouton ✓ pour **Accepter**
- Bouton ✗ pour **Refuser**

### 3. **Gérer les demandes envoyées**
- Onglet **"Envoyées"** pour voir vos demandes en attente
- Bouton **"Annuler"** pour retirer une demande

### 4. **Liste des amis**
- Onglet **"Mes amis"** pour voir tous vos amis
- Bouton 🗑️ pour **Supprimer** un ami (avec confirmation)

---

## 🚀 Comment y accéder

### Depuis l'écran d'accueil (HomeScreen)
Un bouton **"Amis"** (icône 👥) a été ajouté dans l'AppBar en haut à droite.

### Programmatiquement
```dart
context.push(AppRoutes.friends);
// ou
context.push('/friends');
```

---

## 🔄 Flux d'utilisation

### Scénario 1: Envoyer une demande
1. Utilisateur A clique sur "Ajouter un ami"
2. Entre l'email d'Utilisateur B
3. La demande apparaît dans l'onglet "Envoyées" de A
4. La demande apparaît dans l'onglet "Reçues" de B

### Scénario 2: Annuler une demande
1. Utilisateur A va dans l'onglet "Envoyées"
2. Clique sur "Annuler"
3. La demande disparaît des deux côtés

### Scénario 3: Accepter une demande
1. Utilisateur B va dans l'onglet "Reçues"
2. Clique sur ✓ (Accepter)
3. Les deux utilisateurs deviennent amis
4. Ils apparaissent dans l'onglet "Mes amis" de chacun

### Scénario 4: Refuser une demande
1. Utilisateur B va dans l'onglet "Reçues"
2. Clique sur ✗ (Refuser)
3. La demande est supprimée
4. Utilisateur A peut renvoyer une nouvelle demande

### Scénario 5: Supprimer un ami
1. N'importe quel utilisateur va dans "Mes amis"
2. Clique sur l'icône 🗑️
3. Confirme la suppression
4. L'amitié est supprimée **des deux côtés**

---

## 📊 Structure des données Firestore

### Collection `users`
Créée automatiquement lors de l'inscription.
```
users/{userId}
  - email: "user@example.com"
  - displayName: "John Doe"
  - createdAt: Timestamp
```

### Collection `friend_requests`
```
friend_requests/{requestId}
  - senderId: "uid123"
  - senderName: "John"
  - senderEmail: "john@example.com"
  - receiverId: "uid456"
  - status: "pending"
  - createdAt: Timestamp
```

### Collection `friendships`
Deux documents créés (un par utilisateur) lors de l'acceptation.
```
friendships/{friendshipId}
  - userId: "uid123"
  - friendId: "uid456"
  - friendName: "Jane"
  - friendEmail: "jane@example.com"
  - createdAt: Timestamp
```

---

## 🔐 Règles de sécurité Firestore requises

Voir le fichier `FRIENDS_FIRESTORE_CONFIG.md` pour les règles complètes.

**⚠️ Important:** N'oubliez pas de configurer les **index composites** dans Firestore:
- Console Firebase → Firestore Database → Indexes
- Créer les index mentionnés dans `FRIENDS_FIRESTORE_CONFIG.md`

---

## 🏗️ Architecture

### Clean Architecture respectée:
```
features/friends/
├── domain/          # Logique métier
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/           # Accès aux données
│   ├── models/
│   ├── datasources/
│   └── repositories/
└── presentation/   # UI
    ├── bloc/
    ├── pages/
    └── widgets/
```

### State Management
- **BLoC Pattern** pour la gestion d'état
- Events: Load, Send, Cancel, Accept, Reject, Remove
- States: isLoading, friends, receivedRequests, sentRequests, messages

---

## ✅ Tests effectués

- ✅ Compilation sans erreur
- ✅ Analyse statique validée (0 erreurs)
- ✅ Imports corrects
- ✅ Types définis
- ✅ Dépendances enregistrées (DI)
- ✅ Routes configurées
- ✅ Bouton d'accès ajouté

---

## 🎨 Améliorations futures possibles

1. **Photos de profil**: Afficher les avatars réels
2. **Recherche**: Rechercher des amis par nom
3. **Suggestions**: Recommander des amis communs
4. **Notifications**: Notifier les nouvelles demandes
5. **Statut en ligne**: Afficher qui est connecté
6. **Filtres**: Trier/filtrer la liste d'amis

---

## 🐛 Debugging

### Si une demande ne s'affiche pas:
- Vérifier les index Firestore
- Vérifier les règles de sécurité
- Vérifier que le document `users/{uid}` existe

### Si l'email n'est pas trouvé:
- Vérifier que l'utilisateur s'est bien inscrit
- Vérifier l'orthographe de l'email
- Vérifier que le document dans `users` existe

---

## 📱 Interface utilisateur

### Onglet "Mes amis"
- 📋 Liste scrollable
- 🔄 Pull-to-refresh
- 🗑️ Bouton suppression avec confirmation
- 📧 Affichage email + nom

### Onglet "Reçues"
- 👤 Avatar avec initiale
- ✓ Bouton vert accepter
- ✗ Bouton rouge refuser
- 🔄 Pull-to-refresh

### Onglet "Envoyées"
- ⏱️ Icône "en attente"
- 📅 Date d'envoi
- ❌ Bouton annuler
- 🔄 Pull-to-refresh

---

**🎉 La feature est prête à l'emploi!**
