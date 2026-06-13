# TPI-Funcional-2026-Grupo31

> Trabajo Práctico Integrador — Paradigmas y Lenguajes (PyL)  
> FaCENA, Universidad Nacional del Nordeste — 2026  
> **Sistema de Semáforos Inteligentes** en Common Lisp y Haskell

---

## Integrantes

| Nombre y Apellido | Usuario GitHub |
|---|---|
| Milton Nahuel Rodriguez Rivas | [@miltonrodx](https://github.com/miltonrodx) |
| Lautaro Sebastian Quintana Flores | [@lautaroflores31-dot](https://github.com/lautaroflores31-dot) |
| Nestor Javier Nacimiento | [@maverick8585](https://github.com/maverick8585) |
| Juliana Eva Fernandez | [@julindez](https://github.com/julindez) |
| Adolfo Joaquin Jesus Rodriguez | [@joaquinro144-spec](https://github.com/joaquinro144-spec) |

---

## Lenguaje asignado (Fase 3)

**Haskell** — reimplementación de `transicion` y `semaforoTimer`

---

## Entregables

| Entregable | Link |
|---|---|
| 🎥 Video demo (YouTube) | [Ver video](https://www.youtube.com/watch?v=TU9nxIDWvV4) |
| 📄 Informe técnico | [`docs/INFORME.pdf`](docs/INFORME.pdf) |
| ⚖️ Código de Honor | [`docs/HONOR.md`](docs/HONOR.md) |
| 💻 Código Lisp | [`lisp/core.lisp`](lisp/core.lisp) |
| 🔷 Código Haskell | [`comparativa/solucion.hs`](comparativa/solucion.hs) |

---

## Descripción

Sistema de control semafórico implementado bajo el paradigma funcional puro:

- **Funciones puras** — misma entrada, siempre misma salida
- **Inmutabilidad absoluta** — sin `setq`, `setf`, ni variables mutables
- **Sin bucles imperativos** — toda iteración via `mapcar` o recursividad
- **Clasificación taxonómica** — cada función documentada con naturaleza, estrategia e impacto

---

## Estructura del repositorio

```
TPI-Funcional-2026-Grupo31/
├── lisp/
│   └── core.lisp          ← Requerimientos 1-6 + Iteración 2
├── comparativa/
│   └── solucion.hs        ← transicion y semaforoTimer en Haskell
├── docs/
│   ├── INFORME.pdf        ← Informe técnico completo
│   └── HONOR.md           ← Declaración de autoría por integrante
└── README.md
```

---

## Cómo ejecutar

**Requisitos:**
- SBCL (`sudo apt install sbcl`)
- Quicklisp instalado ([quicklisp.org](https://www.quicklisp.org))
- VS Code + extensión Alive (opcional)

**Pasos:**
```lisp
; 1. Cargar dependencias
(ql:quickload :local-time)

; 2. Cargar el sistema
(load "lisp/core.lisp")

; 3. Ejecutar ejemplos de todos los requerimientos
(run-ejemplos)
```

**Para el informe de auditoría (genera archivo .txt):**
```lisp
(informe '((1748000000 rojo verde)
           (1748000100 verde amarillo)
           (1748000200 amarillo rojo)))
```

---

## Estado

| Fase | Estado |
|---|---|
| Fase 1 — Common Lisp (Reqs 1-6) | ✅ Completado |
| Iteración 2 — Intermitencia + Persistencia | ✅ Completado |
| Fase 2 — Quicklisp / local-time | ✅ Completado |
| Fase 3 — Haskell | ✅ Completado |
| Informe PDF | ✅ Completado |
| Video YouTube | ✅ Completado |
| Entrega final | 📅 16 de junio de 2026 |

