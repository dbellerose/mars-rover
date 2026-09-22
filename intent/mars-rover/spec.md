# Spec : Simulateur Mars Rover

Intention de référence : intent/mars-rover/intent.md

## Périmètre

Besoin couvert : un programme Python en ligne de commande qui valide, avant envoi au système de contrôle réel, une séquence de commandes destinée à un rover. Le programme reçoit un point de départ (position et orientation), une carte plaçant les obstacles et une liste de commandes ; il déplace le rover en conséquence, l'arrête devant un obstacle, puis affiche sa position et son orientation finales.

Utilisateurs concernés : l'équipe opérations/ingénierie interne, qui utilise l'outil pour vérifier une séquence avant de la transmettre au système de contrôle du rover.

Exclusions : l'intention ne couvre pas l'envoi effectif des commandes au rover réel ni l'intégration avec le système de contrôle — seule la validation préalable est dans le périmètre.

## Exigences

### EX-01 — Point de départ du rover

Origine dans l'intention : « un point de départ (position x, y et orientation N, S, E ou W) »
Comportement attendu : le programme accepte une position initiale (x, y) et une orientation initiale parmi N, S, E, W, et initialise le rover avec ces valeurs.

Scénario
- Situation de départ : un point de départ valide (position et orientation) est fourni au programme.
- Action : initialisation du rover.
- Résultat attendu : le rover est positionné aux coordonnées (x, y) fournies, avec l'orientation initiale fournie.

### EX-02 — Avancer

Origine dans l'intention : « avancer » ; « Il déplace le rover selon les commandes »
Comportement attendu : la commande « avancer » déplace le rover d'une case dans la direction de son orientation courante, si la case ciblée n'est pas un obstacle.

Scénario
- Situation de départ : le rover est positionné et orienté sur la carte, la case devant lui (dans le sens de son orientation) ne contient pas d'obstacle.
- Action : exécution de la commande « avancer ».
- Résultat attendu : le rover occupe la case suivante dans le sens de son orientation ; son orientation ne change pas.

### EX-03 — Tourner à droite ou à gauche

Origine dans l'intention : « tourner de 90° à droite ou à gauche »
Comportement attendu : la commande « tourner à droite » fait pivoter l'orientation du rover de 90° dans le sens N→E→S→W→N ; la commande « tourner à gauche » la fait pivoter de 90° dans le sens inverse. La position du rover ne change pas.

Scénario
- Situation de départ : le rover est orienté N.
- Action : exécution de la commande « tourner à droite ».
- Résultat attendu : le rover est orienté E, à la même position.

### EX-04 — Arrêt devant un obstacle

Origine dans l'intention : « l'arrête devant un obstacle » ; « En cas d'obstacle bloquant l'avancée, le rover reste immobile (la commande est ignorée). »
Comportement attendu : si la commande « avancer » cible une case contenant un obstacle, le rover ne se déplace pas ; sa position et son orientation restent inchangées et l'exécution de la séquence se poursuit avec la commande suivante.

Scénario
- Situation de départ : la case devant le rover (dans le sens de son orientation) contient un obstacle.
- Action : exécution de la commande « avancer ».
- Résultat attendu : la position et l'orientation du rover restent inchangées.

### EX-05 — Carte à deux jeux de symboles d'obstacles

Origine dans l'intention : « La carte peut utiliser deux jeux de symboles pour représenter les obstacles : 🟩/🌳 ou 🟫/🪨. »
Comportement attendu : le programme accepte une carte pouvant combiner librement les symboles des deux jeux (🟩/🌳 et 🟫/🪨) sur une même carte, et identifie correctement, pour chaque symbole rencontré, s'il représente une case libre ou un obstacle.

Scénario
- Situation de départ : une carte est fournie, combinant librement des symboles des deux jeux.
- Action : chargement de la carte.
- Résultat attendu : les cases marquées 🟩 ou 🟫 sont identifiées comme libres ; les cases marquées 🌳 ou 🪨 sont identifiées comme des obstacles.

### EX-06 — Exécution de la séquence de commandes

Origine dans l'intention : « une liste de commandes » ; « Il déplace le rover selon les commandes »
Comportement attendu : le programme exécute la liste de commandes fournie dans l'ordre, en appliquant EX-02 ou EX-03 pour chaque commande, et EX-04 lorsqu'un obstacle bloque un déplacement, jusqu'à la fin de la liste.

Scénario
- Situation de départ : une liste de commandes valide est fournie, avec un point de départ et une carte.
- Action : exécution de la séquence complète.
- Résultat attendu : chaque commande de la liste a été appliquée dans l'ordre, y compris les commandes ignorées en raison d'un obstacle.

### EX-07 — Affichage du résultat final

Origine dans l'intention : « affiche sa position et son orientation finales »
Comportement attendu : à la fin de l'exécution de la séquence, le programme affiche la position (x, y) et l'orientation finales du rover.

