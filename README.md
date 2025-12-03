# GIT-Helix-Processor

Orquestador central de operaciones Git y (futuro) integración con Helix ITSM. Este repositorio es **vendor-agnostic**: no conoce ni depende de WSO2, Apigee, ni ningún API Manager específico.

## Responsabilidades

- Recibir payload estándar desde cualquier `[Vendor]-Processor`
- Gestionar ramas efímeras en repositorios de dominio
- Realizar commits y merges de APIs
- (Futuro) Crear tickets en Helix para aprobaciones CAB
- (Futuro) Polling de aprobaciones y auto-merge

## Flujo MVP (Registro UAT)

```
[Vendor]-Processor
       │
       ▼ (payload estándar)
┌─────────────────────┐
│  register-api-uat   │  ◄── Este repo
│      workflow       │
└─────────────────────┘
       │
       ▼
┌─────────────────────┐
│  Repo Dominio       │
│  (Informatica-      │
│   DevOps)           │
└─────────────────────┘
```

## Payload Estándar de Entrada

```json
{
  "action": "register-uat",
  "api": {
    "name": "PizzaAPI",
    "version": "1.0.0",
    "domain": "Informatica",
    "subdomain": "DevOps"
  },
  "artifact": {
    "zip_base64": "...",
    "source": "wso2"
  },
  "user": {
    "id": "usuario",
    "email": "usuario@example.com"
  },
  "timestamp": "2025-01-15T10:30:00Z"
}
```

## Workflows Disponibles

| Workflow | Descripción | Estado |
|----------|-------------|--------|
| `register-api-uat.yml` | Registra API en entorno UAT | MVP |
| `promote-api-nft.yml` | Promociona API a NFT | Pendiente |
| `promote-api-pro.yml` | Promociona API a PRO | Pendiente |
| `poll-helix-approvals.yml` | Consulta aprobaciones Helix | Pendiente |

## Custom Actions (Futuras)

| Action | Descripción |
|--------|-------------|
| `kill-switch` | Cancela flujos anteriores de la misma API |
| `create-timestamped-branch` | Crea rama efímera con timestamp |
| `helix-create-ticket` | Crea ticket en Helix |
| `merge-last-write-wins` | Merge con estrategia "theirs" |

## Configuración

### Secrets requeridos

| Secret | Descripción |
|--------|-------------|
| `GIT_BOT_TOKEN` | PAT para operaciones Git en repos de dominio |
| `GIT_BOT_USERNAME` | Username del bot |
| `GIT_BOT_EMAIL` | Email del bot |
| `HELIX_API_URL` | (Futuro) URL del API de Helix |
| `HELIX_API_TOKEN` | (Futuro) Token de Helix |

## Principios de Diseño

1. **Vendor-agnostic**: No importa de dónde venga el payload
2. **Stateless**: Todo estado está en Git, GitHub PRs, o Helix
3. **Idempotente**: Ejecutar dos veces produce el mismo resultado
4. **Observable**: Logs claros, resúmenes en GitHub, trazabilidad completa
