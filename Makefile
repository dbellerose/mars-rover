# Commandes de vérification du simulateur Mars Rover.
# Chemins et module CLI alignés sur intent/mars-rover/plan.md (layout src/, pytest).

PYTHON ?= python3
DEMO_MISSION := examples/demo.txt

.PHONY: test run

test:
	PYTHONPATH=src $(PYTHON) -m pytest

run: $(DEMO_MISSION)
	PYTHONPATH=src $(PYTHON) -m mars_rover.cli.main $(DEMO_MISSION)

$(DEMO_MISSION):
	@mkdir -p $(dir $@)
	@printf '%s\n' 'START 1 0 N' '' 'MAP' '🟩🟩🌳🟩🟩' '🟩🟫🟩🪨🟩' '🟩🟩🟩🟩🟩' '' 'COMMANDS' 'FFRFLF' > $@
