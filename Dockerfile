FROM python:3.11-slim

# Met le code dans /app
WORKDIR /app
COPY . /app

# Installer des dépendances système nécessaires (si besoin pour certains paquets)
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

# Installer les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Crée le dossier pour les pièces si nécessaire
RUN mkdir -p /app/pieces

# Port attendu par Vercel pour les conteneurs
ENV PORT 8080
EXPOSE 8080

# Lancement via gunicorn, binding sur $PORT
CMD ["sh", "-lc", "gunicorn \"connecthys.application:app\" -w 4 -b 0.0.0.0:${PORT} --timeout 120"]
