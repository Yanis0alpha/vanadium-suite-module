# Publier sur GitHub

Le depot est prepare localement, mais aucun depot distant n'a ete cree et
aucun fichier n'a ete envoye sur un compte GitHub.

## Avant de rendre public

Lire LICENSE.md : la provenance/licence de certaines portions adaptees des scripts
reste a verifier. Une publication privee permet de preparer le depot sans presenter
prematurement l'ensemble comme redistribuable sous une licence globale.
L'overlay lui-meme est fourni avec ses sources et sa licence MIT.

## Depuis Windows avec Git Bash et GitHub CLI

Installer Git et GitHub CLI, extraire l'archive source puis ouvrir Git Bash dans
le dossier vanadium-suite-module (celui contenant module.prop).

```sh
gh auth login
git init -b main
git add .
git commit -m "Vanadium Suite v1.1 : module et sources overlay"
gh repo create vanadium-suite-module --private --source=. --remote=origin --push
```

Si Git demande une identite, configurer son nom et son adresse Git (eventuellement
l'adresse noreply GitHub) puis relancer le commit. Ne pas partager de jeton ici.
Si un depot local existe deja, ne pas repeter l'initialisation.

## Construire et publier une release

Avec Bash et zip disponibles :

```sh
bash tools/build.sh dist/vanadium-suite-v1.1.zip
gh release create v1.1 dist/vanadium-suite-v1.1.zip --title "Vanadium Suite v1.1" --notes-file CHANGELOG.md
```

Sinon le workflow GitHub construit une archive dans Actions, artefact
vanadium-suite-flashable : extraire cet artefact et utiliser le ZIP flashable qu'il
contient, pas le ZIP externe de l'artefact ni le Source code ZIP de GitHub.

Apres verification des licences et notices, le proprietaire peut choisir de
rendre le depot public dans les parametres GitHub.
