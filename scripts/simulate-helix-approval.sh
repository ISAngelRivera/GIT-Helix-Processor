#!/bin/bash
# =============================================================================
# Script para simular el webhook de aprobación de Helix ITSM
# =============================================================================
# Uso:
#   ./scripts/simulate-helix-approval.sh <REQUEST_ID> [APPROVED|REJECTED]
#
# Ejemplo:
#   ./scripts/simulate-helix-approval.sh REQ-accounta-68973-a1b2 APPROVED
#   ./scripts/simulate-helix-approval.sh REQ-accounta-68973-a1b2 REJECTED
#
# Requisitos:
#   - gh CLI instalado y autenticado
#   - Token con permisos para repository_dispatch
# =============================================================================

set -e

REPO="ISAngelRivera/GIT-Helix-Processor"

# Validar argumentos
if [ -z "$1" ]; then
  echo "Error: REQUEST_ID es requerido"
  echo ""
  echo "Uso: $0 <REQUEST_ID> [APPROVED|REJECTED]"
  echo ""
  echo "Ejemplo:"
  echo "  $0 REQ-accounta-68973-a1b2 APPROVED"
  exit 1
fi

REQUEST_ID="$1"
STATUS="${2:-APPROVED}"

# Validar status
if [ "$STATUS" != "APPROVED" ] && [ "$STATUS" != "REJECTED" ]; then
  echo "Error: STATUS debe ser APPROVED o REJECTED"
  exit 1
fi

# Generar CRQ ID
CRQ_ID="CRQ-$(date +%Y%m%d%H%M%S)"

echo "=========================================="
echo "  Simulando Webhook de Helix ITSM"
echo "=========================================="
echo ""
echo "Request ID: $REQUEST_ID"
echo "CRQ ID:     $CRQ_ID"
echo "Status:     $STATUS"
echo "Target:     $REPO"
echo ""

# Enviar repository_dispatch
echo "Enviando webhook..."

gh api "repos/${REPO}/dispatches" \
  -f event_type=helix-approval \
  -f client_payload="{\"crq_id\":\"${CRQ_ID}\",\"status\":\"${STATUS}\",\"request_id\":\"${REQUEST_ID}\"}"

echo ""
echo "Webhook enviado correctamente."
echo ""
echo "El workflow 'On Helix Approval' procesará la solicitud."
echo "Puedes ver el progreso en:"
echo "  https://github.com/${REPO}/actions"
echo ""
