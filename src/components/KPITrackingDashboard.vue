<script setup>
import { ref } from 'vue'
import {
  AlertTriangle,
  ArrowRight,
  BarChart3,
  CheckCircle2,
  ChevronRight,
  Compass,
  Eye,
  FileCheck2,
  FileText,
  Info,
  Lock,
  Printer,
  Scale,
  Shield,
  ShieldCheck,
  Wrench,
  X,
} from 'lucide-vue-next'
import Button from './ui/Button.vue'

const kpiList = [
  {
    id: 'TEUP',
    code: 'TEUP',
    category: 'Financiero o Recursos',
    categoryShort: 'Financiero / Recursos',
    name: 'Tasa de Eficiencia en el Uso de Puestos de Cómputo',
    shortName: 'TEUP (Uso PC)',
    target: '75% - 85%',
    currentValue: 85.0,
    formattedValue: '85.0%',
    statusLabel: 'VERDE — Óptimo',
    statusType: 'success',
    criteriaText: {
      green: 'Verde: 75% - 85% (Aprovechamiento óptimo del laboratorio)',
      yellow: 'Amarillo: 65% - 74% o 86% - 90% (Riesgo de subutilización o saturación)',
      red: 'Rojo: <65% o >90% (Subutilización severa o sobrecarga sin mantenimiento)',
    },
    decisionLevel: 'Operacional',
    temporality: 'Adelantado (Leading)',
    temporalityReason:
      'Mide el día a día del laboratorio. Si el uso de computadoras desciende a mitad de mes, permite predecir demoras futuras en las entregas antes de que venzan los plazos.',
    area: 'Tesorería / Infraestructura Técnica',
    responsible: 'Tesorero/a del Consejo en coordinación con el Administrador Técnico de Sala',
    formula:
      'TEUP = (Horas reales de uso de PC destinadas a proyectos cooperativos / Horas totales disponibles del laboratorio asignadas) * 100',
    dataSource:
      'Planilla de asistencia y libro de firmas del Laboratorio de Informática administrada por el Administrador Técnico de Sala.',
    frequency: 'Mensual (al cierre del balance de actividades previo a la asamblea).',
    zeroDenominator:
      "Si en un mes no hubiese horas disponibles de laboratorio (ej. receso de invierno o refacciones edilicias, Total_Horas = 0), el indicador no se calcula algebraicamente y se registra como 'N/A: Receso institucional o sala no operativa'.",
    interpretation:
      'Se espera que el valor se mantenga dentro del intervalo óptimo (75% - 85%). Un valor menor al 70% indica subutilización del equipamiento; un valor superior al 90% advierte saturación de máquinas y riesgo de desgaste de hardware sin tiempo para mantenimiento.',
    calculationBreakdown: {
      period: 'Octubre 2026',
      numerator: '68 horas reales registradas por equipos de programación, diseño y pruebas',
      denominator: '80 horas de laboratorio reservadas para la cooperativa',
      detail:
        'Uso equilibrado y eficiente de la sala de cómputo escolar sin generar cuellos de botella ni ociosidad.',
      math: 'TEUP = (68 h / 80 h) * 100 = 85.0%',
    },
  },
  {
    id: 'IASS',
    code: 'IASS',
    category: 'Usuarios / Comunidad',
    categoryShort: 'Usuarios / Comunidad',
    name: 'Índice de Aceptación y Satisfacción del Solicitante',
    shortName: 'IASS (Satisfacción)',
    target: '>= 85.0%',
    currentValue: 85.0,
    formattedValue: '85.0%',
    statusLabel: 'VERDE — Cumplido',
    statusType: 'success',
    criteriaText: {
      green: 'Verde: >= 85.0% (Alta satisfacción de docentes y directivos)',
      yellow: 'Amarillo: 75.0% - 84.9% (Aceptación moderada, revisar expectativas)',
      red: 'Rojo: <75.0% (Insatisfacción o fallas en el software entregado)',
    },
    decisionLevel: 'Estratégico',
    temporality: 'Rezagado (Lagging)',
    temporalityReason:
      'Mide la percepción global del usuario una vez que el software ya fue terminado y utilizado; documenta el resultado final del impacto institucional logrado por la cooperativa.',
    area: 'Presidencia / Comunicación y Difusión',
    responsible:
      'Comisión de Comunicación y Difusión (envío/recopilación) y Presidencia del Consejo',
    formula:
      'IASS = (Sumatoria del puntaje obtenido en encuestas de entrega [escala 1 a 10] / Puntaje máximo alcanzable) * 100. (Donde Puntaje Máximo = Solicitudes entregadas y evaluadas * 10).',
    dataSource:
      'Formulario digital de recepción final y satisfacción completado por el Solicitante Externo al recibir la solución homologada.',
    frequency: 'Por proyecto entregado y consolidado mensualmente en la Asamblea General.',
    zeroDenominator:
      "Si en un período de cálculo no se finalizó ninguna solución y no hubo encuestas a completar (denominador = 0), se reporta formalmente como '0 entregas en el período - Sin evaluaciones registradas'.",
    interpretation:
      'Conviene que el valor aumente o se aproxime al 100%. Un índice menor a 80% activa revisiones en los requerimientos iniciales tomados por la Comisión de Contenidos. La meta es alcanzable porque se realizan etapas previas de prueba con el usuario antes del pase a producción.',
    calculationBreakdown: {
      period: 'Octubre 2026',
      numerator:
        '17 puntos obtenidos (Docente D-01: 9/10 en PR-004; Docente D-02: 8/10 en prototipo PR-002)',
      denominator: '20 puntos máximos posibles (2 proyectos entregados * 10)',
      detail:
        'Los docentes valoraron muy positivamente las entregas iniciales de las soluciones pedagógicas escolares.',
      math: 'IASS = (17 / 20) * 100 = 85.0%',
    },
  },
  {
    id: 'PDFT',
    code: 'PDFT',
    category: 'Procesos Internos',
    categoryShort: 'Procesos Internos',
    name: 'Porcentaje de Defectos Funcionales en Testing',
    shortName: 'PDFT (Defectos QA)',
    target: '<= 10.0%',
    currentValue: 13.3,
    formattedValue: '13.3%',
    statusLabel: 'ROJO — Desvío de Calidad',
    statusType: 'danger',
    criteriaText: {
      green: 'Verde: <= 10.0% (Código robusto y diseño coherente)',
      yellow: 'Amarillo: 10.1% - 12.0% (Alerta preventiva en validaciones y estilos)',
      red: 'Rojo: >12.0% (Desvío crítico: requiere intervención metodológica)',
    },
    decisionLevel: 'Operacional',
    temporality: 'Adelantado (Leading)',
    temporalityReason:
      'Mide el desempeño técnico directo del código en iteraciones cortas. Anticipa fallas mayores en producción: si la tasa de bugs es alta en pruebas, predice insatisfacción futura del usuario.',
    area: 'Comisión de Control de Calidad y Pruebas (QA) / Programación',
    responsible:
      'Referente de la Comisión de Control de Calidad y Pruebas (QA) junto a la Comisión de Programación',
    formula:
      'PDFT = (Cantidad de casos de prueba con error o bugs detectados en el ciclo de testing / Cantidad total de casos de prueba ejecutados en el mes) * 100',
    dataSource:
      "Módulo de Tareas y Matriz de Errores del sistema de gestión cooperativo (registros de la tarjeta 'En pruebas').",
    frequency: 'Quincenal (por iteración de desarrollo) y mensual en Consejo de Administración.',
    zeroDenominator:
      "Si en un ciclo el equipo se encuentra en fase de investigación o diseño previo y no se ejecutó ningún caso de prueba formal (Total_Pruebas = 0), se reporta como 'Sin casos de prueba programados para el ciclo'.",
    interpretation:
      'Conviene que el valor disminuya. Una tasa por debajo del 10% denota alta calidad en la codificación inicial. Al alcanzar 13.3%, se superó el límite fijado por 3.3 puntos porcentuales debido a fallas en validaciones de formulario y diseño responsivo, lo que activa el Plan de Mejoras.',
    calculationBreakdown: {
      period: 'Octubre 2026',
      numerator: '8 fallas o bugs detectados (3 de diseño responsivo y 5 de validación de campos)',
      denominator: '60 casos de testeo formal ejecutados en PR-002 e integración de PR-001',
      detail:
        'Se superó el umbral tolerable de fallas por 3.3 puntos porcentuales. Requiere intervención inmediata antes del pase a producción.',
      math: 'PDFT = (8 / 60) * 100 = 13.3%',
    },
    actionPlan: {
      type: 'corrective',
      title: 'Decisión Correctiva N° 1: Mitigación de Defectos en Software',
      rationale:
        'La tasa de fallas en QA alcanzó el 13.3%, superando el límite de control fijado en 10.0%, concentrándose en errores de validación de formulario y adaptabilidad responsiva.',
      actions: [
        "Implementar un protocolo formal de 'Checklist de Pre-entrega' obligatorio.",
        "Establecer pruebas cruzadas de código entre pares (Peer Review) antes de mover cualquier tarjeta de 'En desarrollo' a 'En pruebas'.",
        'Redacción de plantillas estándar de validación de formularios por la Comisión de Documentación.',
      ],
      responsible: 'Referente de Programación en conjunto con Referente de QA',
      deadline: 'Al finalizar el siguiente sprint quincenal (15 días hábiles), meta PDFT < 9.0%.',
    },
  },
  {
    id: 'IPEC',
    code: 'IPEC',
    category: 'Personas / Aprendizaje',
    categoryShort: 'Personas / Aprendizaje',
    name: 'Índice de Participación Efectiva por Comisión',
    shortName: 'IPEC (Participación)',
    target: '>= 85.0%',
    currentValue: 90.0,
    formattedValue: '90.0%',
    statusLabel: 'VERDE — Cumplido',
    statusType: 'success',
    criteriaText: {
      green: 'Verde: >= 85.0% (Excelente involucramiento democrático y societario)',
      yellow: 'Amarillo: 75.0% - 84.9% (Alerta de deserción o sobrecarga en referentes)',
      red: 'Rojo: <75.0% (Deserción estudiantil severa o inactividad de comisiones)',
    },
    decisionLevel: 'Estratégico',
    temporality: 'Rezagado y Predictivo Mixto',
    temporalityReason:
      'Constata la participación real ocurrida en el mes (rezagado respecto a las actas), pero a nivel estratégico funciona como advertencia preventiva sobre la sostenibilidad del equipo para el ciclo siguiente.',
    area: 'Secretaría / Consejo de Administración y Comisión Asesora Docente',
    responsible: 'Secretaría del Consejo de Administración y Docente Asesor/a',
    formula:
      'IPEC = (Cantidad de socios activos con al menos una tarea entregada a tiempo y presencia en asamblea / Padrón total de socios registrados en la cooperativa) * 100',
    dataSource:
      'Actas del Libro de Asambleas (Secretaría) y módulo de asignación de usuarios y tareas del sistema.',
    frequency: 'Mensual (previo a cada sesión ordinaria del Consejo).',
    zeroDenominator:
      "Dado que el padrón cooperativo institucional cuenta con al menos los miembros fundadores y representantes elegidos, el denominador nunca será cero en condiciones normales. Si ocurriera una disolución total, se informaría como 'Padrón inactivo'.",
    interpretation:
      'Conviene que el valor aumente hacia el 100%. Un resultado por debajo del 75% alerta sobre deserción estudiantil o asignación desigual de tareas. Se alcanzó un 90.0%, superando la meta prevista, aunque se identificaron 2 ausencias focalizadas en la Comisión de Contenidos.',
    calculationBreakdown: {
      period: 'Octubre 2026',
      numerator:
        '18 socios activos que cumplieron sus tareas asignadas y asistieron a la asamblea',
      denominator: '20 estudiantes registrados en el padrón activo en las 6 comisiones',
      detail:
        'Excelente involucramiento democrático estudiantil. Se registraron únicamente 2 ausencias no justificadas (S-07 y S-14 de Contenidos).',
      math: 'IPEC = (18 / 20) * 100 = 90.0%',
    },
    actionPlan: {
      type: 'preventive',
      title: 'Decisión Preventiva N° 2: Sostenibilidad del Compromiso Societario',
      rationale:
        'Si bien el IPEC cumplió la meta global (90%), se detectaron 2 socios con inactividad (S-07 y S-14) pertenecientes a la Comisión de Contenidos, requiriendo acción preventiva antes de que devenga en deserción.',
      actions: [
        'Aplicar el protocolo establecido en el Artículo 5 del Reglamento institucional.',
        'Ofrecer una instancia de mediación y rotación voluntaria de comisión hacia áreas de diseño o comunicación.',
        'Taller de nivelación y acompañamiento personalizado guiado por la Comisión Asesora Docente.',
      ],
      responsible: 'Secretaría del Consejo de Administración y Docente Asesor/a',
      deadline: 'Al cierre del próximo mes en la revisión ordinaria de asistencia del Consejo.',
    },
  },
]

