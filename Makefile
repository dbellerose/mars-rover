# Déploiement simulé : aucune machine n'est contactée.
# L'état de chaque environnement est conservé dans .git/deploy/<ENV>/,
# hors de l'arbre versionné :
#   current  : version posée sur l'environnement
#   previous : version qu'elle a remplacée

DEPLOY_DIR := $(shell git rev-parse --git-dir 2>/dev/null)/deploy

.PHONY: deploy rollback check-env

check-env:
	@case "$(ENV)" in \
	  '') echo "Erreur : précisez l'environnement, par exemple make $(MAKECMDGOALS) ENV=staging" >&2; exit 1 ;; \
	  *[!A-Za-z0-9_-]*) echo "Erreur : ENV='$(ENV)' invalide (lettres, chiffres, - et _ uniquement)" >&2; exit 1 ;; \
	esac

deploy: check-env
	@set -e; \
	dir="$(DEPLOY_DIR)/$(ENV)"; \
	commit=$$(git rev-parse HEAD); \
	mkdir -p "$$dir"; \
	current=$$(cat "$$dir/current" 2>/dev/null || true); \
	if [ "$$current" = "$$commit" ]; then \
	  echo "$(ENV) : $$commit est déjà posée, rien à faire"; \
	  exit 0; \
	fi; \
	if [ -n "$$current" ]; then \
	  echo "$$current" > "$$dir/previous"; \
	fi; \
	echo "$$commit" > "$$dir/current"; \
	echo "$(ENV) : version $$commit posée$${current:+ (remplace $$current)}"

rollback: check-env
	@set -e; \
	dir="$(DEPLOY_DIR)/$(ENV)"; \
	previous=$$(cat "$$dir/previous" 2>/dev/null || true); \
	if [ -z "$$previous" ]; then \
	  echo "Erreur : aucune version précédente pour $(ENV), rollback impossible" >&2; \
	  exit 1; \
	fi; \
	current=$$(cat "$$dir/current"); \
	echo "$$previous" > "$$dir/current"; \
	rm -f "$$dir/previous"; \
	echo "$(ENV) : $$current -> $$previous"
