# Plan de Build : Simulateur Mars Rover

Intention de référence : intent/mars-rover/intent.md
Spécification de référence : intent/mars-rover/spec.md

Ce document couvre la phase Build : aucune décision produit n'y est prise (toutes ont été tranchées en phase Spec — R-01, R-02, Q1-Q5). Il ne fixe que des détails de conception explicitement laissés libres par la spec (« Conception proposée », EX-07, EX-09, EX-10).

## 1. Décisions de conception (Build)

### D1 — Structure du/des fichier(s) d'entrée

Décision : un seul fichier texte par scénario, à trois sections balisées par mot-clé.

    START 3 4 N

    MAP
    🟩🟩🌳🟩🟩
    🟩🟫🟩🪨🟩
    🟩🟩🟩🟩🟩

    COMMANDS
    FRRFLF

- `START <x> <y> <orientation>` : une ligne, trois jetons séparés par des espaces.
- `MAP` : une ligne par rangée de la grille, un symbole par case ; toutes les lignes de même longueur.
- `COMMANDS` : une ligne de lettres (`F`, `R`, `L`), sans séparateur.
- Sections séparées par une ligne vide, ordre fixe (`START`, `MAP`, `COMMANDS`).

Justification : EX-09 autorise « un ou plusieurs fichiers » sans l'imposer. Un seul fichier réduit le risque d'erreur opérateur (fichiers dépareillés, mauvais ordre d'arguments), simplifie l'invocation CLI à un seul argument positionnel, et donne un fixture de test = un scénario = un fichier lisible d'un coup d'œil. L'alternative à plusieurs fichiers séparés est écartée : les trois éléments sont toujours utilisés ensemble et jamais réutilisés indépendamment.

Convention de repère (détail interne, non observable) : dans `MAP`, la première ligne correspond à la rangée la plus au nord (y maximal), la dernière à y=0 ; x croît de gauche à droite à partir de 0.

### D2 — Messages de sortie et codes de sortie

- Résultat normal (stdout, code 0) :
  ```
  Position finale : (x, y)
  Orientation finale : N
  ```
- Résultat avec blocage (EX-07, complément), même code 0, une ligne ajoutée :
  ```
  Avertissement : un ou plusieurs déplacements ont été bloqués par un obstacle.
  ```
- Entrée invalide (EX-10) : rien sur stdout, message sur stderr, code de sortie 1 :
  ```
  Erreur : <message précis>
  ```
  Messages par catégorie (les quatre citées en EX-10) :
  - commande inconnue : `commande inconnue 'X' (position 3 dans la séquence)`
  - position de départ hors grille : `position de départ (12, 4) hors des limites de la carte (10x8)`
  - orientation initiale invalide : `orientation initiale invalide 'Q' (attendu : N, S, E ou W)`
  - carte mal formée : `carte mal formée : lignes de longueurs différentes` / `carte mal formée : symbole inconnu 'X'` / `carte mal formée : carte vide`
- Fichier introuvable : code 1, `Erreur : fichier introuvable : <chemin>`. Argument CLI manquant : comportement standard d'`argparse` (code 2), pas de logique custom.

Justification : convention Unix (0 = succès, non-zéro = échec), séparation stdout (résultat)/stderr (diagnostic), un seul code d'erreur applicatif car EX-10 ne demande pas de distinguer les catégories par code de sortie.

Point d'attention (documenté par un test, pas tranché ici) : EX-10 énumère quatre catégories d'entrée invalide et ne couvre pas le cas où la position de départ est valide (dans la grille) mais tombe sur une case obstacle. Ce plan ne rejette pas ce cas — le rover démarre sur la case obstacle sans erreur ni mouvement. À confirmer avec le Product Owner si ce comportement s'avère surprenant à l'usage.

### D3 — Organisation des modules

Trois couches, conformes au skill clean-code (détails d'I/O hors du comportement métier). Dans `domain`, les types sont regroupés (cohésion) plutôt qu'éclatés un-fichier-par-concept, pour éviter une abstraction prématurée sur un domaine encore petit — un découpage plus fin pourra émerger plus tard si un fichier grossit trop :

- `domain/model.py` : value objects immuables du domaine — `Position`, `Orientation` (avec `turn_right()`/`turn_left()`), `Command`, `Grid`, `Rover`. Aucune dépendance I/O ni aux symboles de carte.
- `domain/simulation.py` : logique d'exécution pure — `advance_one(rover, grid, command)`, `run(rover, grid, commands)` — seule partie du domaine à réelle complexité comportementale.
- `domain/errors.py` : exceptions de domaine (`StartPositionOutOfBounds`).
- `parsing` : traduit le texte du fichier de mission en objets du domaine (ou lève une erreur de parsing). Seul module qui connaît les symboles 🟩/🌳/🟫/🪨 — le domaine reçoit un ensemble de positions-obstacles déjà résolu.
- `cli` : point d'entrée mince. Lit le fichier, appelle `parsing` puis `domain`, met en forme le résultat/l'erreur, choisit le code de sortie. Aucune règle métier ni règle de format de fichier codée en dur ici.

### D4 — Outillage

- `pyproject.toml` (PEP 621). Aucune dépendance d'exécution : `argparse`, `dataclasses`, `enum`, `pathlib` (stdlib) suffisent.
- Outil de dev recommandé : `uv` (`uv sync`, `uv run pytest`, `uv run ruff check`) — non imposé, `pip install -e ".[dev]"` reste possible.
- Tests : `pytest` (déjà anticipé par `.gitignore` : `.pytest_cache/`).
- Qualité : `ruff` (lint + format) dès le départ — anticipé par `.gitignore` (`.ruff_cache/`), coût de configuration faible.
- **`mypy` différé à l'étape 5 (Polish final)**, pas configuré dès le squelette initial : le TDD du domaine/parsing (étapes 2-3) avance plus vite sans discipline de typage à chaque itération ; `mypy` est appliqué une fois le code stabilisé, en cohérence avec le principe clean-code de ne pas dépasser le nettoyage nécessaire pendant que la conception est encore en train d'émerger. Anticipé par `.gitignore` (`.mypy_cache/`).
- Layout `src/` pour éviter les imports accidentels pendant les tests.

## 2. Arborescence des fichiers à créer

```
pyproject.toml
README.md                               # mis à jour : installation, usage CLI, format du fichier de mission
CLAUDE.md                               # section "Project state" et commandes à mettre à jour une fois l'outillage en place

src/mars_rover/
  __init__.py
  domain/
    __init__.py
    model.py              # Position, Orientation (turn_right/turn_left, vecteur de déplacement), Command, Grid (contains/is_free), Rover
    simulation.py              # advance_one(rover, grid, command) -> (rover, moved) ; run(rover, grid, commands) -> SimulationResult
    errors.py                    # StartPositionOutOfBounds (erreur de domaine, EX-10)
  parsing/
    __init__.py
    symbols.py           # symbole -> libre/obstacle (🟩🟫 libres, 🌳🪨 obstacles) ; MalformedMapError si symbole inconnu
    mission_file.py        # parse_mission(text) -> Mission(start_position, start_orientation, grid, commands) ; erreurs EX-10
  cli/
    __init__.py
    main.py                # argparse, lecture fichier, orchestration parsing -> domaine -> formatage -> exit code
    formatting.py             # format_result(SimulationResult) -> str ; format_error(exception) -> str

tests/
  domain/
    test_orientation.py     # EX-03 (couvre Orientation dans model.py)
    test_grid.py              # EX-05 (frontière domaine), EX-08 (bords) (couvre Grid dans model.py)
    test_rover_simulation.py  # EX-01, EX-02, EX-04, EX-06, EX-07 (contenu du résultat) (couvre Rover/model.py + simulation.py)
  parsing/
    test_symbols.py          # EX-05 (résolution des deux jeux de symboles)
    test_mission_file.py      # EX-09 (structure du fichier), EX-10 (erreurs de parsing)
  cli/
    test_main.py               # bout en bout, fixtures de fichiers, EX-01 à EX-10, formatage exact, codes de sortie
  fixtures/missions/
    valid_no_blockage.txt
    valid_with_interior_obstacle.txt
    valid_with_edge_blockage.txt
    valid_mixed_symbol_sets.txt
    valid_multiple_blockages.txt
    valid_start_on_obstacle.txt        # documente le point d'attention D2
    invalid_unknown_command.txt
    invalid_start_out_of_bounds.txt
    invalid_start_orientation.txt
    invalid_map_uneven_rows.txt
    invalid_map_unknown_symbol.txt
```

## 3. Ordre de travail

1. **Squelette de projet** : `pyproject.toml`, arborescence `src/`/`tests/` vide, `pytest` exécutable (0 test), `ruff` configuré (`mypy` volontairement pas encore configuré à ce stade — voir D4). S'assurer que la chaîne d'outils tourne avant d'écrire la première ligne de logique.
2. **Domaine, en TDD, du plus bas niveau au plus haut** (tout dans `model.py`/`simulation.py`/`errors.py`, voir D3) :
   - `Orientation` (rotation droite/gauche, EX-03) — aucune dépendance, le plus simple à isoler.
   - `Position` + `Grid` (bornes, libre/obstacle par position déjà résolue) — EX-05 (partie domaine), EX-08.
   - `Rover` + `advance_one`/`run` — EX-01, EX-02, EX-04, EX-06, EX-07 (contenu du résultat).
   - Validation de domaine (`StartPositionOutOfBounds`) — partie d'EX-10 relevant d'un invariant métier.

   Le domaine est traité en premier et isolément : il concentre toute la règle métier testable sans infrastructure, c'est la logique la plus critique et la plus rentable à verrouiller par des tests avant d'y brancher quoi que ce soit d'autre. Le faire dépendre de rien (ni fichiers, ni symboles) garantit qu'aucun détail d'I/O ne s'y infiltre.
3. **Parsing, en TDD** : `symbols.py` (résolution des deux jeux d'obstacles, EX-05) puis `mission_file.py` (découpage des sections, construction d'un `Mission`, erreurs de syntaxe couvrant EX-10 sauf le hors-limites qui reste du ressort du domaine). Le parsing vient après le domaine car il en est un simple adaptateur : il construit des objets déjà définis et testés, sans nouvelle règle métier.
4. **CLI, en dernier** : `main.py` (orchestration, codes de sortie) et `formatting.py` (mise en forme exacte des messages, EX-07/EX-10). C'est la couche la plus fine, qui n'a de sens qu'une fois domaine et parsing stables ; les tests de bout en bout (fixtures de fichiers réels) servent alors de tests d'acceptation qui rejouent EX-01 à EX-10 sur le programme complet.
5. **Polish final** : configuration et activation de `mypy` (différé depuis l'étape 1, voir D4) sur le code désormais stabilisé, corrections de typage éventuelles ; mise à jour de `README.md` (installation, usage, format de fichier) et de `CLAUDE.md` (section « Project state » : phase Build démarrée, commandes réelles disponibles) ; relecture contre la checklist du skill clean-code (noms, fonctions courtes, séparation commande/requête, pas d'abstraction superflue) ; exécution effective de `pytest`, `ruff`, `mypy`.

## 4. Plan de tests — traçabilité avec la spec

| Exigence | Test(s) | Niveau |
|---|---|---|
| EX-01 (point de départ) | `test_rover_initializes_at_given_position_and_orientation` ; fixture `valid_no_blockage.txt` avec commandes vides vérifiant position/orientation finales = point de départ | domaine + CLI |
| EX-02 (avancer) | `test_forward_moves_one_cell_when_target_free`, paramétré sur les 4 orientations | domaine |
| EX-03 (tourner) | `test_turn_right_cycles_N_E_S_W_N`, `test_turn_left_cycles_reverse`, paramétrés sur les 4 orientations de départ (8 cas) | domaine |
| EX-04 (obstacle interne) | `test_forward_blocked_by_interior_obstacle_leaves_state_unchanged` ; fixture `valid_with_interior_obstacle.txt` | domaine + CLI |
| EX-05 (deux jeux de symboles) | `test_symbol_resolves_free_or_obstacle` pour les 4 symboles ; `test_grid_mixes_both_symbol_sets_in_same_map` ; fixture `valid_mixed_symbol_sets.txt` | parsing + CLI |
| EX-06 (séquence complète) | `test_run_executes_every_command_in_order_including_blocked_ones` : séquence type `F(bloqué)RFLF`, vérifie que l'exécution continue après un blocage | domaine |
| EX-07 (affichage + signalement de blocage) | `test_result_has_no_warning_when_never_blocked` ; `test_result_flags_blockage_when_at_least_one_forward_was_blocked` ; `test_cli_prints_exact_success_message`, `test_cli_prints_exact_blockage_warning` | domaine + CLI |
| EX-08 (bord de carte) | `test_forward_at_edge_is_blocked`, paramétré sur les 4 bords/orientations ; fixture `valid_with_edge_blockage.txt` | domaine + CLI |
| EX-09 (lecture depuis fichier) | `test_parse_mission_reads_start_map_commands_from_file` ; `test_cli_reads_mission_file_argument` ; `test_cli_reports_error_when_file_missing` | parsing + CLI |
| EX-10 (entrée invalide) | Un test par catégorie, chacun vérifiant message stderr + code de sortie 1 + rien sur stdout : `test_unknown_command_letter_is_rejected`, `test_start_position_out_of_bounds_is_rejected`, `test_invalid_start_orientation_is_rejected`, `test_malformed_map_uneven_rows_is_rejected`, `test_malformed_map_unknown_symbol_is_rejected` | parsing + CLI |

### Cas limites complémentaires

- Carte mélangeant les deux jeux au sein d'une même rangée (`valid_mixed_symbol_sets.txt`).
- Obstacle en bordure vs obstacle interne : deux familles de tests distinctes (EX-04 vs EX-08).
- Plusieurs blocages dans une même séquence : `test_multiple_blockages_still_report_single_warning` (drapeau booléen, pas un compteur).
- Séquence de commandes vide : position/orientation finales = point de départ, pas de blocage signalé.
- Grille 1x1 : toute commande `F` est bloquée par le bord, quelle que soit l'orientation.
- Rotation jamais bloquée : `test_turn_never_blocked_regardless_of_surroundings`.
- Position de départ sur une case obstacle (point d'attention D2) : `test_start_on_obstacle_cell_is_accepted_without_error`.
- Absence d'effet de bord caché : `run()`/`advance_one()` sont des fonctions pures, testées sans mocks ni état global.
