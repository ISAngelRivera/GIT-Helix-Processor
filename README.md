# GIT-Helix-Processor

Procesador genérico vendor-agnostic para integración Git ↔ Helix ITSM.

## Arquitectura GitOps (PRs con Datos Planos)

```
┌─────────────────────┐     ┌─────────────────────┐
│   WSO2-Processor    │     │  Apigee-Processor   │
│   Kong-Processor    │ ... │  Custom-Processor   │
└─────────┬───────────┘     └─────────┬───────────┘
          │                           │
          │  PR con datos planos      │
          ▼                           ▼
┌─────────────────────────────────────────────────┐
│              GIT-Helix-Processor                │  ← Este repositorio
│                                                 │
│  1. Recibe PRs en requests/                     │
│  2. Valida (linters, Spectral)                  │
│  3. Crea CRQ en Helix                           │
│  4. Almacena API en apis/                       │
└─────────────────────────────────────────────────┘
```

## Estructura de Directorios

```
GIT-Helix-Processor/
├── .github/workflows/
│   └── on-request-pr.yml    # Procesa PRs de registro
├── requests/                 # PRs llegan aquí (temporal)
│   └── {request-id}/
│       ├── request.yaml     # Metadatos
│       ├── api.yaml         # Definición API
│       ├── swagger.yaml     # OpenAPI spec
│       └── params.yaml      # Config entorno
├── apis/                     # Almacenamiento final
│   └── {api-name}/
│       └── v{version}/
│           ├── api.yaml
│           └── swagger.yaml
└── README.md
```

## Workflows Disponibles

| Workflow | Trigger | Descripción | Estado |
|----------|---------|-------------|--------|
| `on-request-pr.yml` | PR to requests/ | Valida, crea CRQ, registra API | MVP |
| `promote-api-nft.yml` | Manual | Promociona API a NFT | Pendiente |
| `promote-api-pro.yml` | Manual | Promociona API a PRO | Pendiente |

### on-request-pr.yml

Se activa cuando una PR modifica `requests/**`.

**Jobs**:
1. **validate**: Ejecuta linters y validaciones
   - Verifica archivos requeridos
   - Ejecuta Spectral para OpenAPI
   - Comenta resultado en la PR

2. **create-crq**: Crea ticket en Helix ITSM
   - Genera CRQ con detalles de la API
   - Notifica en la PR

3. **register-api**: Registra la API
   - Espera aprobación de CRQ
   - Mueve archivos a ubicación final
   - Marca PR como lista para merge

## Formato de Request (Datos Planos)

### request.yaml
```yaml
action: register-uat
request_id: 2024-12-04-pizzaapi-v1-0-0-uat
timestamp: 2024-12-04T10:30:00Z

source:
  system: wso2          # o "apigee", "kong", etc.
  processor: WSO2-Processor
  run_id: "12345"

api:
  id: "abc-123"
  name: PizzaAPI
  version: 1.0.0
  context: /pizza

user:
  id: usuario@empresa.com
```

### api.yaml
Definición de la API exportada del vendor (formato nativo o estándar).

### swagger.yaml
OpenAPI specification de la API.

## Configuración

### Secrets requeridos

| Secret | Descripción |
|--------|-------------|
| `HELIX_API_URL` | URL de la API de Helix ITSM |
| `HELIX_TOKEN` | Token de autenticación para Helix |

### Labels automáticos

El workflow añade labels a las PRs:
- `ready-to-merge`: Validación y CRQ completados
- `uat-registered`: API registrada en UAT

## Principios de Diseño

1. **Vendor-agnostic**: No conoce WSO2, Apigee, Kong, etc.
2. **PRs como contrato**: Todo llega como PR con datos planos
3. **Stateless**: Todo estado está en Git, PRs, o Helix
4. **Idempotente**: Ejecutar dos veces produce el mismo resultado
5. **Observable**: Logs claros, comentarios en PRs, trazabilidad completa
