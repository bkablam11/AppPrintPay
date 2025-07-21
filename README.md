# PrintPay - Gestion des Impressions

PrintPay est une application mobile développée en Flutter pour suivre et gérer les coûts d'impression des enseignants. L'application permet de gérer une liste d'enseignants, d'enregistrer leurs sessions d'impression, de calculer les coûts associés et de gérer les paiements. Elle est entièrement intégrée avec Firebase pour l'authentification des utilisateurs et la gestion de la base de données en temps réel.

## Fonctionnalités Implémentées

*   **Authentification des utilisateurs :** Inscription et connexion sécurisées par e-mail et mot de passe via Firebase Auth.
*   **Gestion des Enseignants (CRUD) :**
    *   Ajouter de nouveaux enseignants.
    *   Afficher la liste complète des enseignants avec une fonction de recherche.
    *   Modifier les informations d'un enseignant.
    *   Supprimer un enseignant.
*   **Gestion des Impressions (CRUD) :**
    *   Ajouter une session d'impression pour un enseignant, en spécifiant le nombre de pages et le coût par page (15 ou 25).
    *   Afficher l'historique des impressions pour chaque enseignant.
    *   Modifier une session d'impression existante.
    *   Supprimer une impression (simulant un paiement).
*   **Calcul Automatique des Coûts :**
    *   Calcul du coût total pour chaque impression.
    *   Calcul du paiement total dû par chaque enseignant.
*   **Base de Données en Temps Réel :** Toutes les données sont stockées et synchronisées en temps réel avec la base de données Firestore.

## Structure du Projet

Le projet suit une architecture claire pour séparer les responsabilités :

-   `lib/models`: Contient les modèles de données (`Teacher`, `Impression`).
-   `lib/services`: Gère la logique métier et la communication avec Firebase (`FirebaseAuthService`, `FirebaseTeacherService`).
-   `lib/screens`: Contient les différents écrans de l'application (authentification, tableau de bord, détails, etc.).
-   `lib/widgets`: Contient les composants d'interface utilisateur réutilisables.
-   `lib/utils`: Contient les utilitaires comme le thème de l'application.

## Parcours de Développement et Difficultés Rencontrées

Le développement de l'application a suivi plusieurs étapes clés, avec des défis intéressants qui ont été résolus.

### 1. Initialisation et Base avec des Données Factices

L'application a d'abord été construite avec une structure solide et des données factices (`mock data`). Cela a permis de développer et de tester rapidement l'interface utilisateur et la logique de base sans dépendre d'une base de données externe.

### 2. Intégration de Firebase

La transition vers Firebase a été l'étape la plus complexe et a présenté plusieurs défis.

#### Difficulté 1 : Erreur de Build Android (`No matching client`)

-   **Problème :** L'application ne parvenait pas à se construire sur Android, avec une erreur indiquant qu'aucun client ne correspondait au nom de package `com.example.app`.
-   **Cause :** Le fichier de configuration de Firebase (`google-services.json`) était configuré pour un nom de package, mais le fichier de configuration de l'application Android (`build.gradle.kts`) en utilisait un autre.
-   **Résolution :** Nous avons d'abord tenté de changer le nom du package de l'application pour `com.printpay.app`, puis, sur votre instruction, nous l'avons remis à `com.example.app` pour qu'il corresponde parfaitement au fichier `google-services.json` fourni. Cela a résolu l'erreur de build.

#### Difficulté 2 : Fermeture Brusque de l'Application

-   **Problème :** Une fois l'erreur de build résolue, l'application se lançait mais se fermait immédiatement.
-   **Cause :** Il y avait deux causes principales :
    1.  **Initialisation incorrecte des services :** Dans le fichier `main.dart`, deux instances distinctes du `FirebaseTeacherService` étaient créées, ce qui entraînait des conflits et un état incohérent.
    2.  **Modélisation des données pour Firestore :** La manière dont les "impressions" étaient stockées dans la base de données ne leur donnait pas d'identifiant unique, ce qui rendait leur modification ou suppression impossible et pouvait causer des erreurs.
-   **Résolution :**
    1.  Le fichier `main.dart` a été corrigé pour garantir qu'**une seule instance** de chaque service Firebase est créée et partagée dans toute l'application en utilisant `Provider`.
    2.  Les modèles de données (`Impression` et `Teacher`) ont été mis à jour pour inclure des identifiants uniques et des méthodes de conversion (`fromMap`, `toFirestore`) robustes pour une communication fiable avec Firestore.

#### Difficulté 3 : Erreurs de `Provider`

-   **Problème :** Après la migration vers `FirebaseTeacherService`, certaines parties de l'application essayaient encore d'accéder à l'ancien service de données factices, provoquant des erreurs `Provider not found`.
-   **Résolution :** Tous les écrans (`AddEditTeacherScreen`, `AddEditImpressionScreen`, etc.) ont été méticuleusement vérifiés et mis à jour pour utiliser le nouveau `FirebaseTeacherService`, assurant ainsi la cohérence de l'accès aux données.

## Journal des Tâches Effectuées

Voici la liste de toutes les étapes qui ont été complétées pour arriver au résultat final :

- [x] Mettre à jour pubspec.yaml avec les dépendances initiales
- [x] Créer les fichiers de modèle (Teacher, Impression)
- [x] Créer le service de données factices
- [x] Créer les écrans de base
- [x] Créer le fichier de thème
- [x] Mettre à jour main.dart
- [x] Créer les fichiers vides pour les écrans et widgets restants
- [x] Lancer `flutter pub get` pour installer les dépendances
- [x] Corriger le fichier de test initial
- [x] Mettre à jour le modèle Impression pour y inclure un identifiant unique
- [x] Mettre à jour le service de données pour gérer les impressions (CRUD)
- [x] Créer l'écran d'ajout/modification d'impression
- [x] Mettre à jour l'écran de détails de l'enseignant avec les nouvelles fonctionnalités
- [x] Permettre à l'utilisateur de choisir le coût par page (15 ou 25)
- [x] Configurer Firebase (dépendances, fichiers de configuration Android, initialisation)
- [x] Implémenter les rapports et les graphiques
## Comment Lancer l'Application

1.  Assurez-vous d'avoir le SDK Flutter installé.
2.  Placez le fichier `google-services.json` correct dans le dossier `android/app/`.
3.  Exécutez `flutter pub get` pour installer les dépendances.
4.  Lancez l'application avec `flutter run`.

### TAF

- Vérifier et corriger la mise à jour du "Total Payé" après l'enregistrement d'un paiement.

Pourriez-vous décrire les étapes exactes qui mènent au "Total Payé" qui se réinitialise à 0.00 F ? Par exemple, est-ce que cela se produit après avoir fermé et rouvert l'application, après avoir ajouté une nouvelle impression, ou après avoir effectué une autre action ?


Analyser le code de `teacher_details_screen.dart` pour comprendre la gestion du "Total Payé".
Identifier la cause de la réinitialisation du "Total Payé".
Proposer une solution pour corriger le problème.

