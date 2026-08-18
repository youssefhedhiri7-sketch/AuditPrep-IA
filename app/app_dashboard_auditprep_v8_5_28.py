# ============================================================
# AuditPrep IA - V8.5.31
# Correctif final de lisibilite / contraste sur surfaces claires et sombres
# Base metier : V8.5.28 (logique fonctionnelle inchangee)
#
# IMPORTANT : conserver app_dashboard_auditprep_v8_5_28.py dans le meme dossier.
#
# Lancement PowerShell :
#   cd "C:\PFE Omar\AuditPrep-IA"
#   conda run -n auditprep python -m streamlit run "app\app_dashboard_auditprep_v8_5_31.py"
# ============================================================

from pathlib import Path

BASE_FILE = Path(__file__).with_name("app_dashboard_auditprep_v8_5_28.py")

if not BASE_FILE.exists():
    raise FileNotFoundError(
        f"Fichier de base introuvable : {BASE_FILE}\n"
        "Place app_dashboard_auditprep_v8_5_28.py dans le meme dossier que cette V8.5.31."
    )

source = BASE_FILE.read_text(encoding="utf-8")

# Cette couche est volontairement injectee APRES tous les anciens styles.
# Elle ne touche pas a la logique Python / SQL / ML : seulement a la lisibilite.
FINAL_CONTRAST_CSS = r"""

/* =========================================================
   V8.5.31 — CONTRASTE FINAL CLAIR / SOMBRE
   Objectif : jamais de texte blanc sur fond clair ni de texte sombre
   sur fond violet/noir. Les couleurs sont liees a la SURFACE,
   pas au theme du navigateur, pour rester fiables dans Streamlit.
   ========================================================= */

:root {
    --ap30-dark-bg: #181319;
    --ap30-dark-panel: #24182e;
    --ap30-dark-panel-2: #2c1c3a;
    --ap30-dark-text: #f8f5fb;
    --ap30-dark-muted: #ddd4e6;

    --ap30-light-bg: #f8f4ff;
    --ap30-light-bg-2: #f2ecfa;
    --ap30-light-text: #241c2d;
    --ap30-light-muted: #51465c;

    --ap30-border-dark: rgba(255,255,255,.16);
    --ap30-border-light: rgba(79,55,110,.18);
    --ap30-violet: #7d4ffe;
}

/* ---------------------------------------------------------
   1) FOND SOMBRE : texte clair par defaut
   --------------------------------------------------------- */
html,
body,
.stApp,
[data-testid="stAppViewContainer"] {
    color-scheme: dark;
}

[data-testid="stAppViewContainer"],
[data-testid="stAppViewContainer"] > .main,
.main .block-container {
    color: var(--ap30-dark-text) !important;
}

.main h1,
.main h2,
.main h3,
.main h4,
.main h5,
.main h6,
.main > div > div > p,
.main [data-testid="stMarkdownContainer"] > p,
.main [data-testid="stMarkdownContainer"] > ul,
.main [data-testid="stMarkdownContainer"] > ol,
.audit-caption-white {
    color: var(--ap30-dark-text) !important;
    -webkit-text-fill-color: currentColor !important;
    opacity: 1 !important;
}

[data-testid="stCaptionContainer"],
.stCaption,
.main small {
    color: var(--ap30-dark-muted) !important;
    opacity: 1 !important;
}

/* ---------------------------------------------------------
   2) SURFACES CLAIRES : TOUJOURS texte sombre
   C'est le correctif principal visible dans les captures.
   --------------------------------------------------------- */
.audit-card,
.audit-info-box,
.audit-warning,
.audit-warning-box,
.audit-success,
.audit-success-box,
.audit-alert-card,
.audit-user-chip,
.audit-light-surface,
.audit-white-card,
.audit-requested-black {
    background-color: var(--ap30-light-bg) !important;
    color: var(--ap30-light-text) !important;
    border-color: var(--ap30-border-light) !important;
    text-shadow: none !important;
}

.audit-info-box,
.audit-success,
.audit-success-box {
    background: var(--ap30-light-bg-2) !important;
}

.audit-warning,
.audit-warning-box {
    background: #fff0f7 !important;
}

.audit-alert-card {
    background: #fbf8ff !important;
}

/* Tous les descendants des cartes claires deviennent sombres. */
.audit-card *,
.audit-info-box *,
.audit-warning *,
.audit-warning-box *,
.audit-success *,
.audit-success-box *,
.audit-alert-card *,
.audit-user-chip *,
.audit-light-surface *,
.audit-white-card *,
.audit-requested-black * {
    color: var(--ap30-light-text) !important;
    -webkit-text-fill-color: var(--ap30-light-text) !important;
    text-shadow: none !important;
    opacity: 1 !important;
}

/* Liens dans une carte claire */
.audit-card a,
.audit-info-box a,
.audit-warning a,
.audit-success a,
.audit-alert-card a,
.audit-requested-black a {
    color: #5130b5 !important;
    -webkit-text-fill-color: #5130b5 !important;
}

/* Badge lot selectionne : lisible sur fond vert pale. */
.audit-card .audit-badge,
.audit-requested-black .audit-badge,
.audit-alert-card .audit-badge {
    color: #1d2830 !important;
    -webkit-text-fill-color: #1d2830 !important;
    font-weight: 800 !important;
}

/* ---------------------------------------------------------
   3) SURFACES SOMBRES / VIOLETTES : TOUJOURS texte clair
   --------------------------------------------------------- */
.audit-topbar,
.audit-topbar *,
.audit-hero,
.audit-hero *,
.ap-hero,
.ap-hero *,
.audit-section-head,
.audit-section-head *,
[data-testid="stMetric"],
[data-testid="stMetric"] *,
.audit-mini-card,
.audit-mini-card *,
.ap-card,
.ap-card *,
.audit-note,
.audit-note * {
    color: var(--ap30-dark-text) !important;
    -webkit-text-fill-color: var(--ap30-dark-text) !important;
    text-shadow: none !important;
    opacity: 1 !important;
}

/* Les cartes KPI restent des cartes sombres vitrées. */
.audit-mini-card,
.ap-card,
.audit-note,
[data-testid="stMetric"] {
    background: linear-gradient(135deg, rgba(255,255,255,.10), rgba(255,255,255,.045)) !important;
    border-color: var(--ap30-border-dark) !important;
}

.audit-kpi-label,
[data-testid="stMetricLabel"],
[data-testid="stMetricLabel"] * {
    color: #e8e0f0 !important;
    -webkit-text-fill-color: #e8e0f0 !important;
    opacity: 1 !important;
}

.audit-kpi-value,
.audit-big-number,
[data-testid="stMetricValue"],
[data-testid="stMetricValue"] * {
    color: #ffffff !important;
    -webkit-text-fill-color: #ffffff !important;
}

/* Titres de sections violets. */
.audit-section-head h1,
.audit-section-head h2,
.audit-section-head h3,
.audit-section-head a {
    color: #ffffff !important;
    -webkit-text-fill-color: #ffffff !important;
}

/* ---------------------------------------------------------
   4) BLOCS PRECISEMENT VUS COMME ILLISIBLES DANS LES CAPTURES
   --------------------------------------------------------- */
/* Mode demonstration / dernier lot / lot selectionne / code mission */
.audit-card.audit-requested-black,
.audit-card.audit-requested-black * {
    color: #201827 !important;
    -webkit-text-fill-color: #201827 !important;
}

/* Lecture du lot selectionne */
.audit-info-box.audit-requested-black,
.audit-info-box.audit-requested-black * {
    color: #201827 !important;
    -webkit-text-fill-color: #201827 !important;
}

/* Les titres normaux sur le fond violet restent blancs. */
.main h2:not(.audit-requested-black-heading),
.main h3:not(.audit-requested-black-heading) {
    color: #ffffff !important;
    -webkit-text-fill-color: #ffffff !important;
}

/* Si ce titre se trouve DANS une surface claire, il redevient sombre. */
.audit-card .audit-requested-black-heading,
.audit-info-box .audit-requested-black-heading,
.audit-light-surface .audit-requested-black-heading,
.audit-white-card .audit-requested-black-heading {
    color: var(--ap30-light-text) !important;
    -webkit-text-fill-color: var(--ap30-light-text) !important;
}

/* ---------------------------------------------------------
   5) CHAMPS / FORMULAIRES : fond sombre + texte blanc
   --------------------------------------------------------- */
[data-baseweb="input"] > div,
[data-baseweb="textarea"] > div,
.stTextInput input,
.stNumberInput input,
.stTextArea textarea,
.stDateInput input,
.stTimeInput input {
    background: #211b28 !important;
    color: #ffffff !important;
    border-color: rgba(196,159,255,.32) !important;
}

input,
textarea,
[data-baseweb="input"] input,
[data-baseweb="textarea"] textarea,
.stTextInput input,
.stNumberInput input,
.stTextArea textarea,
.stDateInput input,
.stTimeInput input {
    color: #ffffff !important;
    -webkit-text-fill-color: #ffffff !important;
    caret-color: #ffffff !important;
    opacity: 1 !important;
}

input::placeholder,
textarea::placeholder {
    color: #cfc5d8 !important;
    -webkit-text-fill-color: #cfc5d8 !important;
    opacity: 1 !important;
}

/* Labels de formulaire sur fond sombre */
label,
[data-testid="stWidgetLabel"],
[data-testid="stWidgetLabel"] *,
.stSelectbox label,
.stMultiSelect label,
.stTextInput label,
.stNumberInput label,
.stTextArea label,
.stDateInput label,
.stRadio label,
.stCheckbox label,
.stToggle label {
    color: #f5f0f8 !important;
    -webkit-text-fill-color: #f5f0f8 !important;
    opacity: 1 !important;
}

/* ---------------------------------------------------------
   6) SELECTBOX / MENUS : fond sombre, texte blanc
   --------------------------------------------------------- */
[data-baseweb="select"] > div {
    background: #211b28 !important;
    color: #ffffff !important;
    border-color: rgba(196,159,255,.32) !important;
}

[data-baseweb="select"] span,
[data-baseweb="select"] div,
[data-baseweb="select"] input {
    color: #ffffff !important;
    -webkit-text-fill-color: #ffffff !important;
}

[data-baseweb="popover"],
[data-baseweb="menu"],
[role="listbox"] {
    background: #211b28 !important;
    border-color: rgba(255,255,255,.14) !important;
}

[role="option"],
[role="option"] *,
[data-baseweb="menu"] *,
[data-baseweb="popover"] * {
    color: #ffffff !important;
    -webkit-text-fill-color: #ffffff !important;
}

[role="option"]:hover,
[role="option"][aria-selected="true"] {
    background: rgba(125,79,254,.34) !important;
    color: #ffffff !important;
}

/* ---------------------------------------------------------
   7) BOUTONS : contraste explicite, y compris DESACTIVES
   --------------------------------------------------------- */
.stButton > button,
[data-testid="stFormSubmitButton"] > button {
    color: #ffffff !important;
    -webkit-text-fill-color: #ffffff !important;
    font-weight: 750 !important;
    opacity: 1 !important;
}

.stDownloadButton > button {
    background: #f8f4ff !important;
    color: #241c2d !important;
    -webkit-text-fill-color: #241c2d !important;
    border-color: rgba(79,55,110,.18) !important;
    font-weight: 700 !important;
    opacity: 1 !important;
}

.stDownloadButton > button * {
    color: #241c2d !important;
    -webkit-text-fill-color: #241c2d !important;
}

.stButton > button:disabled,
.stDownloadButton > button:disabled,
[data-testid="stFormSubmitButton"] > button:disabled,
button[disabled] {
    opacity: 1 !important;
    background: #d9d2e4 !important;
    color: #2b2233 !important;
    -webkit-text-fill-color: #2b2233 !important;
    border: 1px solid #b8adc3 !important;
    box-shadow: none !important;
}

.stButton > button:disabled *,
.stDownloadButton > button:disabled *,
[data-testid="stFormSubmitButton"] > button:disabled *,
button[disabled] * {
    color: #2b2233 !important;
    -webkit-text-fill-color: #2b2233 !important;
}

/* ---------------------------------------------------------
   8) ONGLETS / EXPANDERS
   --------------------------------------------------------- */
[data-baseweb="tab"],
[data-baseweb="tab"] *,
button[role="tab"],
button[role="tab"] * {
    color: #e5dcec !important;
    -webkit-text-fill-color: #e5dcec !important;
    opacity: 1 !important;
}

[data-baseweb="tab"][aria-selected="true"],
[data-baseweb="tab"][aria-selected="true"] *,
button[role="tab"][aria-selected="true"],
button[role="tab"][aria-selected="true"] * {
    color: #ffffff !important;
    -webkit-text-fill-color: #ffffff !important;
    font-weight: 800 !important;
}

[data-testid="stExpander"] summary,
[data-testid="stExpander"] summary *,
[data-testid="stExpander"] details,
[data-testid="stExpander"] details * {
    color: #f8f4fc !important;
    -webkit-text-fill-color: #f8f4fc !important;
    opacity: 1 !important;
}

/* ---------------------------------------------------------
   9) TABLEAUX / DATAFRAMES : surface sombre et texte clair
   --------------------------------------------------------- */
[data-testid="stDataFrame"],
[data-testid="stTable"] {
    background: #111319 !important;
    border-color: rgba(255,255,255,.16) !important;
}

[data-testid="stDataFrame"] *,
[data-testid="stTable"] *,
[data-testid="stDataFrame"] [role="columnheader"],
[data-testid="stDataFrame"] [role="gridcell"],
[data-testid="stTable"] th,
[data-testid="stTable"] td {
    color: #f7f2fa !important;
    -webkit-text-fill-color: #f7f2fa !important;
    opacity: 1 !important;
}

/* ---------------------------------------------------------
   10) ALERTES STREAMLIT / INFOBULLES
   --------------------------------------------------------- */
[data-testid="stAlert"],
[data-testid="stAlert"] * {
    color: #ffffff !important;
    -webkit-text-fill-color: #ffffff !important;
    opacity: 1 !important;
}

/* Les infobulles restent volontairement claires. */
[role="tooltip"],
[data-baseweb="tooltip"] {
    background: #ffffff !important;
    color: #211a29 !important;
    border: 1px solid rgba(79,55,110,.20) !important;
}

[role="tooltip"] *,
[data-baseweb="tooltip"] * {
    color: #211a29 !important;
    -webkit-text-fill-color: #211a29 !important;
}

/* ---------------------------------------------------------
   11) SIDEBAR
   --------------------------------------------------------- */
[data-testid="stSidebar"],
[data-testid="stSidebar"] .block-container {
    color: var(--ap30-dark-text) !important;
}

[data-testid="stSidebar"] h1,
[data-testid="stSidebar"] h2,
[data-testid="stSidebar"] h3,
[data-testid="stSidebar"] p,
[data-testid="stSidebar"] label,
[data-testid="stSidebar"] span,
[data-testid="stSidebar"] small {
    color: var(--ap30-dark-text) !important;
    -webkit-text-fill-color: var(--ap30-dark-text) !important;
    opacity: 1 !important;
}

/* Carte utilisateur claire dans la sidebar */
[data-testid="stSidebar"] .audit-user-chip,
[data-testid="stSidebar"] .audit-user-chip * {
    color: var(--ap30-light-text) !important;
    -webkit-text-fill-color: var(--ap30-light-text) !important;
}

/* ---------------------------------------------------------
   12) SECURITE MODE CLAIR / MODE SOMBRE DU NAVIGATEUR
   Les memes contrastes sont conserves dans les deux cas.
   --------------------------------------------------------- */
@media (prefers-color-scheme: light) {
    .audit-card *,
    .audit-info-box *,
    .audit-warning *,
    .audit-warning-box *,
    .audit-success *,
    .audit-success-box *,
    .audit-alert-card *,
    .audit-user-chip *,
    .audit-requested-black * {
        color: var(--ap30-light-text) !important;
        -webkit-text-fill-color: var(--ap30-light-text) !important;
    }

    .audit-section-head *,
    .audit-topbar *,
    .audit-hero *,
    .audit-mini-card *,
    .ap-card *,
    .audit-note * {
        color: var(--ap30-dark-text) !important;
        -webkit-text-fill-color: var(--ap30-dark-text) !important;
    }
}

@media (prefers-color-scheme: dark) {
    .audit-card *,
    .audit-info-box *,
    .audit-warning *,
    .audit-warning-box *,
    .audit-success *,
    .audit-success-box *,
    .audit-alert-card *,
    .audit-user-chip *,
    .audit-requested-black * {
        color: var(--ap30-light-text) !important;
        -webkit-text-fill-color: var(--ap30-light-text) !important;
    }

    .audit-section-head *,
    .audit-topbar *,
    .audit-hero *,
    .audit-mini-card *,
    .ap-card *,
    .audit-note * {
        color: var(--ap30-dark-text) !important;
        -webkit-text-fill-color: var(--ap30-dark-text) !important;
    }
}
"""

