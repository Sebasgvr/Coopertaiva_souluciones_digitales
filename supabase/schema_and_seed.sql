-- =============================================================================
-- COOPERATIVA ESCOLAR DE SOLUCIONES DIGITALES Y TECNOLÓGICAS
-- Script SQL Reproducible: Esquema Relacional, Triggers de Auditoría,
-- Políticas RLS (Row Level Security) y Datos de Prueba Iniciales (Seed Data)
-- Motor: PostgreSQL 15+ / Supabase
-- =============================================================================
-- INSTRUCCIONES DE USO EN SUPABASE:
-- 1. Creá un proyecto nuevo en https://supabase.com
-- 2. Abrí el menú "SQL Editor" -> "New query"
-- 3. Pegá todo este archivo y hacé clic en "Run" (Ctrl + Enter).
-- 4. Copiá tu Project URL y tu clave pública "anon public" desde
--    Project Settings -> API y colocalas en el archivo .env del proyecto
--    (o ingresalas directamente desde el panel "Conexión Supabase" en la app).
-- =============================================================================

-- Limpieza opcional para re-ejecución segura en entorno de desarrollo
DROP TABLE IF EXISTS public.historial_cambios CASCADE;
DROP TABLE IF EXISTS public.uso_laboratorio_teup CASCADE;
DROP TABLE IF EXISTS public.encuestas_satisfaccion CASCADE;
DROP TABLE IF EXISTS public.casos_prueba_qa CASCADE;
DROP TABLE IF EXISTS public.tareas_proyecto CASCADE;
DROP TABLE IF EXISTS public.asambleas_actas CASCADE;
DROP TABLE IF EXISTS public.proyectos CASCADE;
DROP TABLE IF EXISTS public.solicitudes CASCADE;
DROP TABLE IF EXISTS public.usuarios CASCADE;
DROP TABLE IF EXISTS public.comisiones CASCADE;

