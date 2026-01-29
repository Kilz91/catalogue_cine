# 🎬 Configuration TMDb API - Documentation

## ✅ Configuration Effectuée

### Clé API Configurée

La clé TMDb a été ajoutée dans `lib/core/constants/api_constants.dart`

```dart
static const String tmdbApiKey = '2429a2f20c1592f674bfc8dd65baa7a3';
```

### Informations API

- **API Key (v3)** : `2429a2f20c1592f674bfc8dd65baa7a3`
- **Bearer Token (v4)** : `eyJhbGciOiJIUzI1NiJ9...` (stocké séparément si besoin)
- **Base URL** : `https://api.themoviedb.org/3`
- **Image Base URL** : `https://image.tmdb.org/t/p/w500`

## 📡 Endpoints Utilisés

### Recherche

- **Films** : `/search/movie?api_key={key}&query={query}&language=fr-FR`
- **Séries TV** : `/search/tv?api_key={key}&query={query}&language=fr-FR`
- **Animés** : Filtre sur `/search/tv` avec `genre_ids` contenant 16 (Animation)

### Détails (À VENIR)

- **Détails Film** : `/movie/{id}?api_key={key}&language=fr-FR`
- **Détails Série** : `/tv/{id}?api_key={key}&language=fr-FR`
- **Crédits Film** : `/movie/{id}/credits?api_key={key}`
- **Crédits Série** : `/tv/{id}/credits?api_key={key}`

### Acteurs (À VENIR)

- **Détails Acteur** : `/person/{id}?api_key={key}&language=fr-FR`
- **Filmographie** : `/person/{id}/combined_credits?api_key={key}`

## 🔒 Sécurité des Clés

### ⚠️ Problème Actuel

La clé API est **hardcodée** dans le code source. C'est acceptable pour le développement mais **non recommandé pour la production**.

### 🛡️ Solution Recommandée

#### Option 1 : Variables d'Environnement (Recommandé)

1. Créer un fichier `.env` (déjà ajouté au .gitignore) :

```env
TMDB_API_KEY=2429a2f20c1592f674bfc8dd65baa7a3
TMDB_ACCESS_TOKEN=eyJhbGciOiJIUzI1NiJ9...
```

2. Utiliser le package `flutter_dotenv` :

```yaml
# pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

3. Charger dans `main.dart` :

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  // ...
}
```

4. Accéder dans le code :

```dart
static String get tmdbApiKey => dotenv.env['TMDB_API_KEY'] ?? '';
```

#### Option 2 : Backend Proxy (Production)

Pour une app en production, créer un backend qui :

- Stocke la clé API côté serveur
- Expose des endpoints sécurisés (ex: `/api/search?query=...`)
- Ajoute rate limiting et caching
- Protège la clé des utilisateurs malveillants

## 📊 Limites API TMDb

### Plan Gratuit (Developer)

- ✅ **50 requêtes/seconde**
- ✅ **Pas de limite quotidienne**
- ✅ Accès à toutes les données
- ✅ Images haute résolution

### Bonnes Pratiques

1. **Caching** : Mettre en cache les résultats (local storage ou backend)
2. **Debouncing** : Attendre 300ms avant de lancer une recherche
3. **Pagination** : Charger les résultats par pages
4. **Rate Limiting** : Limiter le nombre de requêtes par utilisateur

## 🧪 Test de l'API

### Test Manuel avec cURL

```bash
curl "https://api.themoviedb.org/3/search/movie?api_key=2429a2f20c1592f674bfc8dd65baa7a3&query=inception&language=fr-FR"
```

### Test dans l'App

1. Lancer l'application
2. Aller dans "Mon Catalogue"
3. Rechercher "Inception"
4. Vérifier que les résultats s'affichent

## 📝 Exemples d'Utilisation

### Recherche de Films

```dart
final results = await searchMediaUseCase(
  query: 'Inception',
  type: 'movie',
);
```

### Recherche de Séries

```dart
final results = await searchMediaUseCase(
  query: 'Breaking Bad',
  type: 'tv',
);
```

### Recherche d'Animés

```dart
final results = await searchMediaUseCase(
  query: 'Attack on Titan',
  type: 'anime', // Filtre automatique sur genre Animation
);
```

## 🔗 Liens Utiles

- [Documentation TMDb API](https://developers.themoviedb.org/3)
- [Tableau de bord TMDb](https://www.themoviedb.org/settings/api)
- [Explorer l'API (Swagger)](https://developers.themoviedb.org/3/getting-started/introduction)
- [Liste des Genres](https://api.themoviedb.org/3/genre/movie/list?api_key=YOUR_KEY)

## ✅ Checklist Post-Configuration

- [x] Clé API ajoutée dans `api_constants.dart`
- [x] `.gitignore` mis à jour pour protéger les secrets
- [x] `.env.example` créé comme template
- [x] DataSource TMDb créé avec gestion d'erreurs
- [x] Repository implémenté
- [x] Use Cases créés
- [x] BLoC intégré
- [x] UI de recherche fonctionnelle
- [ ] Tester la recherche dans l'app
- [ ] Migrer vers variables d'environnement (optionnel)
- [ ] Ajouter caching des résultats (optionnel)
- [ ] Implémenter détails média avec crédits (prochaine étape)

## 🚀 Prochaines Étapes

1. **Tester la recherche** dans l'application
2. **Implémenter les détails média** avec cast d'acteurs
3. **Ajouter la feature Actors** (cliquer sur un acteur → voir sa filmographie)
4. **Optimiser avec caching** pour réduire les appels API
5. **Migrer vers .env** pour plus de sécurité
