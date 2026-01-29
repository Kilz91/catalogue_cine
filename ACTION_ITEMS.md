# 📋 ACTION ITEMS - Prochaines Tâches

## 🎯 Priorité 1: Configuration (2-3 heures)

### [ ] 1.1 Configurer Firebase

```bash
cd c:\Users\Kilian\Documents\Coding\catalogue_cine
flutterfire configure
```

- Choisir le projet Firebase (ou en créer un)
- Sélectionner les plateformes (Android, iOS, Web, etc)
- Les fichiers seront générés automatiquement

### [ ] 1.2 Mettre à jour firebase_options.dart

- Copier les clés depuis flutterfire
- Vérifier que toutes les plateformes sont configurées
- Tester que Firebase se connecte

### [ ] 1.3 Installer les dépendances

```bash
flutter pub get
```

### [ ] 1.4 Générer le code (Code generation)

```bash
flutter pub run build_runner build
```

Cela générera:

- `user_model.g.dart`
- Autres fichiers `.g.dart`

### [ ] 1.5 Vérifier la compilation

```bash
flutter analyze
```

Devrait avoir 0 erreurs

---

## 🎯 Priorité 2: Première Feature (4-6 heures)

### [ ] 2.1 Implémenter CATALOG Feature

Suivre [FEATURE_TEMPLATE.md](./FEATURE_TEMPLATE.md):

1. Créer les dossiers
2. Implémenter Domain (Repository + Use Cases)
3. Implémenter Data (Models + DataSources)
4. Implémenter Presentation (BLoC + Pages)
5. Enregistrer dans service_locator.dart
6. Ajouter les routes

### [ ] 2.2 Créer Firestore Structure

```
users/
├── {userId}/
│   ├── mediaLibrary/
│   │   ├── {userMediaId}/
│   │   │   ├── id
│   │   │   ├── mediaId
│   │   │   ├── status: "planned" | "watching" | "completed"
│   │   │   ├── dateAdded
│   │   │   ├── dateStarted
│   │   │   └── dateCompleted
```

### [ ] 2.3 Tester CATALOG

- Ajouter des médias
- Filtrer par statut
- Supprimer des médias
- Navigation vers la page

---

## 🎯 Priorité 3: Features Secondaires (8-12 heures)

### [ ] 3.1 ACTORS Feature

- Récupérer les acteurs d'un média
- Afficher la filmographie d'un acteur
- Intégrer TMDb API

### [ ] 3.2 PROGRESS Feature

- Mettre à jour la progression (épisode, saison)
- Tracker le pourcentage d'un film
- Enregistrer dans Firestore

### [ ] 3.3 FRIENDS Feature

- Ajouter/retirer des amis
- Gérer les demandes
- Afficher le profil d'un ami

---

## 🎯 Priorité 4: Features Sociales (12-16 heures)

### [ ] 4.1 FEED Feature

- Afficher le fil d'actualité
- Recommandations des amis
- Contenus terminés

### [ ] 4.2 CHAT Feature

- Envoyer/recevoir des messages
- Conversations en temps réel (Firestore listeners)
- Notifications

### [ ] 4.3 PROFILE Feature

- Voir/modifier le profil
- Avatar utilisateur
- Bio et préférences

---

## 🎯 Priorité 5: Intégrations (6-8 heures)

### [ ] 5.1 TMDb API Service

```dart
// Créer lib/core/services/tmdb_api_service.dart
- searchMovies()
- searchTV()
- getMovieDetails()
- getTVDetails()
- getMovieCredits()
- getTVCredits()
- getPersonDetails()
- getPersonCredits()
```

### [ ] 5.2 Cache Local

- Implémenter SharedPreferences pour les données
- Implémenter Hive pour les données complexes
- Synchronisation online/offline

### [ ] 5.3 Firebase Cloud Functions (optionnel)

- Recommandations automatiques
- Notifications push
- Nettoyage de données

---

## 🎯 Priorité 6: Tests & Optimisations (4-8 heures)

### [ ] 6.1 Tests Unitaires

```dart
// lib/features/[feature]/test/usecases/
- LoginUseCaseTest
- AddMediaUseCaseTest
- Etc...
```

### [ ] 6.2 Tests d'Intégration

- Test du flux complet Auth
- Test du flux complet Catalog
- Etc...