const audienceMatrix = [
  {
    id: 'consejo',
    title: 'Consejo de Administración y Sindicatura Escolar',
    badge: 'Acceso Total & Auditoría',
    scope: 'Gobierno escolar, fiscalización y auditoría estatutaria',
    description:
      'Acceso total de visualización y desglose analítico (drill-down) de cada fórmula matemática, código de prueba e historial de cambios para auditoría estatutaria de la cooperativa.',
    permissions: [
      'Visualización irrestricta de los 4 KPI (TEUP, IASS, PDFT, IPEC).',
      'Desglose analítico completo (drill-down) con memorias de cálculo detalladas.',
      'Acceso a códigos de prueba, matrices de errores y actas secretariales.',
      'Facultad de homologar decisiones correctivas y planes de mejora continua.',
    ],
    restricted: [],
  },
  {
    id: 'comisiones',
    title: 'Referentes de Comisión y Socios Activos',
    badge: 'Acceso Operativo de Equipo',
    scope: 'Gestión cotidiana de sprints, tareas técnicas y desarrollo',
    description:
      'Visualización completa de los 4 indicadores y detalle operativo de su respectiva comisión para seguimiento continuo del sprint de trabajo y control de calidad.',
    permissions: [
      'Visualización de los 4 KPI y estado semafórico con etiquetas escritas.',
      'Detalle operativo y matriz de tareas de su respectiva comisión de trabajo.',
      'Registro de casos de prueba y reporte de anomalías en testing (QA).',
      'Seguimiento quincenal de horas de cómputo y asistencia a reuniones.',
    ],
    restricted: ['Fórmulas contables de auditoría reservadas a Sindicatura.'],
  },
  {
    id: 'docentes',
    title: 'Docentes Asesores de la Institución',
    badge: 'Acceso Consultivo Pedagógico',
    scope: 'Acompañamiento pedagógico, mediación y formación cooperativa',
    description:
      'Acceso consultivo pedagógico para orientar y acompañar la toma de decisiones, evaluar el impacto formativo y garantizar el cumplimiento del estatuto escolar.',
    permissions: [
      'Visualización general y analítica del cuadro de mando integral.',
      'Monitoreo de deserción estudiantil e indicadores de participación (IPEC).',
      'Acompañamiento en rotaciones voluntarias de comisiones y mediación escolar.',
      'Validación de los criterios pedagógicos en soluciones solicitadas.',
    ],
    restricted: ['No emite votos operativos técnicos reservados a estudiantes.'],
  },
  {
    id: 'comunidad',
    title: 'Solicitantes Externos y Comunidad Escolar',
    badge: 'Vista Resumida Pública',
    scope: 'Transparencia institucional hacia docentes, directivos y familias',
    description:
      'Acceso a una vista resumida y pública que expone el IASS y el volumen general de soluciones entregadas, preservando la confidencialidad interna y el anonimato estudiantil.',
    permissions: [
      'Visualización del Índice de Satisfacción del Solicitante (IASS: 85.0%).',
      'Listado y catálogo de proyectos escolares finalizados y entregados.',
      'Formulario de recepción final y calificación de calidad de soluciones.',
    ],
    restricted: [
      'Oculta datos nominales de estudiantes (preserva privacidad y Data Mining).',
      'Oculta matriz interna de bugs de testing y horas de cómputo de laboratorio.',
    ],
  },
]

