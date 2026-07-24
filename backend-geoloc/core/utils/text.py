"""Utilitários de texto para comparação geográfica."""
from __future__ import annotations

import unicodedata
from typing import Optional


def normalize_geo_text(value: Optional[str]) -> str:
    """Normaliza texto para comparação (minúsculas, sem acentos)."""
    if value is None:
        return ''
    text = str(value).strip().lower()
    # Remove acentos: "São Paulo" -> "sao paulo"
    text = unicodedata.normalize('NFKD', text)
    text = ''.join(ch for ch in text if not unicodedata.combining(ch))
    return text


def matches_city_state_country(
    address_props: dict,
    city: str,
    state: str,
    country_iso: str,
) -> bool:
    """Compara cidade/estado/país do endereço com a configuração, ignorando acentos."""
    prop_city = normalize_geo_text(address_props.get('cidade'))
    prop_state = normalize_geo_text(address_props.get('estado'))
    prop_country = normalize_geo_text(address_props.get('codigo_pais'))

    return (
        prop_city == normalize_geo_text(city)
        and prop_state == normalize_geo_text(state)
        and prop_country == normalize_geo_text(country_iso)
    )
