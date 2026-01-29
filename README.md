# catalogue_cine

Tu es un expert Flutter senior.
Je développe une application Flutter de type catalogue social de films, séries et animés.

========================
🎯 OBJECTIF DE L’APPLICATION
========================
Créer une application mobile où un utilisateur peut :
- Ajouter des films, séries et animés à son catalogue personnel
- Classer les médias par statut : à voir / en cours / terminé
- Suivre sa progression (épisode, saison, pourcentage)
- Ajouter des dates de début et de fin
- Voir les acteurs d’un média
- Cliquer sur un acteur pour voir tous les films/séries dans lesquels il a joué
- Ajouter des amis
- Voir un fil d’actualité (recommandations, contenus terminés)
- Discuter avec ses amis via un chat
- Partager et recommander des contenus

========================
🏗️ ARCHITECTURE À UTILISER
========================
Utiliser CLEAN ARCHITECTURE avec un découpage FEATURE-FIRST.

Chaque feature contient :
- data/
- domain/
- presentation/

Respecter la séparation stricte des responsabilités.

========================
📁 STRUCTURE DES DOSSIERS
========================
lib/
 ├─ core/
 │   ├─ error/
 │   ├─ network/
 │   ├─ utils/
 │   └─ constants/
 │
 ├─ features/
 │   ├─ auth/
 │   ├─ catalog/
 │   ├─ progress/
 │   ├─ actors/
 │   ├─ friends/
 │   ├─ feed/
 │   ├─ chat/
 │   └─ profile/
 │
 └─ main.dart

========================
📦 STACK TECHNIQUE
========================
- Flutter
- Dart
- flutter_bloc (BLoC & Cubit)
- Freezed + JsonSerializable
- Dio (HTTP)
- GetIt (Dependency Injection)
- GoRouter (Navigation)
- Firebase ou Supabase (auth, base de données, temps réel)
- TMDb API pour les données films/séries/acteurs

========================
🎭 DONNÉES EXTERNES (TMDb)
========================
Utiliser l’API TMDb pour :
- Recherche de films / séries / animés
- Détails d’un média (titre, synopsis, genres, images)
- Récupération du cast (acteurs)
- Détails d’un acteur (bio, photo)
- Filmographie d’un acteur

Créer un service dédié : TmdbApiService
Les appels doivent être encapsulés dans des repositories.

========================
📐 CLEAN ARCHITECTURE – DÉTAIL
========================

DOMAIN
- Entities (Media, Actor, User, Progress, Activity, Message)
- UseCases (AddToCatalog, UpdateProgress, GetActorCredits, etc.)
- Repository abstraits (interfaces)

DATA
- Models (Freezed)
- DataSources (Remote / Local)
- Implémentation des repositories

PRESENTATION
- Blocs / Cubits
- States immutables
- UI Widgets uniquement (aucune logique métier)

========================
🧠 GESTION D’ÉTAT
========================
- Utiliser Cubit pour les features simples
- Utiliser Bloc pour les features complexes (feed, chat, social)
- Chaque écran a son propre bloc
- Aucun appel réseau direct dans les widgets

========================
🗂️ MODÈLES PRINCIPAUX
========================
Media :
- id
- title
- type (movie, tv, anime)
- genres
- poster
- releaseDate

Actor :
- id
- name
- profileImage
- biography
- credits (list de Media)

UserMediaStatus :
- planned
- watching
- completed

Progress :
- currentSeason
- currentEpisode
- percentage

Activity (Feed) :
- userId
- actionType (completed, recommendation)
- mediaId
- timestamp

========================
🔄 FLUX EXEMPLE (ACTEUR)
========================
UI -> ActorBloc
-> GetActorDetailsUseCase
-> ActorRepository
-> TMDbApiService
-> Retour données
-> Mise à jour UI

========================
🧪 TESTS
========================
- Tests unitaires sur les use cases
- Tests de blocs
- Pas de logique testée dans l’UI

========================
📜 RÈGLES DE CODE
========================
- Code lisible et commenté
- Aucune logique métier dans les widgets
- Classes courtes et responsables d’une seule chose
- Toujours utiliser des modèles immutables
- Gérer les erreurs réseau proprement

========================
🚀 OBJECTIF FINAL
========================
Une application scalable, maintenable, testable, prête pour la production,
avec une architecture professionnelle Flutter.
