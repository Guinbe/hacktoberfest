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
      ├─ Tuteur S11 → Audio, exemples, signalement, exercices
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
- Les données, téléchargements, synchronisation et exports sont **simulés** :
  aucune API, authentification, sauvegarde locale ou génération IA n’est
  connectée dans ce prototype.
- La bascule hors ligne, l’échec puis la reprise de synchronisation, le faible
  stockage et les filtres sont accessibles pour essayer les états de l’interface.
- Les conversations privées ne sont pas exposées dans l’espace enseignant ;
  celui-ci affiche uniquement des progrès par compétence.
- Le bouton de texte agrandi, les libellés accessibles, les contrastes et les
  états avec icône et texte accompagnent les indicateurs de couleur.

## Vérification

```sh
flutter test
flutter analyze
```
