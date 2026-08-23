import pytest
from fastapi.testclient import TestClient
from app.main import app, polices_db


@pytest.fixture(autouse=True)
def reset_db():
    """S'exécute automatiquement avant CHAQUE test : vide la base en mémoire
    pour garantir que les tests sont indépendants les uns des autres."""
    polices_db.clear()
    yield
    polices_db.clear()


client = TestClient(app)


def test_health_check():
    """Le endpoint /health doit toujours répondre 200 - c'est ce que
    Kubernetes utilise pour savoir si le pod est vivant (liveness probe)."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_lister_polices_vide():
    """Sans aucune police créée, la liste doit être vide."""
    response = client.get("/polices")
    assert response.status_code == 200
    assert response.json() == []


def test_creer_police_valide():
    """Créer une police avec des données valides doit retourner 201
    et renvoyer la police avec un ID généré."""
    payload = {
        "nom_client": "Jean Tremblay",
        "type_police": "auto",
        "prime_mensuelle": 89.99,
        "date_debut": "2026-01-01",
        "date_fin": "2026-12-31",
    }
    response = client.post("/polices", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert data["nom_client"] == "Jean Tremblay"
    assert data["actif"] is True
    assert "id" in data


def test_creer_police_prime_negative_rejetee():
    """Le modèle Pydantic impose prime_mensuelle > 0 (gt=0).
    Une prime négative ou à zéro doit être rejetée AVANT même
    d'atteindre la logique métier - c'est Pydantic qui filtre ça."""
    payload = {
        "nom_client": "Jean Tremblay",
        "type_police": "auto",
        "prime_mensuelle": -10,
        "date_debut": "2026-01-01",
        "date_fin": "2026-12-31",
    }
    response = client.post("/polices", json=payload)
    assert response.status_code == 422  # Erreur de validation Pydantic


def test_obtenir_police_inexistante():
    """Demander une police avec un ID qui n'existe pas doit
    retourner 404, pas planter le serveur (erreur 500)."""
    response = client.get("/polices/id-qui-nexiste-pas")
    assert response.status_code == 404


def test_obtenir_police_existante():
    """Créer une police, puis la récupérer par son ID doit
    retourner exactement les mêmes données."""
    payload = {
        "nom_client": "Marie Gagnon",
        "type_police": "habitation",
        "prime_mensuelle": 45.50,
        "date_debut": "2026-01-01",
        "date_fin": "2026-12-31",
    }
    create_response = client.post("/polices", json=payload)
    police_id = create_response.json()["id"]

    get_response = client.get(f"/polices/{police_id}")
    assert get_response.status_code == 200
    assert get_response.json()["nom_client"] == "Marie Gagnon"


def test_supprimer_police():
    """Supprimer une police existante doit retourner 204,
    et elle ne doit plus être récupérable ensuite (404)."""
    payload = {
        "nom_client": "Paul Roy",
        "type_police": "auto",
        "prime_mensuelle": 60.00,
        "date_debut": "2026-01-01",
        "date_fin": "2026-12-31",
    }
    create_response = client.post("/polices", json=payload)
    police_id = create_response.json()["id"]

    delete_response = client.delete(f"/polices/{police_id}")
    assert delete_response.status_code == 204

    get_response = client.get(f"/polices/{police_id}")
    assert get_response.status_code == 404


def test_supprimer_police_inexistante():
    """Supprimer une police qui n'existe pas doit retourner 404,
    pas planter ni retourner un faux succès."""
    response = client.delete("/polices/id-qui-nexiste-pas")
    assert response.status_code == 404
