🧭 ORDRE RECOMMANDÉ POUR GÉNÉRER LES FEATURES
🥇 1️⃣ Core / Fondations (avant TOUT)

👉 À faire une seule fois

Demande à Copilot :

Génère le core du projet :
- gestion des erreurs
- network (Dio)
- constantes
- injection de dépendances (GetIt)
- configuration Firebase
- configuration TMDb


📌 Sans ça, les features vont être bancales.

🥈 2️⃣ Auth (obligatoire)

👉 Base de tout ce qui est social

Génère la feature auth :
- Firebase Auth
- login / register
- user entity
- AuthBloc


Pourquoi maintenant ?

Toutes les autres features dépendent du userId

🥉 3️⃣ Profile (lié à auth)
Génère la feature profile :
- affichage profil
- avatar
- infos utilisateur

🏅 4️⃣ Catalog (le cœur de l’app)
Génère la feature catalog :
- ajout film/série/animé via TMDb
- liste personnelle
- statuts


👉 C’est LA feature centrale.

🧩 5️⃣ Actors
Génère la feature actors :
- cast d’un média
- détails acteur
- filmographie


⚠️ Dépend du catalog + TMDb.

📊 6️⃣ Progress
Génère la feature progress :
- suivi épisodes
- pourcentage
- dates début/fin


Séparée pour rester clean.

👥 7️⃣ Friends
Génère la feature friends :
- ajout d’amis
- demandes
- liste amis

📰 8️⃣ Feed
Génère la feature feed :
- activités des amis
- recommandations


Dépend de catalog + friends.

💬 9️⃣ Chat

👉 Toujours en dernier

Génère la feature chat :
- conversations
- messages temps réel