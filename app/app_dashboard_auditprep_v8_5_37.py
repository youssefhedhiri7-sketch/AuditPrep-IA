# ============================================================
# AuditPrep IA - V8.5.37
# Correctif SITE : lisibilite definitive des cartes claires.
# Base fonctionnelle : V8.5.29 (version actuellement utilisee
# par Streamlit Cloud).
#
# Cette version ne remplace pas la logique metier. Elle charge
# la V8.5.29 et corrige son HTML/CSS avant execution.
# ============================================================

from pathlib import Path
import re

BASE_FILE = Path(__file__).with_name("app_dashboard_auditprep_v8_5_29.py")

if not BASE_FILE.exists():
    raise FileNotFoundError(
        f"Fichier de base introuvable : {BASE_FILE}"
    )

source = BASE_FILE.read_text(encoding="utf-8")

# ------------------------------------------------------------
# 1. Correction directe des cartes metier claires
# ------------------------------------------------------------
# Les anciens themes superposes de la V8.5.29 peuvent imposer
# un texte blanc aux descendants d'une carte blanche.
# Ici on modifie DIRECTEMENT le HTML genere par le script.

PARENT_STYLE = (
    "background:#F8F4FF !important;"
    "background-color:#F8F4FF !important;"
    "color:#000000 !important;"
    "-webkit-text-fill-color:#000000 !important;"
    "border:1px solid rgba(125,79,254,.28) !important;"
    "text-shadow:none !important;"
    "opacity:1 !important;"
    "filter:none !important;"
    "mix-blend-mode:normal !important;"
)

CHILD_STYLE = (
    "color:#000000 !important;"
    "-webkit-text-fill-color:#000000 !important;"
    "text-shadow:none !important;"
    "opacity:1 !important;"
    "filter:none !important;"
    "mix-blend-mode:normal !important;"
)

def add_inline_style(tag, style):
    if ' style="' in tag:
        return tag.replace(' style="', f' style="{style}', 1)
    return tag[:-1] + f' style="{style}">'

def force_black_block(match):
    block = match.group(0)

    # Conteneur de la carte.
    end = block.find(">")
    if end >= 0:
        opening = add_inline_style(block[:end + 1], PARENT_STYLE)
        block = opening + block[end + 1:]

    # Descendants susceptibles d'avoir une couleur forcee par l'ancien CSS.
    def child_repl(m):
        return add_inline_style(m.group(0), CHILD_STYLE)

    block = re.sub(
        r"<(?:b|strong|span|p|small|h1|h2|h3|h4|h5|h6)(?:\s[^>]*)?>",
        child_repl,
        block,
        flags=re.IGNORECASE,
    )

    # Le texte brut herite du conteneur noir.
    return block

# Cartes demandees par l'utilisateur.
patterns = [
    r'<div\s+class="[^"]*\baudit-requested-black\b[^"]*"[^>]*>.*?</div>',
    r'<div\s+class="[^"]*\baudit-alert-card\b[^"]*"[^>]*>.*?</div>',
]

for pattern in patterns:
    source = re.sub(
        pattern,
        force_black_block,
        source,
        flags=re.IGNORECASE | re.DOTALL,
    )

# ------------------------------------------------------------
# 2. Feuille finale ajoutee dans le DERNIER style du script
# ------------------------------------------------------------
FINAL_CSS = r"""
/* =========================================================
   V8.5.37 — FORCE BLACK ON LIGHT BUSINESS CARDS
   ========================================================= */

html body .stApp [data-testid="stAppViewContainer"]
.audit-card.audit-requested-black,
html body .stApp [data-testid="stAppViewContainer"]
.audit-info-box.audit-requested-black,
html body .stApp [data-testid="stAppViewContainer"]
.audit-requested-black {
    background:#F8F4FF !important;
    background-color:#F8F4FF !important;
    color:#000000 !important;
    -webkit-text-fill-color:#000000 !important;
    border-color:rgba(125,79,254,.28) !important;
    text-shadow:none !important;
    opacity:1 !important;
    filter:none !important;
    mix-blend-mode:normal !important;
}

html body .stApp [data-testid="stAppViewContainer"]
.audit-requested-black *,
html body .stApp [data-testid="stAppViewContainer"]
.audit-card.audit-requested-black *,
html body .stApp [data-testid="stAppViewContainer"]
.audit-info-box.audit-requested-black * {
    color:#000000 !important;
    -webkit-text-fill-color:#000000 !important;
    text-shadow:none !important;
    opacity:1 !important;
    filter:none !important;
    mix-blend-mode:normal !important;
}

/* Lot selectionne */
html body .stApp .audit-requested-black .audit-badge,
html body .stApp .audit-requested-black .audit-badge *,
html body .stApp .audit-requested-black .badge-low,
html body .stApp .audit-requested-black .badge-low * {
    color:#000000 !important;
    -webkit-text-fill-color:#000000 !important;
    font-weight:800 !important;
}

/* Mission cible / historique / code mission */
html body .stApp .audit-requested-black b,
html body .stApp .audit-requested-black strong,
html body .stApp .audit-requested-black span,
html body .stApp .audit-requested-black p,
html body .stApp .audit-requested-black small {
    color:#000000 !important;
    -webkit-text-fill-color:#000000 !important;
}

/* Cartes de vigilance sur fond clair */
html body .stApp .audit-alert-card,
html body .stApp .audit-alert-card * {
    color:#000000 !important;
    -webkit-text-fill-color:#000000 !important;
    text-shadow:none !important;
    opacity:1 !important;
}

/* La phrase ML demandee precedemment reste rouge. */
.ap-ml-red,
.ap-ml-red * {
    color:#FF4B4B !important;
    -webkit-text-fill-color:#FF4B4B !important;
    font-weight:750 !important;
}
"""

last_style_end = source.rfind("</style>")
if last_style_end >= 0:
    source = (
        source[:last_style_end]
        + FINAL_CSS
        + "\n"
        + source[last_style_end:]
    )

# ------------------------------------------------------------
# 3. Phrase ML en rouge
# ------------------------------------------------------------
ML_SENTENCE = (
    "Les constats historiques deviennent des exemples étiquetés. "
    "La classification prédit Faible / Moyenne / Haute ; "
    "la régression estime un score de criticité entre 0 et 100."
)

# Si la phrase est rendue directement par st.markdown dans la base,
# on l'enveloppe dans un span rouge.
source = source.replace(
    ML_SENTENCE,
    '<span class="ap-ml-red">'
    + ML_SENTENCE
    + '</span>'
)

# ------------------------------------------------------------
# 4. Execution de la V8.5.29 corrigee
# ------------------------------------------------------------
exec(compile(source, str(BASE_FILE), "exec"), globals(), globals())