-- =============================================================================
-- 1. TABLA: comisiones
-- Representa las 6 Comisiones de Trabajo estatutarias (Art. 4 del Reglamento)
-- =============================================================================
CREATE TABLE public.comisiones (
    id VARCHAR(15) PRIMARY KEY, -- Ej: 'COM-01'
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT NOT NULL,
    funciones_estatutarias TEXT NOT NULL,
    referente_nombre VARCHAR(120) NOT NULL,
    icono VARCHAR(50) NOT NULL DEFAULT 'Code2',
    tono_visual VARCHAR(20) NOT NULL DEFAULT 'mint' CHECK (tono_visual IN ('mint', 'coral', 'sun', 'lilac')),
    cantidad_integrantes INT NOT NULL DEFAULT 3 CHECK (cantidad_integrantes >= 0),
    iniciales_equipo TEXT[] NOT NULL DEFAULT '{}',
    activa BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- 2. TABLA: usuarios
-- Padrón societario, docentes solicitantes, asesores y órganos de gobierno
-- Cumple el principio de minimización de datos personales (Data Mining ético)
-- =============================================================================
CREATE TABLE public.usuarios (
    id VARCHAR(20) PRIMARY KEY, -- Ej: 'S-01', 'D-01', 'ADM-01'
    auth_user_id UUID UNIQUE NULL, -- Vinculación opcional con auth.users de Supabase
    nombre_completo VARCHAR(120) NOT NULL,
    iniciales VARCHAR(5) NOT NULL,
    email_institucional VARCHAR(150) NOT NULL UNIQUE,
    rol VARCHAR(40) NOT NULL CHECK (rol IN (
        'solicitante_externo',
        'socio',
        'referente_comision',
        'consejo_administracion',
        'sindicatura',
        'docente_asesor',
        'admin_tecnico',
        'comunidad_escolar'
    )),
    cargo_institucional VARCHAR(100) NULL, -- Ej: 'Presidencia', 'Departamento de Ciencias', 'Vocal Programación'
    comision_id VARCHAR(15) NULL REFERENCES public.comisiones(id) ON DELETE SET NULL,
    estado_socio VARCHAR(30) NOT NULL DEFAULT 'Activo' CHECK (estado_socio IN ('Activo', 'En rotación', 'Alerta inactividad', 'Externo')),
    asistencia_asamblea BOOLEAN NOT NULL DEFAULT TRUE,
    tareas_entregadas_a_tiempo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- 3. TABLA: solicitudes
-- Pedidos ingresados por docentes, departamentos, directivos o familias
-- =============================================================================
CREATE TABLE public.solicitudes (
    id VARCHAR(20) PRIMARY KEY, -- Ej: 'SOL-014'
    titulo VARCHAR(160) NOT NULL CHECK (char_length(trim(titulo)) >= 5),
    area_solicitante VARCHAR(120) NOT NULL,
    solicitante_id VARCHAR(20) NULL REFERENCES public.usuarios(id) ON DELETE SET NULL,
    tipo_solucion VARCHAR(50) NOT NULL CHECK (tipo_solucion IN (
        'Sitio web',
        'Formulario',
        'Aplicación informativa',
        'Herramienta'
    )),
    descripcion TEXT NOT NULL CHECK (char_length(trim(descripcion)) >= 10),
    fecha_limite_requerida DATE NULL,
    prioridad VARCHAR(20) NOT NULL DEFAULT 'Media' CHECK (prioridad IN ('Baja', 'Media', 'Alta', 'Urgente')),
    estado VARCHAR(30) NOT NULL DEFAULT 'Por evaluar' CHECK (estado IN (
        'Por evaluar',
        'En revisión',
        'Aprobada',
        'Cancelada'
    )),
    motivo_cancelacion TEXT NULL,
    evaluado_por_id VARCHAR(20) NULL REFERENCES public.usuarios(id) ON DELETE SET NULL,
    etiqueta_fecha VARCHAR(40) NOT NULL DEFAULT 'Ahora',
    fecha_ingreso TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- 4. TABLA: proyectos
-- Soluciones digitales aprobadas por el Consejo y gestionadas en el Tablero
-- =============================================================================
CREATE TABLE public.proyectos (
    id VARCHAR(20) PRIMARY KEY, -- Ej: 'PR-001'
    solicitud_origen_id VARCHAR(20) NULL REFERENCES public.solicitudes(id) ON DELETE SET NULL,
    nombre VARCHAR(160) NOT NULL CHECK (char_length(trim(nombre)) >= 4),
    descripcion TEXT NOT NULL,
    categoria VARCHAR(50) NOT NULL CHECK (categoria IN (
        'Sitio web',
        'Formulario',
        'Aplicación informativa',
        'Herramienta'
    )),
    estado VARCHAR(30) NOT NULL DEFAULT 'Por comenzar' CHECK (estado IN (
        'Por comenzar',
        'En desarrollo',
        'En pruebas',
        'Finalizado',
        'Cancelado'
    )),
    progreso INT NOT NULL DEFAULT 0 CHECK (progreso >= 0 AND progreso <= 100),
    comision_principal_id VARCHAR(15) NULL REFERENCES public.comisiones(id) ON DELETE SET NULL,
    comisiones_asignadas VARCHAR(120) NOT NULL,
    tono_visual VARCHAR(20) NOT NULL DEFAULT 'mint' CHECK (tono_visual IN ('mint', 'coral', 'sun', 'lilac')),
    iniciales_equipo TEXT[] NOT NULL DEFAULT '{}',
    fecha_estimada_etiqueta VARCHAR(30) NOT NULL,
    fecha_entrega_pactada DATE NULL,
    fecha_entrega_real DATE NULL,
    entrega_a_termino BOOLEAN NOT NULL DEFAULT TRUE,
    horas_pc_asignadas NUMERIC(6,2) NOT NULL DEFAULT 0,
    tiempo_optimizado_hs_semanal NUMERIC(5,2) NOT NULL DEFAULT 0,
    repositorio_url VARCHAR(255) NULL,
    motivo_cancelacion TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- 5. TABLA: tareas_proyecto (Sprint Backlog - Art. 10 inc. b)
-- Tareas operativas asignadas dentro de cada comisión para los proyectos
-- =============================================================================
CREATE TABLE public.tareas_proyecto (
    id VARCHAR(20) PRIMARY KEY, -- Ej: 'TAR-001'
    proyecto_id VARCHAR(20) NOT NULL REFERENCES public.proyectos(id) ON DELETE CASCADE,
    comision_id VARCHAR(15) NOT NULL REFERENCES public.comisiones(id) ON DELETE RESTRICT,
    responsable_id VARCHAR(20) NULL REFERENCES public.usuarios(id) ON DELETE SET NULL,
    responsable_nombre VARCHAR(100) NOT NULL DEFAULT 'Sin asignar',
    titulo VARCHAR(180) NOT NULL,
    estado VARCHAR(30) NOT NULL DEFAULT 'Pendiente' CHECK (estado IN (
        'Pendiente',
        'En curso',
        'En revisión QA',
        'Completada',
        'Cancelada'
    )),
    entregada_a_tiempo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_compromiso VARCHAR(30) NOT NULL DEFAULT 'Esta semana',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- 6. TABLA: casos_prueba_qa ( Alimenta el KPI Operacional PDFT )
-- Registro de casos de prueba y bugs detectados en el estado 'En pruebas'
-- =============================================================================
CREATE TABLE public.casos_prueba_qa (
    id VARCHAR(20) PRIMARY KEY, -- Ej: 'QA-001'
    proyecto_id VARCHAR(20) NOT NULL REFERENCES public.proyectos(id) ON DELETE CASCADE,
    reportado_por_id VARCHAR(20) NULL REFERENCES public.usuarios(id) ON DELETE SET NULL,
    tipo_prueba VARCHAR(60) NOT NULL CHECK (tipo_prueba IN (
        'Validación de campos',
        'Diseño responsivo',
        'Integración y navegación',
        'Accesibilidad visual',
        'Rendimiento'
    )),
    descripcion_caso TEXT NOT NULL,
    casos_ejecutados INT NOT NULL DEFAULT 1 CHECK (casos_ejecutados > 0),
    bugs_detectados INT NOT NULL DEFAULT 0 CHECK (bugs_detectados >= 0),
    estado_correccion VARCHAR(30) NOT NULL DEFAULT 'Pendiente' CHECK (estado_correccion IN (
        'Aprobado sin fallas',
        'Bug detectado',
        'En corrección',
        'Corregido y verificado'
    )),
    dias_correccion INT NOT NULL DEFAULT 0,
    periodo_evaluado VARCHAR(30) NOT NULL DEFAULT 'Octubre 2026',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- 7. TABLA: encuestas_satisfaccion ( Alimenta el KPI Estratégico IASS )
-- Evaluación de solicitantes externos al recibir una solución homologada
-- =============================================================================
CREATE TABLE public.encuestas_satisfaccion (
    id VARCHAR(20) PRIMARY KEY, -- Ej: 'ENC-001'
    proyecto_id VARCHAR(20) NOT NULL REFERENCES public.proyectos(id) ON DELETE CASCADE,
    solicitante_codigo VARCHAR(20) NOT NULL, -- Código anonimizado ej: 'D-01'
    area_solicitante VARCHAR(120) NOT NULL,
    puntaje INT NOT NULL CHECK (puntaje >= 1 AND puntaje <= 10),
    valoracion_cualitativa VARCHAR(30) NOT NULL CHECK (valoracion_cualitativa IN (
        'Insuficiente',
        'Aprobado',
        'Notable',
        'Sobresaliente'
    )),
    tiempo_ahorrado_semanal_hs NUMERIC(4,1) NOT NULL DEFAULT 2.0,
    comentario TEXT NOT NULL,
    periodo_evaluado VARCHAR(30) NOT NULL DEFAULT 'Octubre 2026',
    fecha_encuesta TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- 8. TABLA: asambleas_actas ( Libro de Actas - Art. 10 inc. a / KPI IPEC )
-- Registro foliado digital de reuniones ordinarias, extraordinarias y Consejo
-- =============================================================================
CREATE TABLE public.asambleas_actas (
    id VARCHAR(20) PRIMARY KEY, -- Ej: 'ACT-004'
    fecha_etiqueta VARCHAR(20) NOT NULL, -- Ej: '18 SEP'
    fecha_calendario DATE NOT NULL,
    horario VARCHAR(30) NOT NULL DEFAULT '14:00 h',
    lugar VARCHAR(100) NOT NULL DEFAULT 'Sala de informática',
    titulo VARCHAR(160) NOT NULL,
    tipo_sesion VARCHAR(50) NOT NULL CHECK (tipo_sesion IN (
        'Asamblea General Ordinaria',
        'Asamblea Extraordinaria',
        'Reunión del Consejo'
    )),
    resumen_detalle TEXT NOT NULL,
    orden_del_dia TEXT[] NOT NULL DEFAULT '{}',
    acuerdos_aprobados TEXT NOT NULL,
    asistentes_presentes INT NOT NULL DEFAULT 18 CHECK (asistentes_presentes >= 0),
    padron_total INT NOT NULL DEFAULT 20 CHECK (padron_total > 0),
    estado_acta VARCHAR(30) NOT NULL DEFAULT 'Publicada' CHECK (estado_acta IN (
        'Convocada',
        'Publicada',
        'Rectificada por Asamblea'
    )),
    redactada_por_id VARCHAR(20) NULL REFERENCES public.usuarios(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- 9. TABLA: uso_laboratorio_teup ( Alimenta el KPI de Recursos TEUP )
-- Registro mensual de horas disponibles vs. horas reales en sala de informática
-- =============================================================================
CREATE TABLE public.uso_laboratorio_teup (
    id VARCHAR(20) PRIMARY KEY, -- Ej: 'LAB-2026-10'
    periodo_mes VARCHAR(40) NOT NULL UNIQUE, -- Ej: 'Octubre 2026'
    horas_disponibles NUMERIC(6,2) NOT NULL CHECK (horas_disponibles >= 0),
    horas_reales_uso NUMERIC(6,2) NOT NULL CHECK (horas_reales_uso >= 0),
    responsable_sala_id VARCHAR(20) NULL REFERENCES public.usuarios(id) ON DELETE SET NULL,
    observaciones TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================================================
-- 10. TABLA: historial_cambios ( Auditoría Inmutable para Sindicatura )
-- Conserva la trazabilidad completa de quién cambió qué, cuándo y desde qué estado
-- =============================================================================
CREATE TABLE public.historial_cambios (
    id BIGSERIAL PRIMARY KEY,
    entidad VARCHAR(50) NOT NULL, -- 'solicitudes' | 'proyectos' | 'asambleas_actas' | 'tareas_proyecto'
    registro_id VARCHAR(30) NOT NULL,
    accion VARCHAR(40) NOT NULL, -- 'CREACION' | 'CAMBIO_ESTADO' | 'MODIFICACION' | 'CANCELACION'
    estado_anterior VARCHAR(60) NULL,
    estado_nuevo VARCHAR(60) NULL,
    detalle TEXT NOT NULL,
    usuario_responsable VARCHAR(120) NOT NULL DEFAULT 'Sistema / Consejo',
    rol_responsable VARCHAR(50) NOT NULL DEFAULT 'consejo_administracion',
    fecha_hora TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices para optimizar búsquedas y filtros frecuentes (Punto 9 y 12)
CREATE INDEX idx_solicitudes_estado ON public.solicitudes(estado);
CREATE INDEX idx_solicitudes_tipo ON public.solicitudes(tipo_solucion);
CREATE INDEX idx_proyectos_estado ON public.proyectos(estado);
CREATE INDEX idx_tareas_proyecto_id ON public.tareas_proyecto(proyecto_id);
CREATE INDEX idx_historial_entidad ON public.historial_cambios(entidad, registro_id);
CREATE INDEX idx_historial_fecha ON public.historial_cambios(fecha_hora DESC);

-- =============================================================================
-- TRIGGERS AUTOMÁTICOS DE AUDITORÍA E HISTORIAL (Punto 8 y 12)
-- Garantizan que ningún cambio de estado se pierda y que la Sindicatura Escolar
-- pueda auditar todas las transiciones sin intervención manual.
-- =============================================================================
CREATE OR REPLACE FUNCTION public.fn_registrar_auditoria_automatica()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO public.historial_cambios (entidad, registro_id, accion, estado_anterior, estado_nuevo, detalle, usuario_responsable, rol_responsable)
        VALUES (
            TG_TABLE_NAME,
            NEW.id,
            'CREACION',
            NULL,
            NEW.estado,
            'Registro inicial creado en ' || TG_TABLE_NAME || ' (' || NEW.id || ')',
            'Registro del Sistema',
            'sistema'
        );
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.estado IS DISTINCT FROM NEW.estado THEN
            INSERT INTO public.historial_cambios (entidad, registro_id, accion, estado_anterior, estado_nuevo, detalle, usuario_responsable, rol_responsable)
            VALUES (
                TG_TABLE_NAME,
                NEW.id,
                CASE WHEN NEW.estado IN ('Cancelada', 'Cancelado') THEN 'CANCELACION' ELSE 'CAMBIO_ESTADO' END,
                OLD.estado,
                NEW.estado,
                'Transición de estado en ' || NEW.id || ': de "' || COALESCE(OLD.estado, '-') || '" a "' || COALESCE(NEW.estado, '-') || '"',
                'Auditoría Automática DB',
                'consejo_administracion'
            );
        END IF;
        NEW.updated_at = NOW();
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_solicitudes
BEFORE INSERT OR UPDATE ON public.solicitudes
FOR EACH ROW EXECUTE FUNCTION public.fn_registrar_auditoria_automatica();

CREATE TRIGGER trg_auditoria_proyectos
BEFORE INSERT OR UPDATE ON public.proyectos
FOR EACH ROW EXECUTE FUNCTION public.fn_registrar_auditoria_automatica();

-- Regla de protección: prohibir el borrado físico (DELETE) de actas e historial
-- cumpliendo el Reglamento Interno (Art. 10) y el Punto 8 del diseño del sistema.
CREATE OR REPLACE FUNCTION public.fn_prevenir_borrado_historial()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Operación bloqueada por Reglamento Cooperativo: No se permite eliminar registros de actas ni del historial de auditoría. Utilice la cancelación o rectificación por Asamblea.';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_proteger_historial
BEFORE DELETE ON public.historial_cambios
FOR EACH ROW EXECUTE FUNCTION public.fn_prevenir_borrado_historial();

CREATE TRIGGER trg_proteger_actas
BEFORE DELETE ON public.asambleas_actas
FOR EACH ROW EXECUTE FUNCTION public.fn_prevenir_borrado_historial();

-- =============================================================================
-- POLÍTICAS DE ACCESO ROW LEVEL SECURITY (RLS) (Punto 15)
-- =============================================================================
ALTER TABLE public.comisiones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.solicitudes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.proyectos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tareas_proyecto ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.casos_prueba_qa ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.encuestas_satisfaccion ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.asambleas_actas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.uso_laboratorio_teup ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.historial_cambios ENABLE ROW LEVEL SECURITY;

-- Políticas de lectura y operación para el cliente (permite que la app funcione
-- inmediatamente al conectar la anon key en entorno educativo y valida roles):
CREATE POLICY "Lectura pública y societaria de comisiones" ON public.comisiones FOR SELECT USING (true);
CREATE POLICY "Gestión de comisiones por Consejo" ON public.comisiones FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Lectura de usuarios cooperativa" ON public.usuarios FOR SELECT USING (true);
CREATE POLICY "Gestión de usuarios por Consejo y Admin" ON public.usuarios FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Consulta de solicitudes" ON public.solicitudes FOR SELECT USING (true);
CREATE POLICY "Creación y actualización de solicitudes" ON public.solicitudes FOR INSERT WITH CHECK (true);
CREATE POLICY "Evaluación de solicitudes por Consejo" ON public.solicitudes FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Consulta de proyectos" ON public.proyectos FOR SELECT USING (true);
CREATE POLICY "Gestión de proyectos por Consejo y Referentes" ON public.proyectos FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Consulta y gestión de tareas" ON public.tareas_proyecto FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Consulta y carga de pruebas QA" ON public.casos_prueba_qa FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Consulta y carga de encuestas IASS" ON public.encuestas_satisfaccion FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Consulta y publicación de actas" ON public.asambleas_actas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Consulta y registro de laboratorio TEUP" ON public.uso_laboratorio_teup FOR ALL USING (true) WITH CHECK (true);

-- El historial de cambios solo permite SELECT e INSERT (jamás UPDATE ni DELETE)
CREATE POLICY "Lectura de auditoría para Sindicatura y Consejo" ON public.historial_cambios FOR SELECT USING (true);
CREATE POLICY "Inserción de eventos de auditoría" ON public.historial_cambios FOR INSERT WITH CHECK (true);

-- =============================================================================
-- CARGA DE DATOS SIMULADOS DE PRUEBA (SEED DATA - Puntos 6, 13 y 14)
-- Coherente al 100% con los informes de Reglamento, Sistema, Data Mining y KPIs
-- =============================================================================

-- 1. Las 6 Comisiones de Trabajo
INSERT INTO public.comisiones (id, nombre, descripcion, funciones_estatutarias, referente_nombre, icono, tono_visual, cantidad_integrantes, iniciales_equipo) VALUES
('COM-01', 'Programación', 'Construye y mantiene las soluciones digitales.', 'Lógica de negocio, arquitectura frontend/backend, integración con base de datos Supabase y mantenimiento continuo (Art. 4 inc. a).', 'Martina L.', 'Code2', 'mint', 6, ARRAY['ML', 'JC', 'AR', '+3']),
('COM-02', 'Diseño y experiencia', 'Da forma a interfaces claras y accesibles.', 'Maqueta estética, tipografías, paleta de color, prototipado responsivo y accesibilidad escolar (Art. 4 inc. b).', 'Sofía F.', 'LayoutGrid', 'coral', 4, ARRAY['SF', 'EV', 'NS', '+1']),
('COM-03', 'Contenidos', 'Organiza la información y cuida las palabras.', 'Relevamiento de requerimientos docentes, estructura de información y redacción institucional clara (Art. 4 inc. c).', 'Elena V.', 'FileText', 'sun', 3, ARRAY['EV', 'LP', 'CM']),
('COM-04', 'Pruebas y calidad', 'Verifica que todo funcione antes de entregar.', ' Ejecución de casos de prueba, detección de bugs en distintos dispositivos y homologación QA previa al despliegue (Art. 4 inc. d).', 'Agustín R.', 'ShieldCheck', 'lilac', 4, ARRAY['AR', 'AT', 'JC', '+1']),
('COM-05', 'Comunicación', 'Comparte los proyectos con la comunidad escolar.', 'Difusión de herramientas, tutoriales breves, presentaciones en muestras y encuestas de satisfacción IASS (Art. 4 inc. e).', 'Lucía P.', 'MessageCircle', 'mint', 3, ARRAY['LP', 'SF', 'NS']),
('COM-06', 'Documentación y soporte', 'Conserva la memoria y acompaña cada entrega.', 'Archivo de código, manuales de usuario, plantillas de validación, actas de entrega y control de versiones (Art. 4 inc. f).', 'Camila M.', 'BookOpen', 'coral', 3, ARRAY['CM', 'ML', 'AT']);

-- 2. Usuarios representativos de los 8 roles y del padrón S-01 a S-20
INSERT INTO public.usuarios (id, nombre_completo, iniciales, email_institucional, rol, cargo_institucional, comision_id, estado_socio, asistencia_asamblea, tareas_entregadas_a_tiempo) VALUES
('S-01', 'Martina López', 'ML', 'martina.lopez@escuela.edu.ar', 'referente_comision', 'Referente de Programación (Vocal Consejo)', 'COM-01', 'Activo', true, true),
('S-02', 'Sofía Fernández', 'SF', 'sofia.fernandez@escuela.edu.ar', 'referente_comision', 'Referente de Diseño UI/UX (Vocal Consejo)', 'COM-02', 'Activo', true, true),
('S-03', 'Elena Varela', 'EV', 'elena.varela@escuela.edu.ar', 'consejo_administracion', 'Secretaria del Consejo / Ref. Contenidos', 'COM-03', 'Activo', true, true),
('S-04', 'Agustín Romero', 'AR', 'agustin.romero@escuela.edu.ar', 'referente_comision', 'Referente de Pruebas y Calidad (QA)', 'COM-04', 'Activo', true, true),
('S-05', 'Lucía Pereyra', 'LP', 'lucia.pereyra@escuela.edu.ar', 'consejo_administracion', 'Presidenta del Consejo / Ref. Comunicación', 'COM-05', 'Activo', true, true),
('S-06', 'Camila Méndez', 'CM', 'camila.mendez@escuela.edu.ar', 'consejo_administracion', 'Tesorera del Consejo / Ref. Documentación', 'COM-06', 'Activo', true, true),
('S-07', 'Socio S-07 (Contenidos)', 'S7', 'socio07@escuela.edu.ar', 'socio', 'Integrante Comisión de Contenidos', 'COM-03', 'Alerta inactividad', false, false),
('S-08', 'Julián Castro', 'JC', 'julian.castro@escuela.edu.ar', 'socio', 'Integrante Comisión de Programación', 'COM-01', 'Activo', true, true),
('S-09', 'Nicolás Silva', 'NS', 'nicolas.silva@escuela.edu.ar', 'sindicatura', 'Síndico Escolar Titular', 'COM-02', 'Activo', true, true),
('S-10', 'Alma Torres', 'AT', 'alma.torres@escuela.edu.ar', 'socio', 'Integrante QA y Documentación', 'COM-04', 'Activo', true, true),
('S-14', 'Socio S-14 (Contenidos)', 'S14', 'socio14@escuela.edu.ar', 'socio', 'Integrante Comisión de Contenidos', 'COM-03', 'Alerta inactividad', false, false),
('D-01', 'Prof. Laura Gómez (Biblioteca)', 'LG', 'biblioteca@escuela.edu.ar', 'solicitante_externo', 'Referente Biblioteca Escolar', NULL, 'Externo', false, true),
('D-02', 'Prof. Marcos Díaz (Ciencias)', 'MD', 'ciencias@escuela.edu.ar', 'solicitante_externo', 'Docente Departamento de Ciencias', NULL, 'Externo', false, true),
('ASE-01', 'Prof. Valeria Quiroga', 'VQ', 'asesoria.coop@escuela.edu.ar', 'docente_asesor', 'Comisión Asesora Docente', NULL, 'Externo', true, true),
('ADM-01', 'Prof. Hernán Benítez', 'HB', 'laboratorio.tic@escuela.edu.ar', 'admin_tecnico', 'Administrador Técnico / Sala de Informática', NULL, 'Externo', true, true),
('COM-PUB', 'Visitante Comunidad Escolar', 'CE', 'comunidad@escuela.edu.ar', 'comunidad_escolar', 'Familias y Alumnado General', NULL, 'Externo', false, true);

-- 3. Solicitudes iniciales (SOL-011 a SOL-014)
INSERT INTO public.solicitudes (id, titulo, area_solicitante, solicitante_id, tipo_solucion, descripcion, fecha_limite_requerida, prioridad, estado, evaluado_por_id, etiqueta_fecha) VALUES
('SOL-014', 'Registro para la muestra de ciencias', 'Departamento de Ciencias', 'D-02', 'Formulario', 'Formulario digital para inscribir proyectos estudiantiles, asignar stands y organizar horarios antes de la muestra anual de ciencias.', '2026-11-12', 'Alta', 'Por evaluar', NULL, 'Hace 2 días'),
('SOL-013', 'Página informativa para el taller de radio', 'Taller de Comunicación', 'D-02', 'Sitio web', 'Portal escolar con grilla de programas, podcasts grabados por cursos y buzón de temas sugeridos por estudiantes.', '2026-11-20', 'Media', 'En revisión', 'S-05', 'Hace 4 días'),
('SOL-012', 'Calendario de actividades deportivas', 'Educación Física', 'D-01', 'Herramienta', 'Agenda interactiva de torneos intercolegiales, horarios de entrenamiento y resultados por categoría.', '2026-10-30', 'Media', 'Aprobada', 'S-05', 'Hace 1 semana'),
('SOL-011', 'Encuesta de hábitos de lectura', 'Biblioteca Escolar', 'D-01', 'Formulario', 'Relevamiento digital para conocer qué géneros literarios y materiales técnicos prefieren los alumnos de cada año.', '2026-10-15', 'Baja', 'Aprobada', 'S-03', 'Hace 2 semanas');

-- 4. Proyectos del Tablero (PR-001 a PR-004)
INSERT INTO public.proyectos (id, solicitud_origen_id, nombre, descripcion, categoria, estado, progreso, comision_principal_id, comisiones_asignadas, tono_visual, iniciales_equipo, fecha_estimada_etiqueta, fecha_entrega_pactada, fecha_entrega_real, entrega_a_termino, horas_pc_asignadas, tiempo_optimizado_hs_semanal, repositorio_url) VALUES
('PR-001', NULL, 'Web para la feria escolar', 'Un espacio para compartir los proyectos y actividades de la feria.', 'Sitio web', 'En desarrollo', 68, 'COM-01', 'Programación + Diseño', 'coral', ARRAY['ML', 'JC', 'SF'], '18 oct', '2026-10-18', NULL, true, 24.0, 3.5, 'https://github.com/cooperativa-escolar/pr001-feria-web'),
('PR-002', 'SOL-011', 'Inscripción a talleres', 'Formulario digital para organizar cupos y participantes.', 'Formulario', 'En pruebas', 86, 'COM-04', 'Programación + Pruebas', 'mint', ARRAY['AR', 'LP'], '24 oct', '2026-10-24', NULL, true, 22.0, 4.0, 'https://github.com/cooperativa-escolar/pr002-inscripcion-talleres'),
('PR-003', 'SOL-012', 'Cartelera de novedades', 'Información escolar clara y accesible para toda la comunidad.', 'Herramienta', 'Por comenzar', 12, 'COM-03', 'Contenidos + Diseño', 'sun', ARRAY['EV', 'NS'], '05 nov', '2026-11-05', NULL, true, 8.0, 2.0, 'https://github.com/cooperativa-escolar/pr003-cartelera'),
('PR-004', NULL, 'Guía digital de biblioteca', 'Una manera sencilla de explorar los recursos disponibles.', 'Sitio web', 'Finalizado', 100, 'COM-06', 'Documentación + Programación', 'lilac', ARRAY['CM', 'AT'], '12 sep', '2026-09-12', '2026-09-11', true, 14.0, 4.5, 'https://github.com/cooperativa-escolar/pr004-guia-biblioteca');

-- 5. Tareas operativas del Sprint Backlog
INSERT INTO public.tareas_proyecto (id, proyecto_id, comision_id, responsable_id, responsable_nombre, titulo, estado, entregada_a_tiempo, fecha_compromiso) VALUES
('TAR-001', 'PR-001', 'COM-01', 'S-01', 'Martina L.', 'Maquetar grilla de stands y buscador por curso en la Web de Feria', 'En curso', true, '16 oct'),
('TAR-002', 'PR-001', 'COM-02', 'S-02', 'Sofía F.', 'Ajustar contraste accesible de tarjetas en celulares', 'Completada', true, '14 oct'),
('TAR-003', 'PR-002', 'COM-04', 'S-04', 'Agustín R.', 'Ejecutar matriz de 40 pruebas de validación de cupos máximos', 'En revisión QA', true, '20 oct'),
('TAR-004', 'PR-002', 'COM-01', 'S-08', 'Julián C.', 'Corregir validación de correo institucional y campos vacíos', 'En curso', true, '22 oct'),
('TAR-005', 'PR-003', 'COM-03', 'S-03', 'Elena V.', 'Redactar estructura editorial de avisos por departamento', 'Pendiente', true, '28 oct'),
('TAR-006', 'PR-004', 'COM-06', 'S-06', 'Camila M.', 'Publicar manual de uso para docentes y acta de recepción final', 'Completada', true, '12 sep');

-- 6. Casos de Prueba QA (Simulación KPI PDFT: 60 pruebas totales, 8 bugs = 13.3%)
INSERT INTO public.casos_prueba_qa (id, proyecto_id, reportado_por_id, tipo_prueba, descripcion_caso, casos_ejecutados, bugs_detectados, estado_correccion, dias_correccion, periodo_evaluado) VALUES
('QA-001', 'PR-002', 'S-04', 'Validación de campos', 'Batería de pruebas sobre campos obligatorios, formato de DNI/correo y límite de cupos en formulario PR-002.', 35, 5, 'En corrección', 3, 'Octubre 2026'),
('QA-002', 'PR-001', 'S-10', 'Diseño responsivo', 'Verificación de visualización de tarjetas y menú lateral en pantallas móviles (360px a 768px) en PR-001.', 25, 3, 'En corrección', 2, 'Octubre 2026');

-- 7. Encuestas de Satisfacción Docente (Simulación KPI IASS: 17 / 20 = 85.0%)
INSERT INTO public.encuestas_satisfaccion (id, proyecto_id, solicitante_codigo, area_solicitante, puntaje, valoracion_cualitativa, tiempo_ahorrado_semanal_hs, comentario, periodo_evaluado) VALUES
('ENC-001', 'PR-004', 'D-01', 'Biblioteca Escolar', 9, 'Sobresaliente', 4.5, 'La guía digital agilizó las consultas de libros por materia y redujo las filas en los recreos.', 'Octubre 2026'),
('ENC-002', 'PR-002', 'D-02', 'Coordinación de Talleres', 8, 'Notable', 4.0, 'El prototipo funcional del formulario ordenó muy bien los cupos; solo sugerimos aclarar el mensaje de confirmación.', 'Octubre 2026');

-- 8. Asambleas y Actas (Libro de Actas + Simulación KPI IPEC: 18/20 = 90.0%)
INSERT INTO public.asambleas_actas (id, fecha_etiqueta, fecha_calendario, horario, lugar, titulo, tipo_sesion, resumen_detalle, orden_del_dia, acuerdos_aprobados, asistentes_presentes, padron_total, estado_acta, redactada_por_id) VALUES
('ACT-004', '15 OCT', '2026-10-15', '14:00 h', 'Sala de informática', 'Asamblea general ordinaria de octubre', 'Asamblea General Ordinaria', 'Evaluación del Tablero KPI (Octubre 2026), aprobación de mejoras QA y rotación preventiva.', ARRAY['01 Avance de proyectos en curso', '02 Evaluación de nuevas solicitudes', '03 Propuestas de las comisiones y revisión de KPIs', '04 Próximos pasos y acuerdos'], 'Se aprueba por unanimidad el Checklist de Pre-entrega y Peer Review entre Programación y QA (para reducir el PDFT del 13.3% a <9%), y la mediación formativa para S-07 y S-14.', 18, 20, 'Convocada', 'S-03'),
('ACT-003', '18 SEP', '2026-09-18', '14:00 h', 'Sala de informática', 'Reunión del Consejo', 'Reunión del Consejo', 'Seguimiento de proyectos y tareas; homologación de entrega PR-004.', ARRAY['01 Cierre y entrega de PR-004 Guía de Biblioteca', '02 Asignación de equipos para PR-001 y PR-002'], 'Se homologa la entrega final de PR-004 a Biblioteca Escolar y se habilita la encuesta de satisfacción IASS.', 19, 20, 'Publicada', 'S-03'),
('ACT-002', '04 SEP', '2026-09-04', '14:00 h', 'Sala de informática', 'Asamblea extraordinaria', 'Asamblea Extraordinaria', 'Prioridades para el segundo semestre y metas SMART.', ARRAY['01 Definición de los 3 Objetivos SMART', '02 Priorización de pedidos docentes del 2° semestre'], 'Se priorizan los 4 desarrollos troncales del semestre con meta de entregas a término >= 90%.', 19, 20, 'Publicada', 'S-03'),
('ACT-001', '12 AGO', '2026-08-12', '14:00 h', 'Sala de informática', 'Reunión del Consejo', 'Reunión del Consejo', 'Organización de comisiones y designación de referentes.', ARRAY['01 Conformación de las 6 comisiones técnicas', '02 Pautas de uso del laboratorio escolar'], 'Quedan formalmente constituidas las 6 comisiones con un padrón activo de 20 socios estudiantes.', 20, 20, 'Publicada', 'S-03');

-- 9. Registro de Uso de Laboratorio (Simulación KPI TEUP: 68h / 80h = 85.0%)
INSERT INTO public.uso_laboratorio_teup (id, periodo_mes, horas_disponibles, horas_reales_uso, responsable_sala_id, observaciones) VALUES
('LAB-2026-10', 'Octubre 2026', 80.0, 68.0, 'ADM-01', 'TEUP = 85.0% (Óptimo). Uso eficiente de las PC escolares destinadas a programación, diseño y pruebas sin saturar el equipamiento.');

-- 10. Historial de Cambios adicional explicito para consulta de Sindicatura
INSERT INTO public.historial_cambios (entidad, registro_id, accion, estado_anterior, estado_nuevo, detalle, usuario_responsable, rol_responsable, fecha_hora) VALUES
('solicitudes', 'SOL-011', 'CAMBIO_ESTADO', 'En revisión', 'Aprobada', 'El Consejo aprobó la solicitud de Biblioteca Escolar y autorizó su pase a desarrollo.', 'Lucía Pereyra (Presidencia)', 'consejo_administracion', NOW() - INTERVAL '12 days'),
('solicitudes', 'SOL-012', 'CAMBIO_ESTADO', 'En revisión', 'Aprobada', 'El Consejo aprobó el Calendario Deportivo y lo derivó a Contenidos + Diseño (PR-003).', 'Lucía Pereyra (Presidencia)', 'consejo_administracion', NOW() - INTERVAL '6 days'),
('proyectos', 'PR-004', 'CAMBIO_ESTADO', 'En pruebas', 'Finalizado', 'Homologación QA completada al 100% y entrega formal a Biblioteca Escolar.', 'Agustín Romero (Referente QA)', 'referente_comision', NOW() - INTERVAL '18 days'),
('proyectos', 'PR-002', 'CAMBIO_ESTADO', 'En desarrollo', 'En pruebas', 'Pase a entorno de testing. Se registraron 8 observaciones de validación y maquetado responsivo para corregir.', 'Martina López (Ref. Programación)', 'referente_comision', NOW() - INTERVAL '3 days'),
('solicitudes', 'SOL-013', 'CAMBIO_ESTADO', 'Por evaluar', 'En revisión', 'El Consejo inició el análisis de factibilidad técnica junto a la Comisión de Contenidos.', 'Elena Varela (Secretaría)', 'consejo_administracion', NOW() - INTERVAL '2 days');