const selectedKPI = ref(null)
const selectedAudience = ref('todos')
const reportMode = ref(false)
const activeTab = ref('tablero')

function handlePrint() {
  window.print()
}
</script>

<template>
  <div :class="['kpi-module-container', reportMode ? 'kpi-report-mode' : '']">
    <!-- Banner de Cabecera de la Sección 8 -->
    <div class="kpi-hero-banner">
      <div class="kpi-hero-content">
        <div class="kpi-hero-tag">
          <span class="kpi-pulse-dot" />
          <span>PUNTO 8 · DISEÑO DE TABLERO DE SEGUIMIENTO (BSC)</span>
        </div>
        <h2>Tablero de Control y Matriz de Seguimiento</h2>
        <p>
          Monitoreo en tiempo real de la salud operativa de la cooperativa escolar a través de
          cuatro indicadores clave adaptados al Balanced Scorecard, metas pautadas, resultados de la
          simulación y criterios semafóricos accesibles con etiquetas textuales explícitas.
        </p>

        <div class="kpi-hero-actions">
          <div class="kpi-audience-selector">
            <label for="audience-select">
              <Eye :size="15" />
              <span>Vista por Audiencia:</span>
            </label>
            <select
              id="audience-select"
              v-model="selectedAudience"
              class="kpi-select"
            >
              <option value="todos">Vista General Integral (Todos los órganos)</option>
              <option value="consejo">Consejo de Administración y Sindicatura (Total)</option>
              <option value="comisiones">Referentes y Socios (Operativo de Equipo)</option>
              <option value="docentes">Docentes Asesores (Consultivo Pedagógico)</option>
              <option value="comunidad">Comunidad Escolar / Solicitantes (Público)</option>
            </select>
          </div>

          <div class="kpi-hero-buttons">
            <Button
              :variant="reportMode ? 'default' : 'outline'"
              size="sm"
              class="kpi-btn-report"
              title="Modo pantalla limpia para capturar o agregar al informe escolar"
              @click="reportMode = !reportMode"
            >
              <FileCheck2 :size="16" />
              <span>{{ reportMode ? 'Salir de Modo Informe' : 'Modo Captura de Informe' }}</span>
            </Button>

            <Button
              variant="outline"
              size="sm"
              class="kpi-btn-print"
              title="Imprimir pantalla o exportar a PDF para el anexo del informe"
              @click="handlePrint"
            >
              <Printer :size="16" />
              <span>Imprimir / PDF</span>
            </Button>
          </div>
        </div>
      </div>

      <div class="kpi-hero-stats">
        <div class="kpi-mini-stat">
          <span>PERÍODO EVALUADO</span>
          <strong>Octubre 2026</strong>
          <small>Simulación y prueba piloto</small>
        </div>
        <div class="kpi-mini-stat">
          <span>METAS ALCANZADAS</span>
          <strong class="text-mint">3 de 4 (75%)</strong>
          <small>TEUP, IASS e IPEC cumplidos</small>
        </div>
        <div class="kpi-mini-stat highlight-danger">
          <span>DESVÍOS DETECTADOS</span>
          <strong class="text-coral">1 Crítico (PDFT)</strong>
          <small>Plan de mejoras activado</small>
        </div>
      </div>
    </div>

    <div v-if="selectedAudience === 'comunidad'" class="kpi-public-notice">
      <Info :size="20" />
      <div>
        <strong>Modo Vista Pública (Comunidad Escolar y Solicitantes Externos)</strong>
        <p>
          Por políticas de confidencialidad y preservación del anonimato estudiantil (Minería de
          Datos ética), las métricas internas de defectos de pruebas (PDFT), horas de laboratorio
          (TEUP) y padrón nominal de socios (IPEC) permanecen reservadas para auditoría interna,
          exponiendo públicamente el Índice de Satisfacción (IASS) y los proyectos concluidos.
        </p>
      </div>
    </div>

    <!-- Navegación por pestañas secundarias -->
    <div class="kpi-nav-tabs">
      <button
        type="button"
        :class="['kpi-tab-btn', activeTab === 'tablero' ? 'kpi-tab-active' : '']"
        @click="activeTab = 'tablero'"
      >
        <BarChart3 :size="16" />
        <span>Tablero y Cuadro de Mando (Punto 8)</span>
      </button>
      <button
        type="button"
        :class="['kpi-tab-btn', activeTab === 'audiencias' ? 'kpi-tab-active' : '']"
        @click="activeTab = 'audiencias'"
      >
        <Shield :size="16" />
        <span>Matriz de Audiencias y Permisos</span>
      </button>
      <button
        type="button"
        :class="['kpi-tab-btn', activeTab === 'criterios' ? 'kpi-tab-active' : '']"
        @click="activeTab = 'criterios'"
      >
        <Scale :size="16" />
        <span>Criterios Semafóricos &amp; Accesibilidad</span>
      </button>
      <button
        type="button"
        :class="['kpi-tab-btn', activeTab === 'mejoras' ? 'kpi-tab-active' : '']"
        @click="activeTab = 'mejoras'"
      >
        <Wrench :size="16" />
        <span>Plan de Decisiones Correctivas (QA)</span>
        <span class="kpi-pill-badge">1 Activa</span>
      </button>
    </div>

    <!-- VISTA 1: TABLERO PRINCIPAL CON TARJETAS Y TABLA FORMAL -->
    <div v-if="activeTab === 'tablero'" class="kpi-view-tablero">
      <div class="kpi-cards-grid">
        <div
          v-for="kpi in kpiList"
          :key="kpi.id"
          :class="[
            'kpi-card',
            kpi.statusType === 'danger' ? 'kpi-card-danger' : 'kpi-card-success',
            selectedAudience === 'comunidad' && kpi.id !== 'IASS' ? 'kpi-card-restricted' : '',
          ]"
          role="button"
          tabindex="0"
          @click="!(selectedAudience === 'comunidad' && kpi.id !== 'IASS') && (selectedKPI = kpi)"
          @keydown.enter="
            !(selectedAudience === 'comunidad' && kpi.id !== 'IASS') && (selectedKPI = kpi)
          "
        >
          <div class="kpi-card-header">
            <span class="kpi-card-category">{{ kpi.categoryShort }}</span>
            <span :class="['kpi-status-badge', kpi.statusType]">
              <span class="kpi-status-circle" />
              {{ kpi.statusLabel }}
            </span>
          </div>

          <div class="kpi-card-title-row">
            <h3>{{ kpi.shortName }}</h3>
            <span class="kpi-code-pill">{{ kpi.code }}</span>
          </div>

          <div
            v-if="selectedAudience === 'comunidad' && kpi.id !== 'IASS'"
            class="kpi-restricted-cover"
          >
            <Lock :size="28" />
            <strong>Dato Interno Reservado</strong>
            <p>Disponible únicamente para Consejo, Referentes y Docentes.</p>
          </div>
          <template v-else>
            <div class="kpi-card-value-row">
              <div class="kpi-value-block">
                <span class="kpi-value-num">{{ kpi.formattedValue }}</span>
                <span class="kpi-value-sub">Resultado Obtenido</span>
              </div>
              <div class="kpi-target-block">
                <span class="kpi-target-num">{{ kpi.target }}</span>
                <span class="kpi-target-sub">Meta Pautada</span>
              </div>
            </div>

            <div class="kpi-progress-wrapper">
              <div class="kpi-progress-bar">
                <div
                  :class="['kpi-progress-fill', kpi.statusType]"
                  :style="{
                    width: `${Math.min(100, Math.max(10, (kpi.currentValue / 100) * 100))}%`,
                  }"
                />
              </div>
              <div class="kpi-progress-meta">
                <span>{{ kpi.calculationBreakdown.math }}</span>
                <span class="kpi-detail-link">
                  Ficha Técnica <ChevronRight :size="13" />
                </span>
              </div>
            </div>

            <div class="kpi-card-footer-tags">
              <span class="kpi-tag-temporality">
                {{ kpi.temporality.split(' ')[0] ?? kpi.temporality }}
              </span>
              <span class="kpi-tag-level">{{ kpi.decisionLevel }}</span>
              <span class="kpi-tag-area">
                {{ kpi.area.split('/')[0]?.trim() ?? kpi.area }}
              </span>
            </div>
          </template>
        </div>
      </div>

      <div class="kpi-table-container">
        <div class="kpi-table-header-bar">
          <div>
            <span class="kpi-subtitle-eyebrow">MATRIZ DE VISUALIZACIÓN REQUERIDA (PUNTO 8)</span>
            <h3>Tabla General de los Cuatro KPI, Metas, Resultados y Criterios Semafóricos</h3>
            <p>
              Estructura canónica del tablero institucional con evaluación del estado operativo y
              etiquetas semafóricas accesibles.
            </p>
          </div>

          <div class="kpi-table-badges">
            <span class="badge-ok">
              <CheckCircle2 :size="14" /> 3 Cumplidos
            </span>
            <span class="badge-alert">
              <AlertTriangle :size="14" /> 1 Desvío Crítico
            </span>
          </div>
        </div>

        <div class="table-responsive">
          <table class="kpi-matrix-table">
            <thead>
              <tr>
                <th>Categoría BSC</th>
                <th>Indicador Clave</th>
                <th>Meta Pautada</th>
                <th>Valor Actual</th>
                <th>Estado Visual y Etiqueta</th>
                <th>Criterio Semafórico Definido</th>
                <th class="th-action">Acción</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="kpi in kpiList"
                :key="kpi.id"
                :class="kpi.statusType === 'danger' ? 'row-danger-highlight' : ''"
              >
                <td class="td-category">
                  <strong>{{ kpi.category }}</strong>
                  <small>{{ kpi.decisionLevel }}</small>
                </td>
                <td class="td-name">
                  <div class="kpi-name-cell">
                    <strong>{{ kpi.shortName }}</strong>
                    <span>{{ kpi.name }}</span>
                  </div>
                </td>
                <td class="td-meta">
                  <span class="meta-pill">{{ kpi.target }}</span>
                </td>
                <td class="td-actual">
                  <span
                    v-if="selectedAudience === 'comunidad' && kpi.id !== 'IASS'"
                    class="restricted-badge"
                  >
                    <Lock :size="12" /> Reservado
                  </span>
                  <strong v-else :class="['actual-value-text', kpi.statusType]">
                    {{ kpi.formattedValue }}
                  </strong>
                </td>
                <td class="td-status">
                  <span
                    v-if="selectedAudience === 'comunidad' && kpi.id !== 'IASS'"
                    class="restricted-badge"
                  >
                    Confidencial
                  </span>
                  <span v-else :class="['status-display-badge', kpi.statusType]">
                    <span class="badge-indicator" />
                    <span class="badge-text">{{ kpi.statusLabel }}</span>
                  </span>
                </td>
                <td class="td-criteria">
                  <div class="criteria-list">
                    <span class="crit-item green">
                      <strong>Verde:</strong> {{ kpi.criteriaText.green.replace(/^Verde:\s*/, '') }}
                    </span>
                    <span class="crit-item yellow">
                      <strong>Amarillo:</strong>
                      {{ kpi.criteriaText.yellow.replace(/^Amarillo:\s*/, '') }}
                    </span>
                    <span class="crit-item red">
                      <strong>Rojo:</strong> {{ kpi.criteriaText.red.replace(/^Rojo:\s*/, '') }}
                    </span>
                  </div>
                </td>
                <td class="td-action">
                  <Button
                    variant="ghost"
                    size="sm"
                    class="btn-inspect"
                    @click="selectedKPI = kpi"
                  >
                    <FileText :size="15" />
                    <span>Ficha</span>
                  </Button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="kpi-table-footer-legend">
          <div class="legend-item">
            <span class="legend-color-box green" />
            <span>
              <strong>Verde (Óptimo / Cumplido):</strong> El indicador se sitúa dentro del umbral
              esperado o lo supera favorablemente.
            </span>
          </div>
          <div class="legend-item">
            <span class="legend-color-box yellow" />
            <span>
              <strong>Amarillo (Alerta Preventiva):</strong> Desvío leve que exige seguimiento
              temprano para prevenir una merma de calidad.
            </span>
          </div>
          <div class="legend-item">
            <span class="legend-color-box red" />
            <span>
              <strong>Rojo (Desvío Crítico):</strong> Supera el límite de tolerancia técnica u
              operativa; exige la activación de un plan de mejora formal.
            </span>
          </div>
        </div>
      </div>

      <div class="kpi-section-audiences-preview">
        <div class="section-head-flex">
          <div>
            <span class="kpi-subtitle-eyebrow">ÓRGANOS Y USUARIOS AUTORIZADOS</span>
            <h3>¿Quién podrá consultar el tablero de seguimiento?</h3>
            <p>
              La información de la cooperativa se organiza con distintos niveles de visibilidad para
              garantizar transparencia interna, resguardo de datos personales y seguimiento
              estatutario efectivo.
            </p>
          </div>
          <Button
            variant="outline"
            size="sm"
            class="btn-view-matrix"
            @click="activeTab = 'audiencias'"
          >
            <span>Ver Matriz Completa de Permisos</span>
            <ArrowRight :size="15" />
          </Button>
        </div>

        <div class="audiences-cards-grid">
          <div
            v-for="aud in audienceMatrix"
            :key="aud.id"
            :class="['audience-card', selectedAudience === aud.id ? 'selected-role' : '']"
            role="button"
            tabindex="0"
            @click="selectedAudience = aud.id"
            @keydown.enter="selectedAudience = aud.id"
          >
            <div class="aud-header">
              <span class="aud-badge">{{ aud.badge }}</span>
              <span v-if="selectedAudience === aud.id" class="active-tag">Vista Activa</span>
            </div>
            <h4>{{ aud.title }}</h4>
            <p>{{ aud.description }}</p>
            <div class="aud-footer">
              <span>
                <strong>Alcance:</strong> {{ aud.scope }}
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- VISTA 2: MATRIZ DE AUDIENCIAS Y PERMISOS DETALLADA -->
    <div v-if="activeTab === 'audiencias'" class="kpi-view-audiences">
      <div class="audience-explanation-box">
        <ShieldCheck :size="28" class="text-mint" />
        <div>
          <h3>Matriz Institucional de Audiencias y Permisos de Consulta</h3>
          <p>
            En cumplimiento de las normativas de gobernanza cooperativa y resguardo de datos
            escolares (anonimato estudiantil en Data Mining), se definen 4 perfiles diferenciados de
            consulta para el tablero:
          </p>
        </div>
      </div>

      <div class="audience-detail-list">
        <div v-for="aud in audienceMatrix" :key="aud.id" class="audience-detail-row">
          <div class="aud-detail-left">
            <span class="aud-badge-large">{{ aud.badge }}</span>
            <h4>{{ aud.title }}</h4>
            <p class="aud-scope-text">
              <strong>Ámbito:</strong> {{ aud.scope }}
            </p>
            <p class="aud-desc-text">{{ aud.description }}</p>

            <Button
              :variant="selectedAudience === aud.id ? 'default' : 'outline'"
              size="sm"
              class="mt-3"
              @click="
                selectedAudience = aud.id;
                activeTab = 'tablero';
              "
            >
              <Eye :size="14" />
              <span>
                {{
                  selectedAudience === aud.id
                    ? 'Vista Actualmente Seleccionada'
                    : `Simular Vista de ${aud.title.split(' ')[0] ?? aud.title}`
                }}
              </span>
            </Button>
          </div>

          <div class="aud-detail-right">
            <div class="permission-group">
              <h5>
                <CheckCircle2 :size="16" class="text-mint" />
                Permisos y Capacidades de Consulta
              </h5>
              <ul>
                <li v-for="(p, idx) in aud.permissions" :key="idx">{{ p }}</li>
              </ul>
            </div>

            <div v-if="aud.restricted.length > 0" class="restriction-group">
              <h5>
                <Lock :size="16" class="text-coral" />
                Restricciones y Protección de Datos
              </h5>
              <ul>
                <li v-for="(r, idx) in aud.restricted" :key="idx">{{ r }}</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- VISTA 3: CRITERIOS SEMAFÓRICOS & ACCESIBILIDAD -->
    <div v-if="activeTab === 'criterios'" class="kpi-view-criterios">
      <div class="accessibility-hero-box">
        <Scale :size="32" class="text-mint" />
        <div>
          <h3>Fundamentación de los Criterios Semafóricos y Accesibilidad Universal</h3>
          <p>
            Para garantizar que el tablero no dependa exclusivamente del canal cromático (en
            cumplimiento de las directrices WCAG 2.1 y la consigna del informe), cada estado visual
            combina un código de color normalizado con una
            <strong>etiqueta textual explícita</strong> y un
            <strong>símbolo geométrico representativo</strong>.
          </p>
        </div>
      </div>

      <div class="traffic-lights-grid">
        <div class="traffic-card green-card">
          <div class="traffic-card-top">
            <span class="traffic-circle green" />
            <div>
              <h4>VERDE — Óptimo / Cumplido</h4>
              <span class="traffic-status-tag">Rango de Desempeño Satisfactorio</span>
            </div>
          </div>
          <p class="traffic-concept">
            Representa el cumplimiento cabal de la meta pactada por la asamblea y el funcionamiento
            fluido del proceso sin desvíos técnicos.
          </p>
          <div class="traffic-rules-list">
            <strong>Criterios específicos por KPI:</strong>
            <ul>
              <li>
                <strong>TEUP (Uso PC):</strong> 75% a 85% de aprovechamiento del laboratorio de
                cómputo.
              </li>
              <li>
                <strong>IASS (Satisfacción):</strong> &gt;= 85.0% de valoración positiva docente.
              </li>
              <li>
                <strong>PDFT (Defectos QA):</strong> &lt;= 10.0% de casos con fallas en pruebas.
              </li>
              <li>
                <strong>IPEC (Participación):</strong> &gt;= 85.0% de socios activos con tareas al
                día.
              </li>
            </ul>
          </div>
          <div class="traffic-action-required">
            <strong>Acción de gestión:</strong> Sostener las buenas prácticas y documentar lecciones
            aprendidas.
          </div>
        </div>

        <div class="traffic-card yellow-card">
          <div class="traffic-card-top">
            <span class="traffic-circle yellow" />
            <div>
              <h4>AMARILLO — Alerta Preventiva</h4>
              <span class="traffic-status-tag">Rango de Precaución Temprana</span>
            </div>
          </div>
          <p class="traffic-concept">
            Señala un desvío moderado o una fluctuación estacional que no llega a bloquear las
            entregas pero que requiere observación rigurosa.
          </p>
          <div class="traffic-rules-list">
            <strong>Criterios específicos por KPI:</strong>
            <ul>
              <li>
                <strong>TEUP (Uso PC):</strong> 65% - 74% (subutilización) o 86% - 90% (inicio de
                saturación).
              </li>
              <li>
                <strong>IASS (Satisfacción):</strong> 75.0% a 84.9% (atención a observaciones de
                usuarios).
              </li>
              <li>
                <strong>PDFT (Defectos QA):</strong> 10.1% a 12.0% (alerta preventiva en
                validaciones).
              </li>
              <li>
                <strong>IPEC (Participación):</strong> 75.0% a 84.9% (riesgo incipiente de
                deserción).
              </li>
            </ul>
          </div>
          <div class="traffic-action-required">
            <strong>Acción de gestión:</strong> Tratamiento en comisión y advertencia preventiva en
            reunión de Consejo.
          </div>
        </div>

        <div class="traffic-card red-card">
          <div class="traffic-card-top">
            <span class="traffic-circle red" />
            <div>
              <h4>ROJO — Desvío Crítico</h4>
              <span class="traffic-status-tag">Rango de Intervención Inmediata</span>
            </div>
          </div>
          <p class="traffic-concept">
            Supera el umbral tolerable de seguridad técnica o sostenibilidad comunitaria. Exige la
            activación formal de una decisión correctiva.
          </p>
          <div class="traffic-rules-list">
            <strong>Criterios específicos por KPI:</strong>
            <ul>
              <li>
                <strong>TEUP (Uso PC):</strong> &lt;65% (ociosidad severa) o &gt;90% (riesgo grave
                de rotura de hardware sin mantenimiento).
              </li>
              <li>
                <strong>IASS (Satisfacción):</strong> &lt;75.0% (insatisfacción docente o rechazo de
                entrega).
              </li>
              <li>
                <strong>PDFT (Defectos QA):</strong> &gt;12.0% (inestabilidad de software, código no
                homologable).
              </li>
              <li>
                <strong>IPEC (Participación):</strong> &lt;75.0% (deserción estudiantil o parálisis
                de comisiones).
              </li>
            </ul>
          </div>
          <div class="traffic-action-required danger">
            <strong>Acción de gestión:</strong> Convocatoria urgente del Consejo e informe
            obligatorio a la Asamblea.
          </div>
        </div>
      </div>
    </div>

    <!-- VISTA 4: PLAN DE MEJORAS Y DECISIONES CORRECTIVAS -->
    <div v-if="activeTab === 'mejoras'" class="kpi-view-mejoras">
      <div class="mejoras-header-box">
        <Wrench :size="28" class="text-coral" />
        <div>
          <h3>Plan de Mejoras y Decisiones Correctivas Derivadas del Tablero</h3>
          <p>
            A partir de la simulación de octubre 2026, el tablero detectó un
            <strong>desvío crítico en PDFT (13.3%)</strong> y una
            <strong>oportunidad preventiva en IPEC (90.0% con ausencias focalizadas)</strong>. A
            continuación se presentan las decisiones adoptadas por el Consejo:
          </p>
        </div>
      </div>

      <div class="decisions-container">
        <div class="decision-card critical-decision">
          <div class="decision-badge-bar">
            <span class="badge-critical">DECISIÓN CORRECTIVA N° 1 · CRÍTICA</span>
            <span class="badge-target-kpi">KPI Afectado: PDFT (13.3% vs Meta &lt;= 10%)</span>
          </div>

          <h4>Mitigación de Defectos en Software y Blindaje de Pruebas</h4>

          <div class="decision-body-grid">
            <div>
              <strong>Diagnóstico que la fundamenta:</strong>
              <p>
                La tasa de fallas en QA alcanzó el 13.3%, superando el límite de control fijado en
                10.0%, concentrándose en errores de validación de formularios y defectos de
                maquetado responsivo al integrar PR-001 y PR-002.
              </p>

              <strong>Acciones Correctivas Inmediatas:</strong>
              <ol>
                <li>
                  <strong>Checklist de Pre-entrega:</strong> Ningún programador puede mover una
                  tarjeta de "En desarrollo" a "En pruebas" sin verificar 6 puntos básicos de
                  maquetado y validación.
                </li>
                <li>
                  <strong>Revisión Cruzada de Código (Peer Review):</strong> El código fuente debe
                  ser inspepcioando por un compañero de comisión antes de solicitar el testeo formal
                  a QA.
                </li>
                <li>
                  <strong>Plantillas de Validación Estándar:</strong> La Comisión de Documentación
                  redactará modelos estándar para captura de formularios.
                </li>
              </ol>
            </div>

            <div class="decision-side-panel">
              <div class="side-row">
                <span>Responsable:</span>
                <strong>Referente de Programación y Referente de QA</strong>
              </div>
              <div class="side-row">
                <span>Plazo de Remedición:</span>
                <strong>15 días hábiles (siguiente sprint quincenal)</strong>
              </div>
              <div class="side-row">
                <span>Meta de Corrección:</span>
                <strong class="text-mint">Descender PDFT por debajo del 9.0%</strong>
              </div>
            </div>
          </div>
        </div>

        <div class="decision-card preventive-decision">
          <div class="decision-badge-bar">
            <span class="badge-preventive">DECISIÓN PREVENTIVA N° 2 · ACOMPAÑAMIENTO</span>
            <span class="badge-target-kpi">
              KPI Afectado: IPEC (90.0% global, 2 ausencias focalizadas)
            </span>
          </div>

          <h4>Sostenibilidad del Compromiso Societario y Retención Democrática</h4>

          <div class="decision-body-grid">
            <div>
              <strong>Diagnóstico que la fundamenta:</strong>
              <p>
                Si bien el IPEC cumplió holgadamente la meta global (90.0%), el análisis
                pormenorizado detectó que 2 socios (S-07 y S-14) pertenecientes a la Comisión de
                Contenidos registraron inactividad continuada, configurando un riesgo de deserción
                focalizada.
              </p>

              <strong>Acciones Preventivas Propuestas:</strong>
              <ol>
                <li>
                  <strong>Protocolo Art. 5 del Reglamento:</strong> Apertura de un espacio de
                  diálogo fraternal para identificar causas de desmotivación o sobrecarga académica.
                </li>
                <li>
                  <strong>Rotación Voluntaria de Comisión:</strong> Ofrecer la oportunidad de
                  transferirse hacia áreas de Diseño o Comunicación Digital para reenganchar el
                  interés pedagógico.
                </li>
                <li>
                  <strong>Taller de Nivelación y Apoyo:</strong> Espacio de refuerzo guiado por la
                  Comisión Asesora Docente para despejar dudas técnicas.
                </li>
              </ol>
            </div>

            <div class="decision-side-panel">
              <div class="side-row">
                <span>Responsable:</span>
                <strong>Secretaría del Consejo y Docente Asesor/a</strong>
              </div>
              <div class="side-row">
                <span>Plazo de Remedición:</span>
                <strong>Al cierre del próximo mes (revisión de actas)</strong>
              </div>
              <div class="side-row">
                <span>Meta de Corrección:</span>
                <strong class="text-mint">100% de reincorporación activa sin deserciones</strong>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- MODAL DETALLE DE FICHA METODOLÓGICA Y MEMORIA DE CÁLCULO -->
    <div v-if="selectedKPI" class="overlay" @mousedown.self="selectedKPI = null">
      <div class="kpi-modal-dialog" role="dialog" aria-modal="true">
        <div class="modal-header">
          <div>
            <span class="modal-eyebrow">FICHA TÉCNICA METODOLÓGOLÓGICA (SECCIONES 4 Y 6)</span>
            <h2>{{ selectedKPI.name }}</h2>
            <span class="modal-category-tag">{{ selectedKPI.category }}</span>
          </div>
          <Button
            variant="ghost"
            size="icon"
            aria-label="Cerrar ficha"
            @click="selectedKPI = null"
          >
            <X :size="20" />
          </Button>
        </div>

        <div class="modal-body-content">
          <div class="modal-stat-strip">
            <div class="stat-box">
              <span>Valor Actual (Octubre)</span>
              <strong :class="['stat-num', selectedKPI.statusType]">
                {{ selectedKPI.formattedValue }}
              </strong>
            </div>
            <div class="stat-box">
              <span>Meta Pautada</span>
              <strong class="stat-num">{{ selectedKPI.target }}</strong>
            </div>
            <div class="stat-box">
              <span>Estado Visual</span>
              <span :class="['modal-status-badge', selectedKPI.statusType]">
                {{ selectedKPI.statusLabel }}
              </span>
            </div>
            <div class="stat-box">
              <span>Temporalidad</span>
              <strong>{{ selectedKPI.temporality }}</strong>
            </div>
          </div>

          <div class="calc-breakdown-card">
            <h4>
              <Compass :size="17" class="text-mint" />
              Memoria de Cálculo de la Simulación (Período:
              {{ selectedKPI.calculationBreakdown.period }})
            </h4>
            <div class="calc-formula-display">
              <code>{{ selectedKPI.calculationBreakdown.math }}</code>
            </div>
            <div class="calc-details-grid">
              <div>
                <span>Numerador aplicado:</span>
                <p>{{ selectedKPI.calculationBreakdown.numerator }}</p>
              </div>
              <div>
                <span>Denominador disponible:</span>
                <p>{{ selectedKPI.calculationBreakdown.denominator }}</p>
              </div>
            </div>
            <p class="calc-conclusion">
              <strong>Interpretación del resultado:</strong>
              {{ selectedKPI.calculationBreakdown.detail }}
            </p>
          </div>

          <div class="kpi-spec-table-wrap">
            <table class="kpi-spec-table">
              <tbody>
                <tr>
                  <th>Fórmula Matemática</th>
                  <td>
                    <code>{{ selectedKPI.formula }}</code>
                  </td>
                </tr>
                <tr>
                  <th>Criterios Semafóricos</th>
                  <td>
                    <div class="criteria-modal-list">
                      <span class="text-mint">{{ selectedKPI.criteriaText.green }}</span>
                      <span class="text-sun">{{ selectedKPI.criteriaText.yellow }}</span>
                      <span class="text-coral">{{ selectedKPI.criteriaText.red }}</span>
                    </div>
                  </td>
                </tr>
                <tr>
                  <th>Fuente de Datos</th>
                  <td>{{ selectedKPI.dataSource }}</td>
                </tr>
                <tr>
                  <th>Frecuencia de Revisión</th>
                  <td>{{ selectedKPI.frequency }}</td>
                </tr>
                <tr>
                  <th>Rol Responsable</th>
                  <td>{{ selectedKPI.responsible }}</td>
                </tr>
                <tr>
                  <th>Tratamiento de Denominador Cero</th>
                  <td>{{ selectedKPI.zeroDenominator }}</td>
                </tr>
                <tr>
                  <th>Justificación Teórica &amp; Temporalidad</th>
                  <td>{{ selectedKPI.temporalityReason }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-if="selectedKPI.actionPlan" class="modal-action-plan">
            <div class="action-plan-top">
              <AlertTriangle :size="18" class="text-coral" />
              <strong>{{ selectedKPI.actionPlan.title }}</strong>
            </div>
            <p>{{ selectedKPI.actionPlan.rationale }}</p>
            <ul>
              <li v-for="(act, i) in selectedKPI.actionPlan.actions" :key="i">{{ act }}</li>
            </ul>
            <div class="action-plan-meta">
              <span>
                <strong>Responsable:</strong> {{ selectedKPI.actionPlan.responsible }}
              </span>
              <span>
                <strong>Plazo:</strong> {{ selectedKPI.actionPlan.deadline }}
              </span>
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <Button variant="outline" @click="selectedKPI = null">
            Cerrar Ficha
          </Button>
        </div>
      </div>
    </div>
  </div>
</template>
