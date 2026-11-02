# Cooperativa Digital — Espacio Escolar de Gestión Colaborativa

Aplicación web interactiva desarrollada en **Vue 3 (`.vue`)** y **JavaScript puro (`.js`)** con soporte híbrido para **Supabase (PostgreSQL)**, diseñada para la **Cooperativa Escolar de Soluciones Digitales y Tecnológicas (7.° Año Técnica — Ciclo Lectivo 2026)**.

## Estructura del Proyecto (Solo `.vue`, `.js`, `.css` y `.sql`)

```text
Cooperativa_Souluciones/
├── .env.example                                  # Plantilla de variables públicas de Supabase
├── index.html                                    # Punto de entrada HTML5
├── package.json                                  # Dependencias (Vue 3, Vue Router 4, Supabase JS, Lucide Vue)
├── vite.config.js                                # Configuración de Vite + @vitejs/plugin-vue
├── supabase/
│   └── schema_and_seed.sql                       # Script SQL reproducible (10 tablas, PK/FK, Triggers y Seed)
└── src/
    ├── main.js                                   # Inicialización de Vue 3 y Vue Router
    ├── App.vue                                   # Componente raíz
    ├── styles.css                                # Sistema de diseño visual en CSS puro
    ├── router/
    │   └── index.js                              # Configuración de rutas en JavaScript
    ├── lib/
    │   └── supabase.js                           # Cliente @supabase/supabase-js y funciones híbridas
    ├── data/
    │   └── cooperativaModels.js                  # 8 roles cooperativos, datos de prueba y matriz de persistencia
    ├── views/
    │   └── HomeView.vue                          # Vista principal (Inicio, Solicitudes, Proyectos, Comisiones, Actas, KPIs, Diseño)
    └── components/
        ├── KPITrackingDashboard.vue              # Tablero de Seguimiento Balanced Scorecard (TEUP, IASS, PDFT, IPEC)
        └── SystemDesignAndSupabasePanel.vue      # Panel interactivo de Diseño del Sistema y Conexión a Supabase
```

## Cómo ejecutar el proyecto localmente

```bash
npm install
npm run dev
```

## Cómo conectar tu base de datos en Supabase

1. Creá un proyecto en [supabase.com](https://supabase.com).
2. Abrí **SQL Editor -> New Query**, pegá el contenido completo de `supabase/schema_and_seed.sql` y ejecutalo (**Run**).
3. Copiá `.env.example` a `.env` y completá `VITE_SUPABASE_URL` y `VITE_SUPABASE_ANON_KEY` (nunca incluyas claves privadas `service_role` en el frontend).
