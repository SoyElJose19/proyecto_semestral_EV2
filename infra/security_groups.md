# Security Groups - Proyecto Semestral EV2

## 1. SG Frontend (público)
| Regla | Tipo | Puerto | Origen | Propósito |
|-------|------|--------|--------|-----------|
| INGRESS | HTTP | 80 | 0.0.0.0/0 | Acceso web público |
| INGRESS | SSH | 22 | 0.0.0.0/0 | Administración |
| EGRESS | ALL | ALL | 0.0.0.0/0 | Conexión a Backend |

## 2. SG Backend (privado)
| Regla | Tipo | Puerto | Origen | Propósito |
|-------|------|--------|--------|-----------|
| INGRESS | TCP | 8081-8082 | SG Frontend | APIs Despachos y Ventas |
| EGRESS | ALL | ALL | 0.0.0.0/0 | Conexión a BD |

## Justificación (IE7):
- Solo el Frontend es accesible desde Internet
- Los Backends están en subred privada
- La comunicación Front→Back está restringida por Security Groups