Comportement attendu (complément) : si au moins une commande « avancer » a été ignorée en raison d'un obstacle (EX-04 ou EX-08) au cours de la séquence, le programme le signale en plus de la position et de l'orientation finales. Le libellé précis de ce signalement est un détail de conception à préciser lors de la phase Build (voir Conception proposée).

Scénario
- Situation de départ : la séquence de commandes a terminé son exécution ; au moins une commande « avancer » a été ignorée à cause d'un obstacle en cours de séquence.
- Action : affichage du résultat.
- Résultat attendu : la position et l'orientation finales du rover sont affichées, accompagnées d'une indication qu'un ou plusieurs blocages ont eu lieu. Le libellé précis de cette indication est un détail de conception à préciser lors de la phase Build (voir Conception proposée).

### EX-08 — Comportement aux limites de la carte

Origine dans l'intention : implicite au fonctionnement sur une carte ; question ouverte de l'intention sur le franchissement des bords, tranchée par le Product Owner (2026-09-22).
Comportement attendu : le bord de la carte est traité comme un obstacle. Si la commande « avancer » cible une case en dehors des limites de la carte, le rover reste immobile, comme décrit en EX-04.

Scénario
- Situation de départ : le rover est en bordure de carte, orienté vers l'extérieur.
- Action : exécution de la commande « avancer ».
- Résultat attendu : la position et l'orientation du rover restent inchangées.

### EX-09 — Format des entrées et sorties du programme

Origine dans l'intention : « programme Python en ligne de commande » ; question ouverte de l'intention sur le format précis, tranchée par le Product Owner (2026-09-22).
Comportement attendu : le programme lit le point de départ, la carte et la liste de commandes depuis un ou plusieurs fichiers fournis en argument au programme, et affiche son résultat. La structure précise du ou des fichiers (nombre de fichiers, organisation du contenu) n'est pas fixée par cette décision ; elle relève d'un détail de conception à préciser lors de la phase Build (voir Conception proposée).

Scénario
- Situation de départ : l'utilisateur dispose d'un ou plusieurs fichiers décrivant le point de départ, la carte et la liste de commandes.
- Action : lancement du programme avec ce(s) fichier(s) fourni(s) en argument.
- Résultat attendu : le programme lit les entrées depuis le(s) fichier(s) fourni(s) et affiche le résultat correspondant (EX-07 ou EX-10 selon le cas).

### EX-10 — Validation des entrées invalides

Origine dans l'intention : absente de l'intention ; comportement tranché par le Product Owner en réserve R-02 (2026-09-22).
Comportement attendu : le programme détecte une entrée invalide (commande inconnue dans la liste, position de départ hors des limites de la carte, orientation initiale invalide, carte mal formée) dans le(s) fichier(s) fourni(s) (EX-09) et signale une erreur au lieu d'exécuter la séquence. Le libellé précis du signalement (message affiché, code de sortie, etc.) est un détail de conception à préciser lors de la phase Build (voir Conception proposée).

Scénario
- Situation de départ : l'une des entrées fournies au programme (position de départ, orientation, carte, liste de commandes) est invalide.
- Action : lancement du programme avec cette entrée invalide.
- Résultat attendu : le programme signale une erreur et n'affiche pas de position ou d'orientation finales résultant d'une exécution.

## Conception proposée

- **Modèle de déplacement** : le déplacement et la rotation (EX-02, EX-03) reposent sur une grille à deux axes et un ordre cyclique fixe des orientations (N→E→S→W→N pour une rotation à droite, l'inverse pour une rotation à gauche). L'association précise de chaque orientation à un vecteur de déplacement (par exemple N = y croissant) est un détail d'implémentation qui n'affecte pas le comportement observable décrit dans les exigences ; elle sera fixée lors de la phase Build sans nécessiter de décision produit. Statut : proposition, découle directement de la contrainte de l'intention.
- **Représentation de la carte** : la carte est modélisée comme une grille de cases ; chaque case est libre si elle porte le symbole 🟩 ou 🟫, ou occupée par un obstacle si elle porte le symbole 🌳 ou 🪨 (EX-05), les deux jeux pouvant être mélangés sur une même carte (R-01). Le bord de la carte se comporte comme un obstacle (EX-08). Statut : proposition découlant directement des décisions prises.
- **Séquencement des commandes** : les commandes sont traitées une à une, dans l'ordre de la liste fournie ; un obstacle (y compris un bord de carte) interrompt uniquement le déplacement demandé (EX-04, EX-08), pas l'exécution du reste de la séquence (EX-06). Statut : proposition, découle directement des contraintes de l'intention.
- **Entrées/sorties** : les entrées (point de départ, carte, liste de commandes) sont lues depuis un ou plusieurs fichiers fournis en argument au programme ; le résultat (position et orientation finales, indication d'un blocage éventuel, ou message d'erreur pour une entrée invalide) est affiché sur la sortie standard. Statut : proposition découlant de la décision sur le canal d'entrée/sortie. Restent à préciser lors de la phase Build, comme détails d'implémentation ne nécessitant pas de nouvelle décision produit : la structure exacte du ou des fichiers d'entrée (nombre de fichiers, organisation du contenu), et le libellé exact des messages affichés (résultat normal, blocage signalé en EX-07, erreur de validation en EX-10).

## Réserves

### R-01 — Mixité des jeux de symboles d'obstacles au sein d'une même carte

Origine : l'intention indique que « la carte peut utiliser deux jeux de symboles » (🟩/🌳 ou 🟫/🪨) sans préciser si une même carte peut mélanger les deux jeux ou si chaque carte doit utiliser un seul jeu de façon exclusive.
Exigences concernées : EX-05.
Conséquences : selon la réponse, les règles d'analyse de la carte diffèrent (valider qu'un seul jeu est utilisé par carte, ou accepter les deux jeux simultanément sur une même carte).
Décision : le mélange des deux jeux de symboles sur une même carte est autorisé.
Auteur : Product Owner (réponse directe, auteur non nommé).
Date : 2026-09-22.
Justification : non précisée au-delà du choix exprimé.
Statut : tranchée.

