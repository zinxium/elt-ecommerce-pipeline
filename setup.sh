#!/usr/bin/env bash
# ============================================
# ELT E-Commerce Pipeline - Script d'installation
# Python + dbt + Snowflake + BigQuery
# ============================================
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}  ELT E-Commerce Pipeline - Installation${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# ── 1. Python ────────────────────────────────────────────────────────────────
echo -e "${YELLOW}[1/4] Vérification de Python...${NC}"
if command -v python3 &>/dev/null; then
    PYTHON=python3
elif command -v python &>/dev/null; then
    PYTHON=python
else
    echo -e "${RED}Python n'est pas installé. Installez Python 3.10+ depuis https://www.python.org/${NC}"
    exit 1
fi
PY_VERSION=$($PYTHON --version 2>&1)
echo -e "${GREEN}  $PY_VERSION${NC}"

# ── 2. Environnement virtuel ────────────────────────────────────────────────
echo -e "${YELLOW}[2/4] Création de l'environnement virtuel...${NC}"
if [ ! -d "venv" ]; then
    $PYTHON -m venv venv
    echo -e "${GREEN}  venv créé${NC}"
else
    echo -e "${GREEN}  venv existe déjà${NC}"
fi

if [ -f "venv/Scripts/activate" ]; then
    source venv/Scripts/activate
elif [ -f "venv/bin/activate" ]; then
    source venv/bin/activate
fi
echo -e "${GREEN}  venv activé${NC}"

# ── 3. Dépendances ──────────────────────────────────────────────────────────
echo -e "${YELLOW}[3/4] Installation des dépendances Python...${NC}"
pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet
echo -e "${GREEN}  Dépendances installées:${NC}"
echo "    - snowflake-connector-python"
echo "    - google-cloud-bigquery"
echo "    - pandas, pyarrow"
echo "    - python-dotenv"

# ── 4. Environnement ────────────────────────────────────────────────────────
echo -e "${YELLOW}[4/4] Configuration de l'environnement...${NC}"
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}  .env créé depuis .env.example${NC}"
    fi
    echo -e "${YELLOW}  IMPORTANT: Renseignez vos credentials dans .env:${NC}"
    echo "    - Snowflake: SF_ACCOUNT, SF_USER, SF_PASSWORD, SF_WAREHOUSE, SF_DATABASE, SF_SCHEMA"
    echo "    - BigQuery:  BIGQUERY_PROJECT_ID, BIGQUERY_DATASET, GOOGLE_APPLICATION_CREDENTIALS"
else
    echo -e "${GREEN}  .env existe déjà${NC}"
fi

echo ""
echo -e "${GREEN}Installation terminée !${NC}"
echo ""
echo -e "Activer le venv:     ${CYAN}source venv/Scripts/activate${NC} (ou venv/bin/activate)"
echo -e "Tester connexion:    ${CYAN}python test_connexion.py${NC}"
echo -e "Lancer le pipeline:  ${CYAN}python scripts/<script_name>.py${NC}"
echo -e "Lancer dbt:          ${CYAN}dbt run${NC}"
