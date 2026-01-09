# Déploiement sur Vercel (Connecthys)

Ce dépôt contient l'application Connecthys (Flask). Cette documentation décrit les étapes pour déployer l'application sur vercel.com en utilisant un conteneur Docker (méthode simple et reproductible).

## Aperçu

- Nous utilisons un Dockerfile pour packager l'application et `gunicorn` comme serveur WSGI en production.
- `vercel.json` indique à Vercel d'utiliser le builder Docker (`@vercel/docker`).

## Pré-requis

- Un compte sur https://vercel.com
- Le projet hébergé sur Git (GitHub, GitLab ou Bitbucket) ou accès local si vous souhaitez déployer depuis votre machine avec la CLI Vercel.
- Les secrets / variables d'environnement nécessaires (base de données, mails, etc.). Connecthys lit sa configuration depuis `connecthys/application/data/config.py` si présent. Pour un déploiement sur Vercel, il est recommandé d'utiliser des variables d'environnement et d'adapter `data/config.py` pour les lire.

> Remarque : Connecthys peut fonctionner sans `data/config.py` (affiche l'écran de configuration). Pour un déploiement réel, créez `connecthys/application/data/config.py` ou fournissez les variables d'environnement requises par votre configuration.

## Contenu ajouté

- `Dockerfile` : image légère Python 3.11 + gunicorn
- `vercel.json` : configure Vercel pour utiliser le Dockerfile
- `requirements.txt` : mis à jour pour inclure `gunicorn`

## Étapes pas à pas (depuis GitHub)

1. Poussez (push) votre dépôt sur GitHub (ou autre VCS supporté). Assurez-vous que les fichiers ajoutés (`Dockerfile`, `vercel.json`, `requirements.txt` modifié) sont committés.

2. Sur vercel.com :
   - Connectez-vous et cliquez sur "New Project".
   - Importez votre dépôt GitHub/GitLab/Bitbucket.
   - Vercel détectera `vercel.json` et utilisera le builder Docker.

3. Configuration des variables d'environnement et secrets :
   - Dans le tableau de bord du projet Vercel, allez dans "Settings > Environment Variables".
   - Ajoutez les variables nécessaires, par exemple :
     - `SQLALCHEMY_DATABASE_URI` (ex: `sqlite:///data.db` ou URI pour PostgreSQL/MySQL).
     - `SECRET_KEY` et autres clés spécifiques à Connecthys.
   - Si vous préférez, créez un fichier `connecthys/application/data/config.py` localement qui lit ces variables d'environnement. Exemple minimal :

```python
# Exemple minimal à placer dans connecthys/application/data/config.py
import os
class Config_application:
    DEBUG = False
    SECRET_KEY = os.environ.get('SECRET_KEY', 'change_me')
    SQLALCHEMY_DATABASE_URI = os.environ.get('SQLALCHEMY_DATABASE_URI', 'sqlite:///connecthys.db')
    # Ajoutez d'autres options (MAIL, CAPTCHA, etc.) selon vos besoins
```

4. Déploiement via l'interface Vercel :
   - Lancez le déploiement (Deploy). Vercel build l'image Docker et lance le conteneur.
   - Le conteneur écoute sur la variable `PORT` fournie par Vercel (nous avons configuré le Dockerfile pour utiliser `$PORT`). Vous n'avez rien à configurer de plus pour le port.

5. Vérifications post-déploiement :
   - Ouvrez l'URL fournie par Vercel.
   - Vérifiez les logs de build et d'exécution sur le dashboard Vercel (onglet "Deployments" puis logs) pour toute erreur (manque de dépendance, erreurs d'import, fichier de config manquant, etc.).

## Déploiement depuis la CLI (optionnel)

Si vous préférez déployer depuis votre machine :

1. Installez la CLI Vercel :
   - `npm i -g vercel` (ou suivez la doc officielle)
2. Dans le répertoire du projet (racine du dépôt), exécutez :

```pwsh
vercel login
vercel
```

3. Suivez les invites. La CLI poussera et déploiera votre projet.

## Notes et points d'attention

- Fichiers persistants : les déploiements serverless / conteneurisés sur Vercel n'offrent pas de stockage de fichiers persistant entre déploiements. Si votre application écrit des fichiers (par ex. pièces jointes), utilisez un stockage externe (Amazon S3, Azure Blob, Google Cloud Storage, etc.) ou une base de données.

- Base de données : pour production, configurez une base distante (Postgres, MySQL). Évitez SQLite pour des instances productives à haute charge.

- Temps d'exécution : les conteneurs Vercel peuvent avoir des limites sur la durée de démarrage/arrêt et ressources. Ajustez le nombre de workers `-w` de gunicorn si nécessaire.

- Sécurité : définissez `SECRET_KEY` et autres secrets comme variables d'environnement sur Vercel (Settings > Environment Variables).

- Debug : activez `Config_application.DEBUG` uniquement en développement.

## Dépannage rapide

- Erreur "Module not found": vérifiez `requirements.txt` et que le module est installé dans l'image.
- Erreur liée à `data/config.py` : créez le fichier comme indiqué ci-dessus ou fournissez les variables d'environnement attendues.
- L'application ne démarre pas / timeouts : regardez les logs de build et d'exécution sur Vercel et augmentez le timeout si nécessaire (dans gunicorn via `--timeout`).

## Résumé des fichiers modifiés / ajoutés

- `requirements.txt` : + `gunicorn`
- `Dockerfile` : image pour production
- `vercel.json` : instructeur de build Vercel
- `vercel.md` : (vous lisez ce fichier)

---

Si vous voulez, je peux :
- Ajouter un exemple `connecthys/application/data/config.py` directement au dépôt (fichier template non sensible).
- Ajouter un `README-deploy.md` avec commandes CLI plus détaillées.
- Aider à configurer l'accès DB (ex : ajouter un `docker-compose` pour test local avec Postgres).

Dites-moi ce que vous voulez que je fasse ensuite.