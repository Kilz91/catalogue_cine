# 🎬 Feature Feed - Architecture et Structure

## 📋 Vue d'ensemble

La feature **Feed** affiche:
- **Onglet Amis**: Les activités récentes de tes amis
- **Onglet Recommandations**: Des recommandations de films/séries populaires

## 📊 Architecture et Structure Firestore

### Collections Firestore

#### 1. **Collection `activities`** (Fil d'actualité)

Stocke toutes les activités des utilisateurs (ce qu'ils regardent, terminent, etc).

```
activities/
├── {activityId1}
├── {activityId2}
└── {activityId3}
```

**Document structure:**
```json
{
  "userId": "abc123",
  "userName": "John Doe",
  "userImage": "https://...",
  "actionType": "completed",        // 'completed', 'started', 'recommended'
  "mediaId": 12345,
  "mediaTitle": "Inception",
  "mediaPoster": "/path.jpg",
  "timestamp": Timestamp
}
```

#### 2. **Collection `recommendations`** (Recommandations)

Stocke les recommandations de films/séries populaires.

```
recommendations/
├── {recId1}
├── {recId2}
└── {recId3}
```

**Document structure:**
```json
{
  "mediaId": 12345,
  "mediaTitle": "Inception",
  "mediaPoster": "/path.jpg",
  "mediaType": "movie",             // 'movie', 'tv', 'anime'
  "description": "Un chef-d'œuvre...",
  "genres": ["Action", "Sci-Fi"],
  "rating": 8.8,
  "reason": "Très bien noté"
}
```

## 🔄 Flux de Données

### Affichage du Feed

```
FeedScreen
  ↓
FeedBloc (LoadFeedEvent)
  ↓
FeedRepository.getFeedActivities()
  ↓
FeedRemoteDataSource.getFeedActivities()
  ↓
1. Récupérer amis: friendships.where(userId == currentUser)
2. Récupérer activités: activities.where(userId in friendIds).orderBy(timestamp)
  ↓
ActivityEntity[] → ActivityCard (UI)
```

### Affichage des Recommandations

```
FeedScreen
  ↓
FeedBloc (LoadRecommendationsEvent)
  ↓
FeedRepository.getRecommendations()
  ↓
FeedRemoteDataSource.getRecommendations()
  ↓
recommendations.orderBy(rating).limit(20)
  ↓
RecommendationEntity[] → RecommendationCard (UI)
```

### Enregistrement d'une Activité

Quand un utilisateur **termine** un média dans le Progress screen:

```
ProgressCard (Update)
  ↓
ProgressBloc (UpdateProgressEvent)
  ↓
LogActivityUseCase (actionType: 'completed')
  ↓
FeedRepository.logActivity()
  ↓
activities.add({
  userId, userName, userImage,
  actionType, mediaId, mediaTitle, mediaPoster,
  timestamp
})
```

## 🛠️ Implémentation

### 1. Créer les Collections dans Firestore

Firebase Console → Firestore Database → Créer les collections:
- `activities`
- `recommendations`

### 2. Injecter LogActivityUseCase dans Progress

Le progress screen doit loguer l'activité après avoir mis à jour la progression.

### 3. Ajouter des Recommandations

Dois être alimenté soit par:
- Firestore Console (manuel)
- Cloud Function (automatique basé sur ratings TMDb)
- Admin Panel (futur)

Pour l'instant, tu peux les ajouter manuellement via Firestore Console.

## 📝 Firestore Rules

Voir [FIRESTORE_RULES.md](FIRESTORE_RULES.md) pour:
- Règles de lecture/écriture pour `activities`
- Règles de lecture pour `recommendations`

## 🚀 Prochaines Étapes

1. ✅ Feature Feed créée
2. 📌 Publier les Firestore Rules
3. 🔗 Intégrer LogActivityUseCase dans Progress
4. 📊 Créer quelques recommandations de test
5. 🧪 Tester le feed complètement

## 📱 UI Components

### ActivityCard
- Avatar utilisateur
- Nom + action (a terminé / a commencé / recommande)
- Titre du média
- Poster du média
- Cliquable pour naviguer vers le détail

### RecommendationCard
- Image de fond (media poster)
- Gradient overlay noir
- Titre du média
- Rating étoiles
- Raison de la recommandation
- Cliquable pour naviguer vers le détail

## 🔐 Sécurité

- ✅ Authentification requise pour lire le feed
- ✅ Seul l'auteur peut supprimer son activité
- ✅ Les recommandations sont en lecture seule (écriture admin seulement)
- ✅ Les activités des amis uniquement (via friendships)
