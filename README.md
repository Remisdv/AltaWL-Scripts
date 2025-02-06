# GTA-SCRIPT

Ce projet contient une collection de scripts pour **FiveM**, une modification de GTA V permettant de créer des serveurs personnalisés.

## Fonctionnalités principales
- Scripts divers pour enrichir l'expérience de jeu
- Gestion des véhicules et du gameplay
- Systèmes de location et interactions avec les joueurs
- Optimisation et compatibilité avec **FiveM**

## Installation

1. **Cloner le dépôt**
```bash
git clone https://github.com/tonpseudo/GTA-SCRIPT.git
cd GTA-SCRIPT
```

2. **Ajouter les scripts à votre serveur FiveM**
   - Placer les dossiers de scripts dans le répertoire `resources/`
   - Modifier le fichier `server.cfg` pour inclure les ressources :
   ```cfg
   start DRUG
   start Gofast
   start RV_PersonalRental
   start RV_Seats
   start RV_rental
   start R_CORE
   start R_youtool
   start VIP
   start V_CORE
   ```

3. **Démarrer votre serveur**
```bash
./run.sh  # ou start.bat si sous Windows
```

## Technologies utilisées
- **Lua** pour les scripts clients et serveurs
- **FiveM** comme environnement d'exécution
- **HTML/CSS/JS** pour les interfaces utilisateur

## Auteur
Projet réalisé pour le serveur AltaWL.

Si vous souhaitez contribuer ou signaler un problème, ouvrez une issue.

