# ---------------------------------------------------------------------------
# Étape 1 : "builder" — installe les dépendances Python dans un environnement isolé
# ---------------------------------------------------------------------------
FROM python:3.12-slim AS builder

WORKDIR /app

# Installer les dépendances dans un dossier séparé (facilite la copie vers l'image finale)
COPY requirements.txt .
RUN pip install --no-cache-dir --target=/install -r requirements.txt

# ---------------------------------------------------------------------------
# Étape 2 : image finale — minimale, sans outils de build inutiles
# ---------------------------------------------------------------------------
FROM python:3.12-slim

# Créer un utilisateur non-root (bonne pratique de sécurité : ne jamais faire
# tourner un conteneur en root)
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copier uniquement les dépendances déjà installées (pas les outils de compilation)
COPY --from=builder /install /usr/local/lib/python3.12/site-packages
COPY ./app ./app

# Donner la propriété des fichiers au user non-root
RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8000

# Healthcheck natif Docker (en plus du endpoint /health utilisé par Kubernetes)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