### [ ] 6.3 Performance

- Profiler avec DevTools
- Optimiser les queries Firestore
- Lazy loading des images
- Pagination des listes

---

## 📝 Checklist Détaillée par Étape

### Configuration

- [ ] Firebase project created
- [ ] `flutterfire configure` exécuté
- [ ] `firebase_options.dart` mis à jour
- [ ] `flutter pub get` fait
- [ ] `build_runner build` exécuté
- [ ] `flutter analyze` pas d'erreurs

### CATALOG Feature

- [ ] Dossiers créés
- [ ] Domain/Repository interface créé
- [ ] Use cases implémentés
- [ ] Models créés
- [ ] DataSource implémenté
- [ ] Repository impl créé
- [ ] BLoC créé
- [ ] Events/States créés
- [ ] Pages créées
- [ ] Service locator mise à jour
- [ ] Routes ajoutées
- [ ] Tests unitaires (optionnel)

### Chaque Feature Suivante

- [ ] Structure créée
- [ ] Domain implémenté
- [ ] Data implémenté
- [ ] Presentation implémentée
- [ ] Service locator mise à jour
- [ ] Routes ajoutées
- [ ] Testé manuellement

---

## 🚨 Problèmes Courants & Solutions

### "firebase_options.dart: Missing configuration"

**Solution**:

```bash
flutterfire configure
cp lib/firebase_options.dart lib/firebase_options.dart.backup
# Remplacer les clés
```

### "Code generation files not found"

**Solution**:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### "Circular dependency detected"

**Solution**: Vérifier que Domain n'importe rien de Data

### "GetIt: Service not registered"

**Solution**: Vérifier que c'est enregistré dans service_locator.dart

### "GoRouter: Route not found"

**Solution**: Vérifier que c'est ajouté dans app_router.dart

---

## 📞 Support & Questions

### Pour les patterns:

- Consulter [STRUCTURE.md](./STRUCTURE.md)

### Pour les exemples:

- Regarder [features/auth/](./lib/features/auth/)

### Pour ajouter une feature:

- Suivre [FEATURE_TEMPLATE.md](./FEATURE_TEMPLATE.md)

### Pour vérifier:

- Utiliser [VERIFICATION_GUIDE.md](./VERIFICATION_GUIDE.md)

---

## 📅 Timeline Estimée

| Phase     | Tâches                  | Durée      | Status     |
| --------- | ----------------------- | ---------- | ---------- |
| 1         | Configuration + pub get | 2-3h       | ⏳ À faire |
| 2         | CATALOG feature         | 4-6h       | ⏳ À faire |
| 3         | ACTORS + PROGRESS       | 4-8h       | ⏳ À faire |
| 4         | FRIENDS + FEED + CHAT   | 12-16h     | ⏳ À faire |
| 5         | TMDb API + Cache        | 6-8h       | ⏳ À faire |
| 6         | Tests + Optimisations   | 4-8h       | ⏳ À faire |
| **TOTAL** |                         | **32-49h** | ⏳ À faire |

---

## ✅ Définition de "Fini"

La feature est complète quand:

- [x] Code compile sans erreurs
- [x] `flutter analyze` = 0 erreurs
- [x] Domain layer n'a aucune dépendance externe
- [x] Repository interface créée
- [x] Use cases implémentés
- [x] Models créés et sérialisables
- [x] DataSources implémentés
- [x] Repository impl créé
- [x] BLoC/Cubit créé avec events/states
- [x] Pages/Widgets créés
- [x] Service locator mise à jour
- [x] Routes configurées
- [x] Feature testée manuellement
- [x] Pas de warnings
- [x] Code bien formaté
- [x] Commentaires pour logique complexe

---

## 🎊 Prêt à Commencer?

### Commande pour démarrer:

```bash
cd c:\Users\Kilian\Documents\Coding\catalogue_cine
flutterfire configure
flutter pub get
flutter pub run build_runner build
flutter analyze
```

Puis sélectionner la première tâche et commencer! 🚀

---

## 💪 Vous Avez Ceci:

✅ Architecture professionnelle
✅ Documentation complète
✅ Exemple AUTH complet
✅ Templates pour les features
✅ Dépendances configurées
✅ Service locator prêt
✅ Navigation configurée
✅ Thème global défini

**Maintenant c'est à vous de jouer!** 🎬
