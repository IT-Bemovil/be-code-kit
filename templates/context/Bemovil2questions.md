# Bemovil 2.0 — Preguntas Pendientes de Contexto

> **Propósito**: Preguntas clave que no se pueden inferir del código. Las respuestas complementarán los archivos de contexto (business_logic.md, guidelines.md, user_context.md) para que el agente AI tenga información completa en cada tarea.
>
> **Instrucciones**: Respondé cada pregunta con la mayor precisión posible. No hace falta que sean respuestas largas — con datos concretos alcanza. Cuando respondás una pregunta, la marco como resuelta y actualizo el archivo de contexto correspondiente.

---

## Preguntas Pendientes (sin respuesta)

### Sirse / Bridge

1. **¿Cuál es el formato exacto de la comunicación SOAP con Sirse?** ¿Tenés un WSDL de referencia o ejemplos de request/response?

2. **¿Cuál es la cola de prioridad de productos para la migración Bridge?** ¿Qué productos ya están migrados y cuáles faltan? (Referencia: Linear label MigracionBepay)

### Compliance / Regulaciones

3. **¿Qué regulaciones específicas deben cumplir?** ¿SFC (Superintendencia Financiera)? ¿Ley de Habeas Data? ¿PCI-DSS para pagos? Detalle de cada una y cómo impacta al código.

### Métricas / Volumen

~~4. **¿Cuál es el volumen transaccional actual?**~~ → Resuelto via DB queries (abril 2026)

### Davibank

5. **¿Por qué exactamente el microservicio de Davibank tiene su propio servidor WebSocket separado?** ¿Es por el manejo de puertos del proxy? ¿Hay detalles técnicos adicionales?

### Mobile App

6. **¿Cuál es el nombre del repo de la app React Native?** ¿Cuándo estará disponible para agregarlo al monorepo?

### BeOne

7. **¿Cuáles son los requerimientos prioritarios del Excel de BeOne?** → Pendiente de análisis del archivo `context/BeOne - Requerimientos.xlsx`

### Otros países

8. **¿Cuál es el propósito de los registros de Venezuela (countryId 12) y México (countryId 13)?** En producción hay 1 business de cada país — ¿son tests, pilotos, o algo planificado?

---

## Preguntas Resueltas (movidas a contexto)

| # | Pregunta | Resolución | Destino |
|---|----------|------------|---------|
| 1 | Balance types (balanceMarketing, balanceDebt, balanceExternalDebt) | balanceMarketing=DEPRECATED (0 uso), balanceDebt/balanceExternalDebt=barely used (3-8 businesses) | `business_logic.md` → Balance System |
| 7 | Estructura JSON options/providerOptions | Explorado vía DB queries — JSON columns con config flexible por producto | `business_logic.md` → Product Architecture |
| 8 | activationProcess values | Explorado vía DB queries — vinculado a ProductActivation y risk department | `business_logic.md` → Commission System |
| 4 | Volumen transaccional actual | ~346K txn/día promedio, pico 479K, horario 6am-9pm, peak 10am | `business_logic.md` → Transactional Volume |

---

*Última actualización: 2026-04-27*
