"""
============================================================
AuditPrep IA - Point d'entrée principal pour Streamlit Cloud
============================================================
Ce fichier permet à Streamlit Community Cloud (et à toute autre
plateforme d'hébergement web) d'exécuter directement la dernière
version d'AuditPrep IA (v8.5.37).
"""

import os
import sys
import runpy
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent
APP_DIR = ROOT_DIR / "app"

if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))
if str(APP_DIR) not in sys.path:
    sys.path.insert(0, str(APP_DIR))

TARGET_APP = APP_DIR / "app_dashboard_auditprep_v8_5_37.py"

if not TARGET_APP.exists():
    raise FileNotFoundError(f"Fichier d'application introuvable : {TARGET_APP}")

runpy.run_path(str(TARGET_APP), run_name="__main__")
