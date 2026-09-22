# Intent : Simulateur Mars Rover
Auteur : non renseigné.

## Problème
Avant d'envoyer une séquence de commandes à un rover réel, l'équipe a besoin de pouvoir la valider au préalable, afin d'éviter des erreurs coûteuses ou irréversibles sur le terrain.

## Résultat proposé
Un programme Python en ligne de commande qui reçoit :
- un point de départ (position x, y et orientation N, S, E ou W),
- une carte plaçant les obstacles,
- une liste de commandes.

Il déplace le rover selon les commandes (avancer, tourner de 90° à droite ou à gauche), l'arrête devant un obstacle, puis affiche sa position et son orientation finales.

## Utilisateurs et systèmes concernés
L'équipe opérations/ingénierie en interne, qui utilise l'outil pour vérifier une séquence de commandes avant de la transmettre au système de contrôle du rover.

## Contraintes
- Le point de départ est exprimé par une position (x, y) et une orientation (N, S, E, W).
- Les commandes possibles sont : avancer, tourner à droite de 90°, tourner à gauche de 90°.
- En cas d'obstacle bloquant l'avancée, le rover reste immobile (la commande est ignorée).
- La carte peut utiliser deux jeux de symboles pour représenter les obstacles : 🟩/🌳 ou 🟫/🪨.

## Questions ouvertes
- Que représentent exactement les symboles 🟩, 🌳, 🟫 et 🪨 (lequel est un obstacle, lequel est du terrain libre) ?
- Le rover doit-il gérer le franchissement des bords de la carte (limite, sortie, ou comportement cyclique) ?
- Le résultat final (position et direction) doit-il aussi signaler si le rover s'est arrêté prématurément à cause d'un obstacle ?
- Quel format d'entrée/sortie est attendu précisément (arguments CLI, fichier, entrée standard) ?
- Qui est l'auteur de cette intention (nom, rôle) ?
