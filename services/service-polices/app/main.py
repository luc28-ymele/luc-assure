import uuid
import logging
from fastapi import FastAPI, HTTPException, status
from fastapi.responses import JSONResponse

from app.models import Police, PoliceCreate

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("service-polices")

app = FastAPI(
    title="Luc-Assure — Service Polices",
    description="Microservice de gestion des polices d'assurance (auto, habitation).",
    version="1.0.0",
)

# Stockage en mémoire pour l'instant (sera remplacé par PostgreSQL/RDS — voir roadmap Phase 6)
polices_db: dict[str, Police] = {}


@app.get("/health", tags=["Santé"])
def health_check():
    """Endpoint de santé utilisé par Kubernetes (liveness/readiness probes)."""
    return {"status": "ok", "service": "service-polices"}


@app.get("/polices", response_model=list[Police], tags=["Polices"])
def lister_polices():
    """Retourne la liste de toutes les polices."""
    return list(polices_db.values())


@app.get("/polices/{police_id}", response_model=Police, tags=["Polices"])
def obtenir_police(police_id: str):
    """Retourne une police spécifique par son ID."""
    police = polices_db.get(police_id)
    if not police:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Police introuvable")
    return police


@app.post("/polices", response_model=Police, status_code=status.HTTP_201_CREATED, tags=["Polices"])
def creer_police(police_data: PoliceCreate):
    """Crée une nouvelle police d'assurance."""
    police_id = str(uuid.uuid4())
    police = Police(id=police_id, **police_data.model_dump())
    polices_db[police_id] = police
    logger.info(f"Police créée: {police_id} pour {police.nom_client}")
    return police


@app.delete("/polices/{police_id}", status_code=status.HTTP_204_NO_CONTENT, tags=["Polices"])
def supprimer_police(police_id: str):
    """Supprime (annule) une police."""
    if police_id not in polices_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Police introuvable")
    del polices_db[police_id]
    logger.info(f"Police supprimée: {police_id}")
    return JSONResponse(status_code=status.HTTP_204_NO_CONTENT, content=None)
