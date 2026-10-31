# Sabi

**Comprendre, à ton rythme.** Sabi est un prototype Flutter d’aide en
mathématiques pour les élèves de Troisième au Cameroun. Il explique les notions
pas à pas, propose des exercices adaptés et aide les enseignants à repérer les
besoins d’accompagnement. Sabi complète le travail de l’enseignant ; il ne le
remplace pas.

## Lancer le prototype

```sh
flutter pub get
flutter run
```

Cette commande lance le prototype en mode local : sans adresse du relais, le
tuteur utilise les explications enregistrées sur le téléphone. Pour activer
Gemma, suis les étapes Windows ci-dessous.

Le parcours mobile est pensé pour un écran de **360 × 800**. Sur un grand écran
(à partir de 1000 px), le prototype ouvre directement le tableau de bord
enseignant, conçu pour **1280 × 800**. Le menu « Mon espace » permet de passer
d’un espace à l’autre.

## Parcours élève

```text
S01 Splash
  → S02 Découverte (3 écrans, glisser ou Continuer)
  → S03 Inscription / connexion (code élève + PIN)
  → S04 Autorisation parentale
  → S05 Présentation du test
  → S05a Test de positionnement (10 questions, sans chronomètre)
  → S05b Parcours de compétences
  → S06 Accueil
      ├─ Chapitre → S07 Compétences → S08 Leçon → S09 Exercice
      │                                        ├─ Indices progressifs
      │                                        ├─ Tuteur S11
      │                                        └─ S10 Correction
      │                                             └─ S10a Compétence maîtrisée
      ├─ Recherche locale → leçon ou chapitre
      ├─ Tuteur S11 → Gemma via serveur sécurisé, solution locale de secours, exercices
      ├─ Progrès S12 → Badges S12a / Historique S13 → Correction S10
      ├─ Notifications S16
      └─ Profil S15
           ├─ Hors ligne S14 (téléchargements, synchronisation, stockage)
           ├─ Paramètres S17
           ├─ Confidentialité S18
           ├─ Aide S19
           └─ Espace enseignant T01
```

## Parcours enseignant

```text
T01 Connexion enseignant
  ├─ Première visite → T02 Création de classe → T03 Vue d’ensemble
  └─ Connexion suivante → T03 Vue d’ensemble
       ├─ Compétences T04 → case rouge T05 Élèves → T05a Détail élève
       │                    └─ compétence → T06 Remédiation
       ├─ Élèves T05 → T05a Détail élève → Ajouter à une séance T06
       ├─ Planifier une remédiation → T06 → confirmation → T03
       ├─ Rapports T07 → export PDF ou CSV
       └─ Contenus T08 → détail T08a → signalement d’erreur
```

## Prototype et accessibilité

- Interface française, thème clair, couleurs Sabi et navigation interactive.
- La recherche reste locale. Le tuteur peut utiliser Gemma au travers du
  serveur `backend/`; à la première question, l’élève voit un avis clair et doit
  confirmer avant tout envoi. Une réponse préparée sur le téléphone reste
  disponible si le serveur n’est pas configuré ou ne répond pas.
- Les données, téléchargements, progression et exports sont **simulés** :
  aucune authentification d’élève ni sauvegarde persistante n’est connectée.
- La clé Google reste uniquement dans l’environnement du serveur; ne l’ajoute
  jamais à Flutter, à `--dart-define`, à un dépôt ou à une capture d’écran.
- Le proxy local limite la taille et la fréquence des requêtes. Avant une mise
  en production, déployer derrière HTTPS et ajouter une authentification des
  utilisateurs, une limitation de débit partagée et les protections anti-abus
  de la plateforme d’hébergement.
- Les conversations privées ne sont pas exposées dans l’espace enseignant ;
  celui-ci affiche uniquement des progrès par compétence.
- Le bouton de texte agrandi, les libellés accessibles, les contrastes et les
  états avec icône et texte accompagnent les indicateurs de couleur.

## Activer Gemma pour le développement local

Révoque toute clé déjà partagée dans une conversation, puis crée une nouvelle
clé dans Google AI Studio. Ouvre le fichier `.env` à la racine du projet et
remplace `COLLE_TA_NOUVELLE_CLE_ICI` par la nouvelle clé :

```env
GEMINI_API_KEY=TA_NOUVELLE_CLE
```

Le fichier `.env` est volontairement ignoré par Git : il reste modifiable dans
VS Code, mais sa clé ne sera pas ajoutée au dépôt. Ne partage jamais son contenu.

Dans un premier terminal PowerShell, depuis le dépôt :

```powershell
.\backend\start-local.ps1
```

Laisse ce terminal ouvert. Vérifie que le relais répond en ouvrant
`http://localhost:8787/health` ; il doit afficher `{"status":"ok"}`.
Avant d’ouvrir l’application, teste la connexion réelle à Google avec
`http://localhost:8787/api/test`. Une réponse `{"status":"ok",...}` confirme le
modèle et l’accès à l’API ; une erreur 401/403 indique que la clé doit être
remplacée, et une erreur 429 signale une limite de quota. L’endpoint de test
envoie un petit prompt à Google.

Dans un second terminal, démarre l’app avec l’adresse du relais correspondant
à ta cible :

```powershell
# Navigateur Chrome sur cet ordinateur
flutter run -d chrome --dart-define=TUTOR_API_URL=http://localhost:8787/api/tutor

# Émulateur Android
flutter run --dart-define=TUTOR_API_URL=http://10.0.2.2:8787/api/tutor
```

Pour un téléphone physique ou un déploiement, utiliser l’adresse HTTPS du
serveur. Le modèle par défaut est `gemma-3-27b-it`; il peut être modifié avec
`GEMMA_MODEL`. Chaque question envoyée au tuteur est transmise au relais puis à
Google. Si l’app affiche encore une réponse enregistrée, vérifie que tu
as relancé Flutter avec `--dart-define=TUTOR_API_URL=...` après avoir démarré le
relais.

## Vérification

```sh
flutter test
flutter analyze
```

Les tests du proxy se lancent avec `node --test backend/server.test.mjs`.
