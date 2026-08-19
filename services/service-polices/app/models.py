from pydantic import BaseModel, Field
from typing import Optional
from enum import Enum
from datetime import date


class TypePolice(str, Enum):
    auto = "auto"
    habitation = "habitation"


class PoliceCreate(BaseModel):
    nom_client: str = Field(..., examples=["Jean Tremblay"])
    type_police: TypePolice
    prime_mensuelle: float = Field(..., gt=0, examples=[89.99])
    date_debut: date
    date_fin: date


class Police(PoliceCreate):
    id: str
    actif: bool = True