### R-02 — Gestion des entrées invalides

Origine : l'intention ne précise pas le comportement attendu face à des entrées invalides (commande inconnue dans la liste, position de départ hors des limites de la carte, orientation initiale invalide, carte mal formée).
Exigences concernées : EX-01, EX-06, EX-10.
Conséquences : sans décision, le comportement du programme face à une entrée invalide reste indéfini (échec silencieux, message d'erreur, arrêt du programme), ce qui empêche de spécifier un résultat observable pour ces cas.
Décision : la validation des entrées invalides est dans le périmètre de cette intention ; le programme doit détecter ces entrées et signaler une erreur.
Auteur : Product Owner (réponse directe, auteur non nommé).
Date : 2026-09-22.
Justification : non précisée au-delà du choix exprimé. La forme exacte du signalement (message affiché, code de sortie, etc.) reste à préciser — voir EX-10.
Statut : tranchée.

## Questions ouvertes

- **Q1 — Signification des symboles 🟩, 🌳, 🟫 et 🪨** (reprise de l'intention) : lequel de chaque paire représente un obstacle et lequel représente du terrain libre ? Réponse du Product Owner (2026-09-22, auteur non nommé) : 🟩 et 🟫 sont des cases libres ; 🌳 et 🪨 sont des obstacles. EX-05 a été mis à jour en conséquence.
- **Q2 — Franchissement des bords de la carte** (reprise de l'intention) : le rover doit-il être arrêté par les limites de la carte, pouvoir en sortir, ou avoir un comportement cyclique (téléportation au bord opposé) ? Réponse du Product Owner (2026-09-22, auteur non nommé) : le bord de la carte est infranchissable, traité comme un obstacle. EX-08 a été mis à jour en conséquence.
- **Q3 — Signalement d'un arrêt prématuré** (reprise de l'intention) : le résultat final doit-il indiquer si le rover s'est arrêté prématurément à cause d'un obstacle, en plus de sa position et de son orientation ? Réponse du Product Owner (2026-09-22, auteur non nommé) : oui, le blocage doit être signalé. EX-07 a été mis à jour en conséquence ; la forme exacte du signalement reste liée à Q4.
- **Q4 — Format précis d'entrée/sortie** (reprise de l'intention) : les entrées (point de départ, carte, commandes) sont-elles fournies par arguments en ligne de commande, par fichier, ou par entrée standard ? Réponse du Product Owner (2026-09-22, auteur non nommé) : par fichier(s) fourni(s) en argument. EX-09 a été mis à jour en conséquence ; la structure exacte du ou des fichiers reste un détail de conception pour la phase Build.
- **Q5 — Auteur de l'intention** (reprise de l'intention) : qui est l'auteur de cette intention (nom, rôle) ? Réponse du Product Owner (2026-09-22) : David B. Le rôle n'a pas été précisé. Sans effet sur le passage à la phase Build.

Toutes les questions ont reçu une réponse du Product Owner le 2026-09-22 ; les exigences EX-05, EX-07, EX-08 et EX-09 ont été mises à jour en conséquence. Aucune question bloquante ne reste ouverte pour le passage à la phase Build.

## Contexte de génération

### Demande initiale

Commande /spec avec argument : `intent/mars-rover/intent.md`

### Skills utilisées

| Chemin | Commit Git de la version utilisée |
| --- | --- |
| .claude/skills/spec/SKILL.md | 0a1ff094c77ee75ef19f494d8da77cdfbd355346 |

### Révisions

Aucune révision à ce stade.