# Injection dans le DERNIER bloc <style> de la V8.5.28 :
# notre CSS arrive donc apres tous les overrides V8.5.27/28.
last_style_end = source.rfind("</style>")
if last_style_end == -1:
    raise RuntimeError("Impossible de localiser le dernier bloc CSS </style> dans la V8.5.28.")

source = source[:last_style_end] + FINAL_CONTRAST_CSS + "\n" + source[last_style_end:]

# ============================================================
# V8.5.31 — LIGNE ML DEMANDEE EN ROUGE
# ============================================================
# Le texte vise uniquement la phrase visible sous "Étape 1".
# On intercepte son rendu Streamlit sans toucher a la logique ML.

import html as _html
import streamlit as _st

_AP31_TARGET = (
    "Les constats historiques deviennent des exemples étiquetés. "
    "La classification prédit Faible / Moyenne / Haute ; "
    "la régression estime un score de criticité entre 0 et 100."
)

_AP31_RED_STYLE = (
    '<span style="color:#FF4B4B !important;'
    '-webkit-text-fill-color:#FF4B4B !important;'
    'font-weight:750 !important;">{}</span>'
)

_ap31_original_markdown = _st.markdown
_ap31_original_write = _st.write

def _ap31_markdown(body, *args, **kwargs):
    if isinstance(body, str) and _AP31_TARGET in body:
        body = body.replace(
            _AP31_TARGET,
            _AP31_RED_STYLE.format(_html.escape(_AP31_TARGET))
        )
        kwargs["unsafe_allow_html"] = True
    return _ap31_original_markdown(body, *args, **kwargs)

def _ap31_write(*args, **kwargs):
    if len(args) == 1 and isinstance(args[0], str) and _AP31_TARGET in args[0]:
        rendered = args[0].replace(
            _AP31_TARGET,
            _AP31_RED_STYLE.format(_html.escape(_AP31_TARGET))
        )
        return _ap31_original_markdown(rendered, unsafe_allow_html=True)
    return _ap31_original_write(*args, **kwargs)

_st.markdown = _ap31_markdown
_st.write = _ap31_write

# Execution de la base metier avec la couche de contraste finale.
exec(compile(source, str(BASE_FILE), "exec"), globals(), globals())
