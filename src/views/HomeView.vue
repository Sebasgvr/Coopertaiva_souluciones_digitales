<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import {
  AlertTriangle,
  ArrowRight,
  ArrowUpRight,
  BarChart3,
  Bell,
  BookOpen,
  CalendarDays,
  Check,
  CheckCircle2,
  ChevronRight,
  ClipboardList,
  Clock3,
  Code2,
  Edit3,
  FileText,
  Folders,
  HeartHandshake,
  LayoutDashboard,
  LayoutGrid,
  List,
  Loader2,
  Menu,
  MessageCircle,
  MoreHorizontal,
  Plus,
  RotateCcw,
  Search,
  ShieldCheck,
  Sparkles,
  UserCheck,
  Users,
  X,
  XCircle,
} from 'lucide-vue-next'
import Button from '../components/ui/Button.vue'
import KPITrackingDashboard from '../components/KPITrackingDashboard.vue'
import ProjectGlyph from '../components/ProjectGlyph.vue'
import {
  ROLES_COOPERATIVA,
  INITIAL_REQUESTS,
  INITIAL_PROJECTS,
  INITIAL_TASKS,
  INITIAL_QA_TESTS,
  INITIAL_ACTAS,
  INITIAL_AUDIT_LOGS,
} from '../data/cooperativaModels.js'
import {
  getSupabaseConfig,
  fetchAllFromSupabase,
  insertSolicitudSupabase,
  updateSolicitudSupabase,
  insertProjectSupabase,
  updateProjectSupabase,
} from '../lib/supabase.js'

const commissions = [
  {
    id: 'COM-01',
    name: 'Programación',
    desc: 'Construye y mantiene las soluciones digitales.',
    functions:
      'Lógica de negocio, arquitectura de software, codificación frontend/backend e integración con Supabase (Art. 4 inc. a).',
    icon: Code2,
    tone: 'mint',
    count: '6 integrantes',
    lead: 'Martina L. (S-01)',
    initials: ['ML', 'JC', 'AR', '+3'],
  },
  {
    id: 'COM-02',
    name: 'Diseño y experiencia',
    desc: 'Da forma a interfaces claras y accesibles.',
    functions:
      'Maqueta estética, tipografías, paleta de color, prototipado responsivo para PC y celulares (Art. 4 inc. b).',
    icon: LayoutGrid,
    tone: 'coral',
    count: '4 integrantes',
    lead: 'Sofía F. (S-02)',
    initials: ['SF', 'EV', 'NS', '+1'],
  },
  {
    id: 'COM-03',
    name: 'Contenidos',
    desc: 'Organiza la información y cuida las palabras.',
    functions:
      'Relevamiento de requerimientos docentes, estructuración de la información y redacción institucional (Art. 4 inc. c).',
    icon: FileText,
    tone: 'sun',
    count: '3 integrantes',
    lead: 'Elena V. (S-03)',
    initials: ['EV', 'LP', 'CM'],
  },
  {
    id: 'COM-04',
    name: 'Pruebas y calidad',
    desc: 'Verifica que todo funcione antes de entregar.',
    functions:
      'Ejecución de casos de testeo en diferentes dispositivos, detección de bugs y homologación QA (Art. 4 inc. d).',
    icon: ShieldCheck,
    tone: 'lilac',
    count: '4 integrantes',
    lead: 'Agustín R. (S-04)',
    initials: ['AR', 'AT', 'JC', '+1'],
  },
  {
    id: 'COM-05',
    name: 'Comunicación',
    desc: 'Comparte los proyectos con la comunidad escolar.',
    functions:
      'Difusión de herramientas, tutoriales breves, muestras anuales y encuestas de satisfacción IASS (Art. 4 inc. e).',
    icon: MessageCircle,
    tone: 'mint',
    count: '3 integrantes',
    lead: 'Lucía P. (S-05)',
    initials: ['LP', 'SF', 'NS'],
  },
  {
    id: 'COM-06',
    name: 'Documentación y soporte',
    desc: 'Conserva la memoria y acompaña cada entrega.',
    functions:
      'Archivo de código, manuales de uso para docentes, plantillas de validación y actas de entrega (Art. 4 inc. f).',
    icon: BookOpen,
    tone: 'coral',
    count: '3 integrantes',
    lead: 'Camila M. (S-06)',
    initials: ['CM', 'ML', 'AT'],
  },
]

const nav = [
  { id: 'inicio', label: 'Inicio', icon: LayoutDashboard },
  { id: 'solicitudes', label: 'Solicitudes', icon: ClipboardList },
  { id: 'proyectos', label: 'Proyectos', icon: Folders },
  { id: 'comisiones', label: 'Comisiones', icon: Users },
  { id: 'asamblea', label: 'Asamblea y actas', icon: HeartHandshake },
  { id: 'tablero', label: 'Tablero KPI (BSC)', icon: BarChart3 },
]

const titles = {
  inicio: {
    eyebrow: 'ESPACIO DE TRABAJO',
    title: 'Buen día, equipo.',
    subtitle: 'Así avanzan las ideas que estamos construyendo juntos.',
  },
  solicitudes: {
    eyebrow: 'BANDEJA DE ENTRADA',
    title: 'Solicitudes',
    subtitle: 'Necesidades de la escuela, listas para convertirse en soluciones.',
  },
  proyectos: {
    eyebrow: 'NUESTRO TRABAJO',
    title: 'Proyectos',
    subtitle: 'De la primera idea hasta la entrega a la comunidad.',
  },
  comisiones: {
    eyebrow: 'PERSONAS Y EQUIPOS',
    title: 'Comisiones',
    subtitle: 'Distintos saberes, un mismo propósito.',
  },
  asamblea: {
    eyebrow: 'DECISIONES COMPARTIDAS',
    title: 'Asamblea y actas',
    subtitle:
      'Acuerdos abiertos e historial inmutable para construir una cooperativa transparente.',
  },
  tablero: {
    eyebrow: 'PUNTO 8 · SEGUIMIENTO ESTRATÉGICO',
    title: 'Tablero de Seguimiento (BSC)',
    subtitle:
      'Monitoreo en tiempo real de los 4 KPI, metas, resultados y matriz de audiencias institucionales.',
  },
}

function getStatusKind(value) {
  return value === 'Finalizado' || value === 'Aprobada' || value === 'Completada'
    ? 'done'
    : value === 'En desarrollo' || value === 'En revisión' || value === 'En curso'
      ? 'active'
      : value === 'En pruebas' || value === 'En revisión QA'
        ? 'testing'
        : 'waiting'
}

const LOCAL_STORAGE_KEY = 'cooperativa_escolar_state_v1'

const view = ref('inicio')
const currentRole = ref('consejo_administracion')
const requests = ref([...INITIAL_REQUESTS])
const projects = ref([...INITIAL_PROJECTS])
const tasks = ref([...INITIAL_TASKS])
const qaTests = ref([...INITIAL_QA_TESTS])
const actas = ref([...INITIAL_ACTAS])
const auditLogs = ref([...INITIAL_AUDIT_LOGS])

const filter = ref('Todas')
const typeFilter = ref('Todos')
const query = ref('')
const board = ref(false)

// Modales y diálogos
const modal = ref(false)
const editingRequestId = ref(null)
const cancelTargetRequest = ref(null)
const cancelReasonInput = ref('')
const selectedProject = ref(null)
const selectedCommission = ref(null)
const actaModal = ref(false)
const qaModal = ref(false)

const mobileNav = ref(false)
const notification = ref(false)

// Estado de carga, confirmación y error (Punto 16)
const isLoadingOp = ref(false)
const feedbackBanner = ref(null)
const isSupabaseConnected = ref(false)

// Formulario de solicitud con validación (Punto 5)
const form = ref({
  title: '',
  from: '',
  type: 'Formulario',
  targetDate: '2026-11-15',
  priority: 'Media',
  description: '',
})
const formErrors = ref({})

// Formulario de nueva Acta
const actaForm = ref({
  title: '',
  type: 'Asamblea General Ordinaria',
  date: '29 OCT',
  attendees: 19,
  detail: '',
  agreements: '',
})
const actaError = ref('')

// Formulario de caso de prueba QA
const qaForm = ref({
  projectId: 'PR-002',
  type: 'Validación de campos',
  casesExecuted: 10,
  bugsFound: 1,
  description: '',
})
const qaError = ref('')

const roleDef = computed(
  () => ROLES_COOPERATIVA.find((r) => r.id === currentRole.value) ?? ROLES_COOPERATIVA[0]
)

function showFeedback(type, message) {
  feedbackBanner.value = { type, message }
  if (type !== 'loading') {
    setTimeout(() => {
      if (feedbackBanner.value?.message === message) {
        feedbackBanner.value = null
      }
    }, 5500)
  }
}

async function syncFromSupabaseIfConfigured() {
  const cfg = getSupabaseConfig()
  if (!cfg.isConfigured) {
    isSupabaseConnected.value = false
    return
  }
  isLoadingOp.value = true
  const data = await fetchAllFromSupabase()
  isLoadingOp.value = false
  if (data.error) {
    isSupabaseConnected.value = false
    showFeedback(
      'error',
      `Aviso de conexión Supabase: ${data.error} (Usando datos de prueba locales)`
    )
    return
  }
  isSupabaseConnected.value = true
  if (data.solicitudes && data.solicitudes.length > 0) requests.value = data.solicitudes
  if (data.proyectos && data.proyectos.length > 0) projects.value = data.proyectos
  if (data.tareas && data.tareas.length > 0) tasks.value = data.tareas
  if (data.pruebasQA && data.pruebasQA.length > 0) qaTests.value = data.pruebasQA
  if (data.actas && data.actas.length > 0) actas.value = data.actas
  if (data.historial && data.historial.length > 0) auditLogs.value = data.historial
  showFeedback('success', 'Datos sincronizados en tiempo real desde Supabase PostgreSQL.')
}

onMounted(() => {
  try {
    const raw = window.localStorage.getItem(LOCAL_STORAGE_KEY)
    if (raw) {
      const parsed = JSON.parse(raw)
      if (Array.isArray(parsed.requests)) requests.value = parsed.requests
      if (Array.isArray(parsed.projects)) projects.value = parsed.projects
      if (Array.isArray(parsed.tasks)) tasks.value = parsed.tasks
      if (Array.isArray(parsed.qaTests)) qaTests.value = parsed.qaTests
      if (Array.isArray(parsed.actas)) actas.value = parsed.actas
      if (Array.isArray(parsed.auditLogs)) auditLogs.value = parsed.auditLogs
      if (parsed.currentRole) currentRole.value = parsed.currentRole
    }
  } catch {
    // Fallback silencioso a datos iniciales
  }
  syncFromSupabaseIfConfigured()
})

watch(
  [requests, projects, tasks, qaTests, actas, auditLogs, currentRole],
  () => {
    try {
      window.localStorage.setItem(
        LOCAL_STORAGE_KEY,
        JSON.stringify({
          requests: requests.value,
          projects: projects.value,
          tasks: tasks.value,
          qaTests: qaTests.value,
          actas: actas.value,
          auditLogs: auditLogs.value,
          currentRole: currentRole.value,
        })
      )
    } catch {
      // Ignorar si storage está lleno
    }
  },
  { deep: true }
)

function appendAuditLog(entity, recordId, action, previousState, newState, detail) {
  const now = new Date()
  const formattedTime = now.toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' })
  const newEntry = {
    id: `LOG-${String(auditLogs.value.length + 101)}`,
    entity,
    recordId,
    action,
    previousState,
    newState,
    detail,
    user: roleDef.value.simulatedUser,
    role: roleDef.value.label,
    timestamp: `Hoy · ${formattedTime} h`,
  }
  auditLogs.value = [newEntry, ...auditLogs.value]
}

function handleResetDemoData() {
  requests.value = [...INITIAL_REQUESTS]
  projects.value = [...INITIAL_PROJECTS]
  tasks.value = [...INITIAL_TASKS]
  qaTests.value = [...INITIAL_QA_TESTS]
  actas.value = [...INITIAL_ACTAS]
  auditLogs.value = [...INITIAL_AUDIT_LOGS]
  window.localStorage.removeItem(LOCAL_STORAGE_KEY)
  showFeedback('success', 'Datos de prueba restaurados a su estado original del informe.')
}

function changeView(next) {
  view.value = next
  mobileNav.value = false
  query.value = ''
  filter.value = 'Todas'
  typeFilter.value = 'Todos'
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

function handleRoleChange(nextRole) {
  currentRole.value = nextRole
  const nextDef = ROLES_COOPERATIVA.find((r) => r.id === nextRole)
  showFeedback(
    'success',
    `Vista y permisos cambiados al rol simulado: ${nextDef?.label ?? nextRole}`
  )
}

// Validación estricta del formulario de Solicitud (Punto 5)
function validateSolicitudForm() {
  const errors = {}
  const allowedTypes = ['Sitio web', 'Formulario', 'Aplicación informativa', 'Herramienta']

  if (!form.value.title.trim()) {
    errors.title = 'El nombre de la solicitud es obligatorio.'
  } else if (form.value.title.trim().length < 5 || form.value.title.trim().length > 140) {
    errors.title = 'El nombre debe tener entre 5 y 140 caracteres.'
  }

  if (!form.value.from.trim()) {
    errors.from = 'El área, departamento o persona solicitante es obligatorio.'
  } else if (form.value.from.trim().length < 3) {
    errors.from = 'Indicá un nombre de departamento o docente válido (mínimo 3 caracteres).'
  }

  if (!allowedTypes.includes(form.value.type)) {
    errors.type = 'Seleccioná un tipo de solución permitido por el Reglamento (Art. 2).'
  }

  if (!form.value.targetDate) {
    errors.targetDate = 'Indicá la fecha estimada o límite en que se necesita la solución.'
  }

  if (!form.value.description.trim()) {
    errors.description = 'La descripción del problema o necesidad es obligatoria.'
  } else if (form.value.description.trim().length < 15) {
    errors.description =
      'Describí el contexto con al menos 15 caracteres para que el Consejo pueda evaluarla.'
  }

  formErrors.value = errors
  return Object.keys(errors).length === 0
}

function openNewRequestModal() {
  if (!roleDef.value.permissions.canCreateRequest) {
    showFeedback(
      'error',
      `El rol actual (${roleDef.value.shortLabel}) es de consulta/fiscalización. Cambiá al rol "Solicitante externo" o "Consejo" para cargar solicitudes.`
    )
    return
  }
  editingRequestId.value = null
  form.value = {
    title: '',
    from: currentRole.value === 'solicitante_externo' ? 'Departamento de Ciencias' : '',
    type: 'Formulario',
    targetDate: '2026-11-15',
    priority: 'Media',
    description: '',
  }
  formErrors.value = {}
  modal.value = true
}

function openEditRequestModal(req) {
  editingRequestId.value = req.id
  form.value = {
    title: req.title,
    from: req.from,
    type: req.type,
    targetDate: req.targetDate || '2026-11-15',
    priority: req.priority || 'Media',
    description: req.description,
  }
  formErrors.value = {}
  modal.value = true
}

async function submitRequest() {
  if (!validateSolicitudForm()) {
    showFeedback('error', 'Revisá los campos marcados en rojo antes de enviar el formulario.')
    return
  }

  isLoadingOp.value = true
  showFeedback('loading', 'Registrando operación y validando permisos...')

  if (editingRequestId.value) {
    const prev = requests.value.find((r) => r.id === editingRequestId.value)
    requests.value = requests.value.map((r) =>
      r.id === editingRequestId.value
        ? {
            ...r,
            title: form.value.title.trim(),
            from: form.value.from.trim(),
            type: form.value.type,
            targetDate: form.value.targetDate,
            priority: form.value.priority,
            description: form.value.description.trim(),
          }
        : r
    )
    await updateSolicitudSupabase(editingRequestId.value, {
      title: form.value.title.trim(),
      from: form.value.from.trim(),
      type: form.value.type,
      description: form.value.description.trim(),
    })
    appendAuditLog(
      'Solicitudes',
      editingRequestId.value,
      'MODIFICACIÓN',
      prev?.status || 'Por evaluar',
      prev?.status || 'Por evaluar',
      `Actualización de datos en solicitud '${form.value.title.trim()}' (${form.value.from.trim()}).`
    )
    isLoadingOp.value = false
    modal.value = false
    showFeedback('success', `Solicitud ${editingRequestId.value} modificada correctamente.`)
    return
  }

  const nextNumber = requests.value.length + 11
  const newId = `SOL-${String(nextNumber).padStart(3, '0')}`
  const newReq = {
    id: newId,
    title: form.value.title.trim(),
    from: form.value.from.trim(),
    solicitanteCode: roleDef.value.simulatedCode,
    type: form.value.type,
    description: form.value.description.trim(),
    targetDate: form.value.targetDate,
    priority: form.value.priority,
    date: 'Ahora',
    status: 'Por evaluar',
  }

  const dbRes = await insertSolicitudSupabase(newReq)
  isLoadingOp.value = false
  if (dbRes.error) {
    showFeedback('error', `Error en base de datos: ${dbRes.error}`)
    return
  }

  requests.value = [newReq, ...requests.value]
  appendAuditLog(
    'Solicitudes',
    newId,
    'CREACIÓN',
    '—',
    'Por evaluar',
    `Nueva solicitud '${newReq.title}' cargada por ${newReq.from} (${newReq.type}).`
  )
  modal.value = false
  changeView('solicitudes')
  showFeedback('success', `Solicitud ${newId} creada con éxito y registrada en estado "Por evaluar".`)
}

// Cambio de estado de solicitud por el Consejo (Punto 8 y 15)
async function handleRequestStateChange(req, nextStatus) {
  if (!roleDef.value.permissions.canEvaluateRequest) {
    showFeedback(
      'error',
      `Permiso denegado: Solo el Consejo de Administración puede cambiar el estado a "${nextStatus}".`
    )
    return
  }
  isLoadingOp.value = true
  const oldStatus = req.status
  requests.value = requests.value.map((r) => (r.id === req.id ? { ...r, status: nextStatus } : r))
  await updateSolicitudSupabase(req.id, { status: nextStatus })
  isLoadingOp.value = false

  appendAuditLog(
    'Solicitudes',
    req.id,
    'CAMBIO DE ESTADO',
    oldStatus,
    nextStatus,
    `El Consejo evaluó la solicitud '${req.title}' y cambió su estado de '${oldStatus}' a '${nextStatus}'.`
  )
  showFeedback('success', `Estado de ${req.id} actualizado a "${nextStatus}" y asentado en el historial.`)
}

// Cancelación lógica conservando el historial (Punto 8)
async function confirmCancelRequest() {
  if (!cancelTargetRequest.value) return
  if (cancelReasonInput.value.trim().length < 8) {
    showFeedback(
      'error',
      'Indicá un motivo de cancelación claro (mínimo 8 caracteres) para el historial.'
    )
    return
  }

  const target = cancelTargetRequest.value
  const oldStatus = target.status
  const reason = cancelReasonInput.value.trim()
  isLoadingOp.value = true
  requests.value = requests.value.map((r) =>
    r.id === target.id ? { ...r, status: 'Cancelada', cancelReason: reason } : r
  )
  await updateSolicitudSupabase(target.id, { status: 'Cancelada', cancelReason: reason })
  isLoadingOp.value = false

  appendAuditLog(
    'Solicitudes',
    target.id,
    'CANCELACIÓN (HISTORIAL CONSERVADO)',
    oldStatus,
    'Cancelada',
    `Cancelación lógica sin borrado físico. Motivo: ${reason}`
  )
  cancelTargetRequest.value = null
  cancelReasonInput.value = ''
  showFeedback(
    'success',
    `Solicitud ${target.id} marcada como "Cancelada". Se conservó el registro en el historial de auditoría.`
  )
}

// Convertir una Solicitud Aprobada en Proyecto del Tablero (Recorrido Punto 3 y 8)
async function handleConvertRequestToProject(req) {
  if (!roleDef.value.permissions.canEvaluateRequest) {
    showFeedback(
      'error',
      'Solo el Consejo de Administración puede convertir solicitudes aprobadas en proyectos.'
    )
    return
  }
  const existing = projects.value.find(
    (p) => p.solicitudId === req.id || p.name.toLowerCase() === req.title.toLowerCase()
  )
  if (existing) {
    showFeedback('error', `Esta solicitud ya está vinculada al proyecto ${existing.id}.`)
    return
  }

  const tones = ['mint', 'coral', 'sun', 'lilac']
  const newProjId = `PR-${String(projects.value.length + 1).padStart(3, '0')}`
  const newProject = {
    id: newProjId,
    solicitudId: req.id,
    name: req.title,
    description: req.description,
    category: req.type,
    status: 'Por comenzar',
    progress: 10,
    tone: tones[projects.value.length % tones.length] ?? 'mint',
    initials: ['ML', 'SF', 'EV'],
    date: req.targetDate ? req.targetDate.slice(5) : '15 nov',
    commission: req.type === 'Formulario' ? 'Programación + Pruebas' : 'Programación + Diseño',
    hoursPc: 4,
    bugsCount: 0,
    testCasesCount: 0,
  }

  isLoadingOp.value = true
  await insertProjectSupabase(newProject)
  isLoadingOp.value = false

  projects.value = [newProject, ...projects.value]
  appendAuditLog(
    'Proyectos',
    newProjId,
    'CREACIÓN',
    `Solicitud ${req.id} (Aprobada)`,
    'Por comenzar (10%)',
    `El Consejo convirtió la solicitud ${req.id} ('${req.title}') en el proyecto ${newProjId} asignado a ${newProject.commission}.`
  )
  changeView('proyectos')
  showFeedback('success', `Solicitud ${req.id} convertida en el proyecto ${newProjId} ("Por comenzar").`)
}

// Actualizar estado y progreso de un Proyecto (Punto 8)
async function handleUpdateProjectStage(proj, nextStage, nextProgress) {
  if (!roleDef.value.permissions.canUpdateProjectStatus) {
    showFeedback(
      'error',
      `El rol actual (${roleDef.value.shortLabel}) no tiene permisos para mover tarjetas del tablero de proyectos.`
    )
    return
  }

  const oldStage = proj.status
  isLoadingOp.value = true
  const updated = { ...proj, status: nextStage, progress: nextProgress }
  projects.value = projects.value.map((p) => (p.id === proj.id ? updated : p))
  selectedProject.value = updated
  await updateProjectSupabase(proj.id, { status: nextStage, progress: nextProgress })
  isLoadingOp.value = false

  appendAuditLog(
    'Proyectos',
    proj.id,
    'CAMBIO DE ESTADO',
    `${oldStage} (${proj.progress}%)`,
    `${nextStage} (${nextProgress}%)`,
    `Actualización de avance en '${proj.name}' por ${roleDef.value.simulatedUser}.`
  )
  showFeedback('success', `Proyecto ${proj.id} actualizado a "${nextStage}" (${nextProgress}% completado).`)
}

// Cambiar estado de una Tarea del Sprint Backlog
function handleCycleTaskStatus(task) {
  if (!roleDef.value.permissions.canManageTasks) {
    showFeedback(
      'error',
      'Solo los Socios, Referentes y el Consejo pueden actualizar tareas del Sprint Backlog.'
    )
    return
  }
  const order = ['Pendiente', 'En curso', 'En revisión QA', 'Completada']
  const nextIdx = (order.indexOf(task.status) + 1) % order.length
  const nextStatus = order[nextIdx] ?? 'En curso'
  tasks.value = tasks.value.map((t) => (t.id === task.id ? { ...t, status: nextStatus } : t))
  appendAuditLog(
    'Tareas',
    task.id,
    'CAMBIO DE ESTADO',
    task.status,
    nextStatus,
    `Tarea '${task.title}' (${task.projectId}) movida a '${nextStatus}'.`
  )
  showFeedback('success', `Tarea ${task.id} actualizada a "${nextStatus}".`)
}

// Registrar nuevo Caso de Prueba / Bug QA (Situación de Uso 2 y KPI PDFT)
function handleCreateQATest() {
  if (qaForm.value.description.trim().length < 10) {
    qaError.value = 'Describí el caso probado o el error detectado (mínimo 10 caracteres).'
    return
  }
  if (
    qaForm.value.casesExecuted < 1 ||
    qaForm.value.bugsFound < 0 ||
    qaForm.value.bugsFound > qaForm.value.casesExecuted
  ) {
    qaError.value = 'La cantidad de fallas no puede ser negativa ni superar los casos ejecutados.'
    return
  }
  const targetProj = projects.value.find((p) => p.id === qaForm.value.projectId)
  const newQa = {
    id: `QA-00${qaTests.value.length + 1}`,
    projectId: qaForm.value.projectId,
    projectName: targetProj?.name || qaForm.value.projectId,
    type: qaForm.value.type,
    description: qaForm.value.description.trim(),
    casesExecuted: Number(qaForm.value.casesExecuted),
    bugsFound: Number(qaForm.value.bugsFound),
    status: qaForm.value.bugsFound > 0 ? 'Bug detectado' : 'Aprobado sin fallas',
    reportedBy: roleDef.value.simulatedUser,
    date: 'Hoy',
  }
  qaTests.value = [newQa, ...qaTests.value]
  appendAuditLog(
    'Pruebas QA',
    newQa.id,
    'CREACIÓN',
    '—',
    `${newQa.bugsFound} bugs / ${newQa.casesExecuted} pruebas`,
    `Reporte QA en ${newQa.projectId}: ${newQa.description}`
  )
  qaModal.value = false
  qaForm.value = { ...qaForm.value, description: '' }
  qaError.value = ''
  showFeedback(
    'success',
    `Reporte de pruebas ${newQa.id} registrado correctamente en la matriz de calidad.`
  )
}

// Publicar nueva Acta de Asamblea (Punto 8)
function handleCreateActa() {
  if (!roleDef.value.permissions.canPublishActa) {
    actaError.value = 'Solo Secretaría / Consejo de Administración puede redactar y publicar actas.'
    return
  }
  if (actaForm.value.title.trim().length < 5 || actaForm.value.agreements.trim().length < 15) {
    actaError.value = 'Completá el título y los acuerdos votados (mínimo 15 caracteres).'
    return
  }
  const newActa = {
    id: `ACT-00${actas.value.length + 1}`,
    date: actaForm.value.date.trim().toUpperCase(),
    title: actaForm.value.title.trim(),
    type: actaForm.value.type,
    detail:
      actaForm.value.detail.trim() || 'Sesión ordinaria registrada en el Libro de Actas digital.',
    agreements: actaForm.value.agreements.trim(),
    attendees: Number(actaForm.value.attendees),
    totalMembers: 20,
    status: 'Publicada',
  }
  actas.value = [newActa, ...actas.value]
  appendAuditLog(
    'Asambleas y Actas',
    newActa.id,
    'CREACIÓN',
    'Borrador',
    'Publicada',
    `Publicación oficial de ${newActa.title} (${newActa.attendees}/20 socios presentes).`
  )
  actaModal.value = false
  actaError.value = ''
  actaForm.value = {
    title: '',
    type: 'Asamblea General Ordinaria',
    date: '29 OCT',
    attendees: 19,
    detail: '',
    agreements: '',
  }
  showFeedback(
    'success',
    `Acta ${newActa.id} publicada en el Libro de Actas (protegida contra borrado).`
  )
}

// Filtros combinados y control de visibilidad por Rol (Puntos 4, 9 y 15)
const visibleRequests = computed(() =>
  requests.value.filter((r) => {
    if (currentRole.value === 'comunidad_escolar' && r.status !== 'Aprobada') return false
    const matchStatus = filter.value === 'Todas' || r.status === filter.value
    const matchType = typeFilter.value === 'Todos' || r.type === typeFilter.value
    const matchQuery = `${r.id} ${r.title} ${r.from} ${r.type} ${r.description}`
      .toLowerCase()
      .includes(query.value.toLowerCase())
    return matchStatus && matchType && matchQuery
  })
)

const visibleProjects = computed(() =>
  projects.value.filter((p) => {
    if (currentRole.value === 'comunidad_escolar' && p.status !== 'Finalizado') return false
    const matchStatus = filter.value === 'Todas' || p.status === filter.value
    const matchType = typeFilter.value === 'Todos' || p.category === typeFilter.value
    const matchQuery = `${p.id} ${p.name} ${p.category} ${p.commission}`
      .toLowerCase()
      .includes(query.value.toLowerCase())
    return matchStatus && matchType && matchQuery
  })
)

const selectedCommissionObj = computed(() =>
  commissions.find((c) => c.name === selectedCommission.value)
)
</script>

<template>
  <div class="app-shell">
    <aside :class="['sidebar', mobileNav ? 'sidebar-open' : '']">
      <div
        class="brand"
        role="button"
        tabindex="0"
        @click="changeView('inicio')"
        @keydown.enter="changeView('inicio')"
      >
        <span class="brand-mark">
          <span />
          <span />
          <span />
          <span />
        </span>
        <span class="brand-copy">
          cooperativa<span>digital</span>
        </span>
      </div>
      <div class="sidebar-rule" />
      <div class="workspace-label">ESPACIO DE TRABAJO</div>
      <nav class="nav-list" aria-label="Navegación principal">
        <Button
          v-for="item in nav"
          :key="item.id"
          variant="ghost"
          :class="['nav-item', view === item.id ? 'nav-item-active' : '']"
          @click="changeView(item.id)"
        >
          <component :is="item.icon" :size="19" :stroke-width="1.8" />
          <span>{{ item.label }}</span>
          <span v-if="item.id === 'solicitudes'" class="nav-count">
            {{ requests.filter((r) => r.status === 'Por evaluar').length }}
          </span>
        </Button>
      </nav>

      <div class="sidebar-bottom">
        <div class="sidebar-note">
          <span class="note-icon">
            <Sparkles :size="17" />
          </span>
          <strong>Rol Simulado Activo (Pto. 4):</strong>
          <p style="margin-bottom: 8px">{{ roleDef.label }}</p>
          <select
            aria-label="Cambiar rol simulado"
            :value="currentRole"
            style="
              width: 100%;
              padding: 6px 8px;
              border-radius: 5px;
              font-size: 11px;
              font-weight: 700;
              background: var(--card);
              color: var(--foreground);
              border: 1px solid var(--border);
            "
            @change="handleRoleChange($event.target.value)"
          >
            <option v-for="r in ROLES_COOPERATIVA" :key="r.id" :value="r.id">
              {{ r.shortLabel }} ({{ r.simulatedCode }})
            </option>
          </select>
        </div>
        <div
          class="sidebar-user"
          role="button"
          tabindex="0"
          title="Ver actas e historial de auditoría"
          @click="changeView('asamblea')"
        >
          <span class="user-avatar">{{ roleDef.avatarInitials }}</span>
          <span>
            <strong>{{ roleDef.simulatedUser }}</strong>
            <small>Rol simulado · {{ roleDef.shortLabel }}</small>
          </span>
          <MoreHorizontal :size="18" />
        </div>
      </div>
    </aside>

    <div class="main-shell">
      <header class="topbar">
        <div class="topbar-left">
          <Button
            variant="ghost"
            size="icon"
            class="mobile-menu"
            aria-label="Abrir menú"
            @click="mobileNav = !mobileNav"
          >
            <X v-if="mobileNav" />
            <Menu v-else />
          </Button>
          <span class="breadcrumb">Cooperativa escolar</span>
          <ChevronRight :size="15" class="breadcrumb-chevron" />
          <strong>{{ nav.find((n) => n.id === view)?.label }}</strong>
        </div>

        <div class="topbar-actions">
          <div
            style="
              display: flex;
              align-items: center;
              gap: 6px;
              background: var(--muted);
              padding: 4px 10px;
              border-radius: 6px;
              border: 1px solid var(--border);
              font-size: 11px;
            "
          >
            <UserCheck :size="14" class="text-primary" />
            <span style="color: var(--muted-foreground); font-weight: 600">Rol simulado:</span>
            <select
              aria-label="Selector de rol en barra superior"
              :value="currentRole"
              style="
                background: transparent;
                border: 0;
                font-weight: 800;
                color: var(--foreground);
                outline: none;
                cursor: pointer;
              "
              @change="handleRoleChange($event.target.value)"
            >
              <option v-for="r in ROLES_COOPERATIVA" :key="r.id" :value="r.id">
                {{ r.shortLabel }}
              </option>
            </select>
          </div>

          <div
            class="sample-label"
            :style="{
              background: isSupabaseConnected ? 'var(--mint-light)' : 'var(--sun-light)',
              padding: '5px 10px',
              borderRadius: '5px',
              border: '1px solid var(--border)',
              color: 'var(--foreground)',
            }"
            title="Estado de sincronización de datos"
          >
            <span
              :style="{
                background: isSupabaseConnected ? 'var(--primary)' : 'var(--coral)',
              }"
            />
            {{ isSupabaseConnected ? 'CONECTADO A SUPABASE' : 'DATOS DE PRUEBA (SIMULADOS)' }}
          </div>

          <Button
            variant="ghost"
            size="icon"
            aria-label="Notificaciones y Auditoría"
            title="Últimos eventos del historial"
            class="notification-button"
            @click="notification = !notification"
          >
            <Bell :size="19" />
            <i />
          </Button>
          <span class="topbar-avatar" :title="roleDef.simulatedUser">
            {{ roleDef.avatarInitials }}
          </span>
        </div>

        <div v-if="notification" class="notification-popover" style="width: 310px">
          <strong>Actividad Reciente (Historial)</strong>
          <p
            v-for="l in auditLogs.slice(0, 3)"
            :key="l.id"
            style="
              font-size: 11px;
              border-top: 1px solid var(--border);
              padding-top: 6px;
              margin-top: 6px;
            "
          >
            <strong>{{ l.recordId }}:</strong> {{ l.detail }} <br />
            <small style="color: var(--primary)">{{ l.timestamp }}</small>
          </p>
          <Button
            variant="ghost"
            size="sm"
            style="width: 100%; margin-top: 8px; font-size: 11px"
            @click="
              notification = false;
              changeView('asamblea');
            "
          >
            Ver Historial Completo de Sindicatura
          </Button>
        </div>
      </header>

      <main class="content">
        <div
          v-if="feedbackBanner || isLoadingOp"
          role="status"
          aria-live="polite"
          :style="{
            marginBottom: '18px',
            padding: '12px 18px',
            borderRadius: '7px',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            gap: '12px',
            fontSize: '12px',
            fontWeight: 600,
            border: '1px solid var(--border)',
            background:
              feedbackBanner?.type === 'error'
                ? 'var(--coral-light)'
                : feedbackBanner?.type === 'loading' || isLoadingOp
                  ? 'var(--sun-light)'
                  : 'var(--mint-light)',
            color: 'var(--foreground)',
          }"
        >
          <div style="display: flex; align-items: center; gap: 10px">
            <Loader2
              v-if="isLoadingOp || feedbackBanner?.type === 'loading'"
              :size="17"
            />
            <AlertTriangle
              v-else-if="feedbackBanner?.type === 'error'"
              :size="17"
              style="color: var(--destructive)"
            />
            <CheckCircle2 v-else :size="17" style="color: var(--primary)" />
            <span>{{ feedbackBanner?.message || 'Procesando consulta en el sistema...' }}</span>
          </div>
          <Button
            v-if="feedbackBanner"
            variant="ghost"
            size="icon"
            style="height: 24px; width: 24px"
            @click="feedbackBanner = null"
          >
            <X :size="14" />
          </Button>
        </div>

        <div
          style="
            margin-bottom: 22px;
            padding: 10px 16px;
            border-radius: 7px;
            background: var(--card);
            border: 1px solid var(--border);
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            font-size: 11px;
          "
        >
          <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap">
            <span class="status status-active">
              <span class="status-dot" />
              ROL SIMULADO: {{ roleDef.label.toUpperCase() }}
            </span>
            <span style="color: var(--muted-foreground)">
              Usuario: <strong>{{ roleDef.simulatedUser }}</strong> · {{ roleDef.canDo[0] }}
            </span>
          </div>
          <div style="display: flex; align-items: center; gap: 10px">
            <span style="color: var(--muted-foreground)">
              Fuente:
              <strong>{{
                isSupabaseConnected ? 'Supabase PostgreSQL' : 'Datos de prueba ficticios'
              }}</strong>
            </span>
            <Button
              variant="outline"
              size="sm"
              style="height: 28px; font-size: 11px"
              title="Restaurar datos de prueba iniciales del informe"
              @click="handleResetDemoData"
            >
              <RotateCcw :size="13" />
              <span>Restaurar datos</span>
            </Button>
          </div>
        </div>

        <div class="page-heading">
          <div>
            <p class="eyebrow">{{ titles[view].eyebrow }}</p>
            <h1>{{ titles[view].title }}</h1>
            <p class="page-subtitle">{{ titles[view].subtitle }}</p>
          </div>
          <Button
            v-if="view !== 'asamblea' && view !== 'comisiones' && view !== 'tablero'"
            class="primary-action"
            @click="openNewRequestModal"
          >
            <Plus :size="18" />
            Nueva solicitud
          </Button>
          <Button
            v-if="view === 'asamblea' && roleDef.permissions.canPublishActa"
            class="primary-action"
            @click="actaModal = true"
          >
            <Plus :size="18" />
            Redactar acta
          </Button>
        </div>

        <!-- ===============================================================
             VISTA 1: INICIO
        =============================================================== -->
        <template v-if="view === 'inicio'">
          <div class="welcome-band">
            <div class="welcome-content">
              <div class="welcome-kicker">
                <span class="live-dot" /> CONSTRUYENDO EN COMUNIDAD
              </div>
              <h2>
                Pequeñas soluciones.
                <br />
                <em>Grandes cambios.</em>
              </h2>
              <p>Cada proyecto empieza escuchando una necesidad de nuestra escuela.</p>
              <Button class="welcome-link" @click="changeView('proyectos')">
                Explorar proyectos <ArrowUpRight :size="16" />
              </Button>
            </div>
            <div class="welcome-art" aria-hidden="true">
              <div class="art-grid" />
              <div class="art-circle circle-one" />
              <div class="art-circle circle-two" />
              <div class="art-tile tile-one">&lt;/&gt;</div>
              <div class="art-tile tile-two">
                <Check :size="35" />
              </div>
              <div class="art-spark spark-one">✳</div>
              <div class="art-spark spark-two">✳</div>
              <div class="art-line line-one" />
              <div class="art-line line-two" />
            </div>
          </div>

          <div
            class="tablero-quick-banner"
            role="button"
            tabindex="0"
            @click="changeView('tablero')"
            @keydown.enter="changeView('tablero')"
          >
            <div class="tablero-quick-left">
              <span class="tablero-quick-badge">
                <span class="kpi-pulse-dot" /> PUNTO 8 · CUADRO DE MANDO Y CONTROL (BSC)
              </span>
              <h3>Tablero de Seguimiento Estratégico</h3>
              <p>
                Salud operativa en tiempo real: <strong>3 de 4 metas alcanzadas</strong> (TEUP, IASS,
                IPEC) y <strong>1 desvío crítico</strong> en pruebas de calidad (PDFT: 13.3% con plan
                de mejora activo).
              </p>
            </div>
            <div class="tablero-quick-right">
              <div class="tablero-quick-pills">
                <span class="kpi-tag-mini ok">TEUP: 85% · Óptimo</span>
                <span class="kpi-tag-mini ok">IASS: 85% · Cumplido</span>
                <span class="kpi-tag-mini alert">PDFT: 13.3% · Desvío QA</span>
                <span class="kpi-tag-mini ok">IPEC: 90% · Cumplido</span>
              </div>
              <Button variant="default" size="sm" class="tablero-btn-explore">
                <span>Abrir Tablero Completo</span>
                <ArrowRight :size="15" />
              </Button>
            </div>
          </div>

          <div class="metrics">
            <div
              class="metric"
              style="cursor: pointer"
              role="button"
              tabindex="0"
              @click="changeView('proyectos')"
            >
              <span class="metric-icon metric-coral">
                <Folders :size="20" />
              </span>
              <div>
                <strong>
                  {{
                    projects
                      .filter((p) => p.status !== 'Cancelado')
                      .length.toString()
                      .padStart(2, '0')
                  }}
                </strong>
                <span>Proyectos en marcha</span>
              </div>
              <ArrowUpRight :size="17" class="metric-arrow" />
            </div>
            <div
              class="metric"
              style="cursor: pointer"
              role="button"
              tabindex="0"
              @click="changeView('solicitudes')"
            >
              <span class="metric-icon metric-mint">
                <ClipboardList :size="20" />
              </span>
              <div>
                <strong>
                  {{
                    requests
                      .filter((r) => r.status === 'Por evaluar')
                      .length.toString()
                      .padStart(2, '0')
                  }}
                </strong>
                <span>Solicitudes por evaluar</span>
              </div>
              <ArrowUpRight :size="17" class="metric-arrow" />
            </div>
            <div
              class="metric"
              style="cursor: pointer"
              role="button"
              tabindex="0"
              @click="changeView('comisiones')"
            >
              <span class="metric-icon metric-sun">
                <Users :size="20" />
              </span>
              <div>
                <strong>06</strong>
                <span>Comisiones de trabajo</span>
              </div>
              <ArrowUpRight :size="17" class="metric-arrow" />
            </div>
          </div>

          <div class="dashboard-grid">
            <section class="dashboard-main">
              <div class="section-title">
                <h2>Proyectos destacados</h2>
                <Button variant="ghost" size="sm" @click="changeView('proyectos')">
                  Ver todos
                  <ArrowRight :size="15" />
                </Button>
              </div>
              <div class="featured-list">
                <div
                  v-for="p in visibleProjects.slice(0, 3)"
                  :key="p.id"
                  class="featured-row"
                  role="button"
                  tabindex="0"
                  @click="selectedProject = p"
                  @keydown.enter="selectedProject = p"
                >
                  <div :class="['project-glyph', `tone-${p.tone}`]">
                    <ProjectGlyph :tone="p.tone" />
                  </div>
                  <div class="featured-info">
                    <strong>{{ p.name }}</strong>
                    <span>
                      {{ p.category }} <b>·</b> {{ p.commission }}
                    </span>
                  </div>
                  <div class="featured-status">
                    <span :class="['status', `status-${getStatusKind(p.status)}`]">
                      <span class="status-dot" />
                      {{ p.status }}
                    </span>
                    <span>{{ p.progress }}% completado</span>
                  </div>
                  <ChevronRight :size="18" class="row-chevron" />
                </div>
              </div>
            </section>
            <section class="dashboard-side">
              <div class="section-title">
                <h2>Próxima asamblea</h2>
              </div>
              <div class="meeting-panel">
                <div class="date-badge">
                  <span>OCT</span>
                  <strong>15</strong>
                </div>
                <div class="meeting-copy">
                  <strong>Asamblea general</strong>
                  <span>
                    <Clock3 :size="14" /> 14:00 h · Sala de informática
                  </span>
                </div>
                <div class="meeting-divider" />
                <p>
                  Ideas para nuevos proyectos, evaluación de solicitudes y seguimiento de los
                  equipos.
                </p>
                <Button
                  variant="outline"
                  class="meeting-button"
                  @click="changeView('asamblea')"
                >
                  Ver orden del día <ArrowRight :size="16" />
                </Button>
              </div>
            </section>
          </div>

          <div class="bottom-highlight">
            <div class="highlight-icon">
              <HeartHandshake :size="24" />
            </div>
            <div>
              <strong>La tecnología se construye en equipo</strong>
              <p>
                Conocé a las personas detrás de cada solución y la organización democrática de las
                comisiones.
              </p>
            </div>
            <Button variant="ghost" @click="changeView('comisiones')">
              Conocer comisiones <ArrowRight :size="16" />
            </Button>
          </div>
        </template>

        <!-- ===============================================================
             VISTA 2: SOLICITUDES
        =============================================================== -->
        <template v-if="view === 'solicitudes'">
          <div class="view-summary">
            <span class="summary-icon">
              <ClipboardList :size="22" />
            </span>
            <div>
              <strong>
                {{ requests.length }} solicitudes registradas ({{
                  isSupabaseConnected ? 'Base de Datos Supabase' : 'Datos de prueba identificados'
                }})
              </strong>
              <p>
                Las necesidades escolares se evalúan en el Consejo antes de convertirse en
                proyectos. Las solicitudes descartadas se marcan como
                <strong>Canceladas</strong> (sin borrado físico) para conservar el historial de la
                Sindicatura.
              </p>
            </div>
            <span class="summary-decoration">✳</span>
          </div>

          <div class="controls-row">
            <div class="filter-tabs">
              <Button
                v-for="v in ['Todas', 'Por evaluar', 'En revisión', 'Aprobada', 'Cancelada']"
                :key="v"
                variant="ghost"
                :class="filter === v ? 'filter-active' : ''"
                @click="filter = v"
              >
                {{ v }}
              </Button>
            </div>
            <div style="display: flex; gap: 8px; flex-wrap: wrap; align-items: center">
              <select
                v-model="typeFilter"
                aria-label="Filtrar por tipo de solución"
                style="
                  height: 36px;
                  padding: 0 10px;
                  border-radius: 5px;
                  border: 1px solid var(--border);
                  background: var(--card);
                  font-size: 11px;
                  font-weight: 600;
                "
              >
                <option value="Todos">Todos los tipos</option>
                <option value="Sitio web">Sitio web</option>
                <option value="Formulario">Formulario</option>
                <option value="Aplicación informativa">Aplicación informativa</option>
                <option value="Herramienta">Herramienta</option>
              </select>
              <div class="search-field">
                <Search :size="17" />
                <input
                  v-model="query"
                  aria-label="Buscar solicitudes"
                  placeholder="Buscar solicitudes..."
                />
              </div>
            </div>
          </div>

          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>SOLICITUD Y CONTEXTO</th>
                  <th>SOLICITANTE</th>
                  <th>TIPO</th>
                  <th>ESTADO</th>
                  <th>FECHA / PRIORIDAD</th>
                  <th>OPERACIONES (SEGÚN ROL: {{ roleDef.shortLabel.toUpperCase() }})</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in visibleRequests" :key="r.id">
                  <td>
                    <span class="row-id">
                      {{ r.id }} · {{ isSupabaseConnected ? 'DB' : 'DATO DE PRUEBA' }}
                    </span>
                    <strong>{{ r.title }}</strong>
                    <span
                      style="display: block; font-size: 11px; margin-top: 4px; line-height: 1.4"
                    >
                      {{ r.description }}
                    </span>
                    <span
                      v-if="r.cancelReason"
                      style="
                        display: block;
                        font-size: 10px;
                        color: var(--destructive);
                        margin-top: 4px;
                      "
                    >
                      <strong>Motivo de cancelación:</strong> {{ r.cancelReason }}
                    </span>
                  </td>
                  <td>{{ r.from }}</td>
                  <td>
                    <span class="type-pill">{{ r.type }}</span>
                  </td>
                  <td>
                    <span :class="['status', `status-${getStatusKind(r.status)}`]">
                      <span class="status-dot" />
                      {{ r.status }}
                    </span>
                  </td>
                  <td>
                    <div>{{ r.date }}</div>
                    <small style="color: var(--primary); font-weight: 700">
                      Meta: {{ r.targetDate || 'A definir' }} ({{ r.priority }})
                    </small>
                  </td>
                  <td>
                    <div style="display: flex; flex-wrap: wrap; gap: 6px">
                      <Button
                        v-if="roleDef.permissions.canEvaluateRequest && r.status === 'Por evaluar'"
                        size="sm"
                        variant="outline"
                        style="height: 27px; font-size: 10px"
                        @click="handleRequestStateChange(r, 'En revisión')"
                      >
                        Pasar a Revisión
                      </Button>
                      <Button
                        v-if="
                          roleDef.permissions.canEvaluateRequest &&
                          (r.status === 'Por evaluar' || r.status === 'En revisión')
                        "
                        size="sm"
                        style="height: 27px; font-size: 10px"
                        @click="handleRequestStateChange(r, 'Aprobada')"
                      >
                        Aprobar
                      </Button>
                      <Button
                        v-if="roleDef.permissions.canEvaluateRequest && r.status === 'Aprobada'"
                        size="sm"
                        variant="outline"
                        style="
                          height: 27px;
                          font-size: 10px;
                          border-color: var(--primary);
                          color: var(--primary);
                        "
                        @click="handleConvertRequestToProject(r)"
                      >
                        Convertir en Proyecto
                      </Button>

                      <Button
                        v-if="
                          (roleDef.permissions.canEditOwnRequest ||
                            roleDef.permissions.canEvaluateRequest) &&
                          r.status === 'Por evaluar'
                        "
                        size="sm"
                        variant="ghost"
                        style="height: 27px; font-size: 10px"
                        title="Editar solicitud"
                        @click="openEditRequestModal(r)"
                      >
                        <Edit3 :size="12" /> Editar
                      </Button>

                      <Button
                        v-if="
                          (roleDef.permissions.canCancelOwnRequest ||
                            roleDef.permissions.canEvaluateRequest) &&
                          r.status !== 'Cancelada'
                        "
                        size="sm"
                        variant="ghost"
                        style="height: 27px; font-size: 10px; color: var(--destructive)"
                        @click="
                          cancelTargetRequest = r;
                          cancelReasonInput = '';
                        "
                      >
                        <XCircle :size="12" /> Cancelar
                      </Button>

                      <span
                        v-if="
                          !roleDef.permissions.canEvaluateRequest &&
                          !roleDef.permissions.canEditOwnRequest
                        "
                        style="font-size: 10px; color: var(--muted-foreground)"
                      >
                        Solo lectura ({{ roleDef.shortLabel }})
                      </span>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
            <div v-if="visibleRequests.length === 0" class="empty-state">
              No hay solicitudes con esos criterios o para este nivel de acceso.
            </div>
          </div>
        </template>

        <!-- ===============================================================
             VISTA 3: PROYECTOS, SPRINT BACKLOG Y PRUEBAS QA
        =============================================================== -->
        <template v-if="view === 'proyectos'">
          <div class="project-overview">
            <div>
              <span class="eyebrow">PANORAMA GENERAL · DATOS DE PRUEBA ACTIVOS</span>
              <h2>De la idea a la realidad.</h2>
              <p>
                Seguimos cada paso para entregar soluciones útiles, accesibles y bien hechas. Hacé
                clic en cualquier tarjeta para gestionar el avance, las tareas del equipo o reportar
                pruebas de calidad (QA).
              </p>
            </div>
            <div class="overview-count">
              <strong>{{ visibleProjects.length.toString().padStart(2, '0') }}</strong>
              <span>
                proyectos
                <br />
                visibles
              </span>
            </div>
          </div>

          <div class="controls-row">
            <div class="filter-tabs">
              <Button
                v-for="v in ['Todas', 'Por comenzar', 'En desarrollo', 'En pruebas', 'Finalizado']"
                :key="v"
                variant="ghost"
                :class="filter === v ? 'filter-active' : ''"
                @click="filter = v"
              >
                {{ v }}
              </Button>
            </div>
            <div class="project-tools">
              <Button
                v-if="roleDef.permissions.canRegisterQABugs"
                variant="outline"
                size="sm"
                style="height: 34px; font-size: 11px"
                @click="qaModal = true"
              >
                <ShieldCheck :size="15" /> Registrar Prueba QA / Bug
              </Button>
              <div class="search-field">
                <Search :size="17" />
                <input
                  v-model="query"
                  aria-label="Buscar proyectos"
                  placeholder="Buscar proyectos..."
                />
              </div>
              <div class="view-switch">
                <Button
                  variant="ghost"
                  size="icon"
                  title="Vista de tarjetas"
                  aria-label="Vista de tarjetas"
                  :class="!board ? 'switch-active' : ''"
                  @click="board = false"
                >
                  <LayoutGrid :size="17" />
                </Button>
                <Button
                  variant="ghost"
                  size="icon"
                  title="Vista de tablero Kanban"
                  aria-label="Vista de tablero Kanban"
                  :class="board ? 'switch-active' : ''"
                  @click="board = true"
                >
                  <List :size="18" />
                </Button>
              </div>
            </div>
          </div>

          <div v-if="board" class="kanban">
            <div
              v-for="stage in ['Por comenzar', 'En desarrollo', 'En pruebas', 'Finalizado']"
              :key="stage"
              class="kanban-column"
            >
              <div class="kanban-heading">
                <span
                  :class="['kanban-dot', `stage-${stage.replaceAll(' ', '-').toLowerCase()}`]"
                />
                <strong>{{ stage }}</strong>
                <small>{{ visibleProjects.filter((p) => p.status === stage).length }}</small>
              </div>
              <div
                v-for="p in visibleProjects.filter((item) => item.status === stage)"
                :key="p.id"
                class="kanban-card"
                role="button"
                tabindex="0"
                @click="selectedProject = p"
                @keydown.enter="selectedProject = p"
              >
                <span class="row-id">{{ p.id }} · DATO DE PRUEBA</span>
                <strong>{{ p.name }}</strong>
                <p>{{ p.description }}</p>
                <div>
                  <div class="avatar-stack avatar-stack-small">
                    <span
                      v-for="(ini, i) in p.initials"
                      :key="`${ini}-${i}`"
                      :class="['avatar', `avatar-${i % 4}`]"
                    >
                      {{ ini }}
                    </span>
                  </div>
                  <ArrowUpRight :size="16" />
                </div>
              </div>
            </div>
          </div>

          <div v-else class="project-grid">
            <div
              v-for="p in visibleProjects"
              :key="p.id"
              class="project-card"
              role="button"
              tabindex="0"
              @click="selectedProject = p"
              @keydown.enter="selectedProject = p"
            >
              <div :class="['project-card-art', `tone-${p.tone}`]">
                <span class="project-card-tag">{{ p.category }}</span>
                <ProjectGlyph :tone="p.tone" />
                <span class="art-corner">✳</span>
              </div>
              <div class="project-card-body">
                <div class="project-card-meta">
                  <span>{{ p.id }} · Datos de prueba</span>
                  <span :class="['status', `status-${getStatusKind(p.status)}`]">
                    <span class="status-dot" />
                    {{ p.status }}
                  </span>
                </div>
                <h3>{{ p.name }}</h3>
                <p>{{ p.description }}</p>
                <div class="progress-label">
                  <span>Progreso ({{ p.commission }})</span>
                  <strong>{{ p.progress }}%</strong>
                </div>
                <div class="progress-track">
                  <span :style="{ width: `${p.progress}%` }" />
                </div>
                <div class="project-card-footer">
                  <div class="avatar-stack avatar-stack-small">
                    <span
                      v-for="(ini, i) in p.initials"
                      :key="`${ini}-${i}`"
                      :class="['avatar', `avatar-${i % 4}`]"
                    >
                      {{ ini }}
                    </span>
                  </div>
                  <span>
                    <CalendarDays :size="14" />
                    {{ p.date }}
                  </span>
                </div>
              </div>
            </div>
          </div>

          <div v-if="visibleProjects.length === 0" class="empty-state">
            No hay proyectos con esos criterios.
          </div>

          <div
            v-if="roleDef.permissions.canViewInternalBoards"
            style="margin-top: 32px; display: grid; gap: 24px"
          >
            <div class="table-wrap">
              <div
                style="
                  padding: 16px 20px;
                  border-bottom: 1px solid var(--border);
                  display: flex;
                  justify-content: space-between;
                  align-items: center;
                  flex-wrap: wrap;
                  gap: 10px;
                "
              >
                <div>
                  <strong style="font-size: 14px">
                    Tablero de Tareas Pendientes por Comisión (Sprint Backlog - Art. 10 inc. b)
                  </strong>
                  <p style="font-size: 11px; color: var(--muted-foreground); margin: 3px 0 0">
                    Los referentes y socios pueden hacer clic en «Avanzar estado» para registrar el
                    progreso de su tarea.
                  </p>
                </div>
              </div>
              <table>
                <thead>
                  <tr>
                    <th>CÓDIGO / PROYECTO</th>
                    <th>TAREA ASIGNADA</th>
                    <th>COMISIÓN</th>
                    <th>RESPONSABLE</th>
                    <th>ESTADO</th>
                    <th>ACCIÓN</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="t in tasks" :key="t.id">
                    <td>
                      <span class="row-id">{{ t.id }}</span>
                      <strong>{{ t.projectId }}</strong>
                    </td>
                    <td>{{ t.title }}</td>
                    <td>{{ t.commission }}</td>
                    <td>{{ t.assignee }}</td>
                    <td>
                      <span :class="['status', `status-${getStatusKind(t.status)}`]">
                        <span class="status-dot" />
                        {{ t.status }}
                      </span>
                    </td>
                    <td>
                      <Button
                        v-if="roleDef.permissions.canManageTasks"
                        size="sm"
                        variant="outline"
                        style="height: 27px; font-size: 10px"
                        @click="handleCycleTaskStatus(t)"
                      >
                        Avanzar estado
                      </Button>
                      <span v-else style="font-size: 10px">Solo lectura</span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div class="table-wrap">
              <div
                style="
                  padding: 16px 20px;
                  border-bottom: 1px solid var(--border);
                  display: flex;
                  justify-content: space-between;
                  align-items: center;
                  flex-wrap: wrap;
                  gap: 10px;
                "
              >
                <div>
                  <strong style="font-size: 14px">
                    Matriz de Control de Calidad y Pruebas QA (Fuente del KPI PDFT = 13.3%)
                  </strong>
                  <p style="font-size: 11px; color: var(--muted-foreground); margin: 3px 0 0">
                    Deja constancia de los casos de prueba ejecutados y las fallas detectadas antes
                    de entregar una solución.
                  </p>
                </div>
                <Button
                  v-if="roleDef.permissions.canRegisterQABugs"
                  size="sm"
                  @click="qaModal = true"
                >
                  <Plus :size="14" /> Nuevo Reporte QA
                </Button>
              </div>
              <table>
                <thead>
                  <tr>
                    <th>REPORTE / PROYECTO</th>
                    <th>TIPO DE PRUEBA</th>
                    <th>DESCRIPCIÓN Y HALLAZGOS</th>
                    <th>CASOS / BUGS</th>
                    <th>ESTADO</th>
                    <th>REPORTADO POR</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="q in qaTests" :key="q.id">
                    <td>
                      <span class="row-id">{{ q.id }}</span>
                      <strong>{{ q.projectId }} · {{ q.projectName }}</strong>
                    </td>
                    <td>
                      <span class="type-pill">{{ q.type }}</span>
                    </td>
                    <td>{{ q.description }}</td>
                    <td>
                      <strong>{{ q.bugsFound }} fallas</strong> sobre {{ q.casesExecuted }} pruebas
                    </td>
                    <td>
                      <span :class="['status', `status-${getStatusKind(q.status)}`]">
                        <span class="status-dot" />
                        {{ q.status }}
                      </span>
                    </td>
                    <td>{{ q.reportedBy }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </template>

        <!-- ===============================================================
             VISTA 4: COMISIONES
        =============================================================== -->
        <template v-if="view === 'comisiones'">
          <div class="view-summary">
            <span class="summary-icon">
              <Users :size="22" />
            </span>
            <div>
              <strong>Seis formas de aportar (Padrón activo: 20 socios estudiantes)</strong>
              <p>
                Cada integrante puede aprender, colaborar y rotar voluntariamente de comisión al
                terminar un proyecto (Art. 5 del Reglamento).
              </p>
            </div>
            <span class="summary-decoration">✳</span>
          </div>
          <div class="commission-grid">
            <div v-for="(c, i) in commissions" :key="c.name" class="commission-card">
              <div class="commission-top">
                <span :class="['commission-icon', `tone-${c.tone}`]">
                  <component :is="c.icon" :size="25" :stroke-width="1.7" />
                </span>
                <span class="commission-number">0{{ i + 1 }}</span>
              </div>
              <h2>{{ c.name }}</h2>
              <p>{{ c.desc }}</p>
              <p style="font-size: 10px; margin-top: 8px">{{ c.functions }}</p>
              <div class="commission-divider" />
              <div class="commission-people">
                <div class="avatar-stack avatar-stack-small">
                  <span
                    v-for="(ini, idx) in c.initials"
                    :key="`${ini}-${idx}`"
                    :class="['avatar', `avatar-${idx % 4}`]"
                  >
                    {{ ini }}
                  </span>
                </div>
                <span>
                  {{ c.count }} · Ref: <strong>{{ c.lead }}</strong>
                </span>
              </div>
              <Button
                variant="ghost"
                class="commission-link"
                @click="selectedCommission = c.name"
              >
                Ver comisión y tareas <ArrowUpRight :size="16" />
              </Button>
            </div>
          </div>
        </template>

        <!-- ===============================================================
             VISTA 5: ASAMBLEA, ACTAS Y AUDITORÍA DE SINDICATURA
        =============================================================== -->
        <template v-if="view === 'asamblea'">
          <div class="assembly-hero">
            <div class="assembly-symbol">
              <HeartHandshake :size="30" />
            </div>
            <div>
              <span class="eyebrow">
                UN EQUIPO, UNA VOZ POR PERSONA (ART. 6 Y 8 DEL REGLAMENTO)
              </span>
              <h2>Decidimos en conjunto.</h2>
              <p>
                La asamblea reúne a todos los socios para conversar, proponer y tomar decisiones.
                Las actas y el historial de cambios no pueden borrarse para garantizar transparencia
                ante la Sindicatura Escolar.
              </p>
            </div>
            <span class="assembly-art" aria-hidden="true">✳</span>
          </div>

          <div class="assembly-grid">
            <section>
              <div class="section-title">
                <h2>Próxima reunión</h2>
              </div>
              <div class="agenda-panel">
                <div class="agenda-head">
                  <div class="date-badge">
                    <span>OCT</span>
                    <strong>15</strong>
                  </div>
                  <div>
                    <span class="eyebrow">ASAMBLEA GENERAL ORDINARIA</span>
                    <h3>Encuentro de octubre</h3>
                    <p>
                      <Clock3 :size="15" /> 14:00 h <span>·</span> Sala de informática (18/20 socios
                      confirmados · IPEC 90%)
                    </p>
                  </div>
                </div>
                <div class="agenda-divider" />
                <h4>Orden del día</h4>
                <ol>
                  <li><span>01</span>Avance de proyectos en curso (PR-001 y PR-002)</li>
                  <li>
                    <span>02</span>Evaluación de nuevas solicitudes (Muestra de Ciencias SOL-014)
                  </li>
                  <li>
                    <span>03</span>Revisión del Tablero KPI y protocolo Peer Review QA (PDFT)
                  </li>
                  <li>
                    <span>04</span>Acuerdos de rotación formativa y firma del Libro de Actas
                  </li>
                </ol>
              </div>
            </section>

            <section>
              <div class="section-title">
                <h2>Libro de Actas recientes (Protegido contra borrado)</h2>
                <Button
                  v-if="roleDef.permissions.canPublishActa"
                  variant="ghost"
                  size="sm"
                  @click="actaModal = true"
                >
                  Nueva acta
                  <ArrowRight :size="15" />
                </Button>
              </div>
              <div class="minutes-list">
                <div
                  v-for="m in actas"
                  :key="m.id"
                  class="minute-row"
                  style="align-items: flex-start"
                >
                  <span class="minute-icon">
                    <FileText :size="18" />
                  </span>
                  <div>
                    <strong>
                      {{ m.id }} · {{ m.title }} ({{ m.attendees }}/{{ m.totalMembers }} presentes)
                    </strong>
                    <span style="white-space: normal; margin-top: 4px">{{ m.detail }}</span>
                    <span
                      style="white-space: normal; margin-top: 4px; color: var(--foreground)"
                    >
                      <strong>Acuerdo:</strong> {{ m.agreements }}
                    </span>
                  </div>
                  <small>{{ m.date }}</small>
                </div>
              </div>
              <div class="principle-note">
                <ShieldCheck :size="22" />
                <div>
                  <strong>Decisiones transparentes y fiscalizadas por la Sindicatura</strong>
                  <p>
                    Los acuerdos y cambios de estado quedan registrados automáticamente en el
                    historial inmutable de auditoría ({{ auditLogs.length }} registros activos abajo).
                  </p>
                </div>
              </div>
            </section>
          </div>

          <!-- HISTORIAL INMUTABLE DE CAMBIOS Y AUDITORÍA DE SINDICATURA -->
          <div class="kpi-consolidated-panel" style="margin-top: 28px">
            <div class="kpi-panel-header">
              <div>
                <span class="eyebrow">FISCALIZACIÓN ESTATUTARIA · SINDICATURA ESCOLAR</span>
                <h3>Historial Inmutable de Cambios y Auditoría (`historial_cambios`)</h3>
                <p>
                  Registro cronológico automático de todas las altas, evaluaciones, conversiones a
                  proyecto, reportes QA y actas publicadas sin posibilidad de eliminación física.
                </p>
              </div>
              <span class="type-pill">{{ auditLogs.length }} registros auditados</span>
            </div>
            <div class="table-wrap">
              <table>
                <thead>
                  <tr>
                    <th>ID / FECHA</th>
                    <th>ENTIDAD Y REGISTRO</th>
                    <th>ACCIÓN</th>
                    <th>TRANSICIÓN DE ESTADO</th>
                    <th>DETALLE DE LA OPERACIÓN</th>
                    <th>RESPONSABLE Y ROL</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="log in auditLogs" :key="log.id">
                    <td>
                      <span class="row-id">{{ log.id }}</span>
                      <strong>{{ log.timestamp }}</strong>
                    </td>
                    <td>
                      <span class="type-pill">{{ log.entity }}</span>
                      <strong>{{ log.recordId }}</strong>
                    </td>
                    <td>
                      <strong style="color: var(--primary)">{{ log.action }}</strong>
                    </td>
                    <td>
                      <small style="display: block; color: var(--muted-foreground)">
                        Antes: {{ log.previousState }}
                      </small>
                      <strong style="font-size: 11px">Ahora: {{ log.newState }}</strong>
                    </td>
                    <td>{{ log.detail }}</td>
                    <td>
                      <strong style="margin: 0">{{ log.user }}</strong>
                      <small style="display: block; color: var(--muted-foreground)">
                        {{ log.role }}
                      </small>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </template>

        <!-- ===============================================================
             VISTA 6: TABLERO KPI (BSC)
        =============================================================== -->
        <template v-if="view === 'tablero'">
          <KPITrackingDashboard
            :onNavigateToProjects="() => changeView('proyectos')"
          />
        </template>

        <footer class="page-footer">
          <span>Cooperativa Escolar de Soluciones Digitales y Tecnológicas</span>
          <span>
            {{
              isSupabaseConnected
                ? 'Conectado a Supabase PostgreSQL'
                : 'Prototipo funcional con datos de prueba preparados para Supabase'
            }}
          </span>
        </footer>
      </main>
    </div>

    <!-- =====================================================================
         MODAL 1: CREAR / EDITAR SOLICITUD CON VALIDACIÓN DE CAMPOS
    ===================================================================== -->
    <div v-if="modal" class="overlay" @mousedown.self="modal = false">
      <div class="dialog" role="dialog" aria-modal="true" aria-labelledby="dialog-title">
        <div class="dialog-head">
          <div>
            <span class="eyebrow">
              {{ editingRequestId ? `MODIFICAR ${editingRequestId}` : 'NUEVA IDEA' }}
            </span>
            <h2 id="dialog-title">
              {{ editingRequestId ? 'Editar solicitud' : 'Crear solicitud' }}
            </h2>
          </div>
          <Button variant="ghost" size="icon" aria-label="Cerrar" @click="modal = false">
            <X :size="20" />
          </Button>
        </div>
        <p>
          Completá los datos obligatorios (*). El sistema valida formatos y valores permitidos antes
          de registrar el pedido.
        </p>
        <form novalidate @submit.prevent="submitRequest">
          <label>
            Nombre de la solicitud * (5 a 140 caracteres)
            <input
              v-model="form.title"
              placeholder="Ej. Inscripción a la muestra de ciencias"
              :style="formErrors.title ? { borderColor: 'var(--destructive)' } : undefined"
            />
            <small v-if="formErrors.title" style="color: var(--destructive); font-weight: 600">
              {{ formErrors.title }}
            </small>
          </label>

          <label>
            Área, departamento o persona solicitante *
            <input
              v-model="form.from"
              placeholder="Ej. Departamento de Ciencias"
              :style="formErrors.from ? { borderColor: 'var(--destructive)' } : undefined"
            />
            <small v-if="formErrors.from" style="color: var(--destructive); font-weight: 600">
              {{ formErrors.from }}
            </small>
          </label>

          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px">
            <label>
              Tipo de solución permitida *
              <select v-model="form.type">
                <option value="Sitio web">Sitio web</option>
                <option value="Formulario">Formulario</option>
                <option value="Aplicación informativa">Aplicación informativa</option>
                <option value="Herramienta">Herramienta</option>
              </select>
            </label>

            <label>
              Fecha necesaria / límite *
              <input
                v-model="form.targetDate"
                type="date"
                :style="formErrors.targetDate ? { borderColor: 'var(--destructive)' } : undefined"
              />
              <small
                v-if="formErrors.targetDate"
                style="color: var(--destructive); font-weight: 600"
              >
                {{ formErrors.targetDate }}
              </small>
            </label>
          </div>

          <label>
            ¿Qué problema o necesidad escolar queremos resolver? * (mínimo 15 caracteres)
            <textarea
              v-model="form.description"
              rows="3"
              placeholder="Describí el contexto, quiénes lo usarán y qué datos necesita..."
              :style="formErrors.description ? { borderColor: 'var(--destructive)' } : undefined"
            />
            <small
              v-if="formErrors.description"
              style="color: var(--destructive); font-weight: 600"
            >
              {{ formErrors.description }}
            </small>
          </label>

          <div class="dialog-actions">
            <Button type="button" variant="outline" @click="modal = false">
              Cancelar
            </Button>
            <Button type="submit" :disabled="isLoadingOp">
              {{ editingRequestId ? 'Guardar cambios' : 'Enviar solicitud' }}
              <ArrowRight :size="16" />
            </Button>
          </div>
        </form>
      </div>
    </div>

    <!-- =====================================================================
         MODAL 2: CANCELACIÓN LÓGICA DE SOLICITUD
    ===================================================================== -->
    <div v-if="cancelTargetRequest" class="overlay" @mousedown.self="cancelTargetRequest = null">
      <div class="dialog" role="dialog" aria-modal="true">
        <div class="dialog-head">
          <div>
            <span class="eyebrow">CONSERVACIÓN DEL HISTORIAL (PUNTO 8)</span>
            <h2>Cancelar {{ cancelTargetRequest.id }}</h2>
          </div>
          <Button variant="ghost" size="icon" @click="cancelTargetRequest = null">
            <X :size="20" />
          </Button>
        </div>
        <p>
          Para cumplir el Reglamento y permitir la fiscalización de la Sindicatura Escolar, los
          registros <strong>no se eliminan físicamente</strong>: pasan al estado
          <strong>Cancelada</strong> conservando su trazabilidad.
        </p>
        <form @submit.prevent="confirmCancelRequest">
          <label>
            Motivo de la cancelación * (obligatorio para el acta de auditoría)
            <textarea
              v-model="cancelReasonInput"
              required
              rows="3"
              placeholder="Ej. El departamento postergó la actividad para el próximo trimestre..."
            />
          </label>
          <div class="dialog-actions">
            <Button type="button" variant="outline" @click="cancelTargetRequest = null">
              Volver
            </Button>
            <Button type="submit">Confirmar cancelación lógica</Button>
          </div>
        </form>
      </div>
    </div>

    <!-- =====================================================================
         MODAL 3: DETALLE Y GESTIÓN DE PROYECTO
    ===================================================================== -->
    <div v-if="selectedProject" class="overlay" @mousedown.self="selectedProject = null">
      <div
        class="detail-dialog"
        role="dialog"
        aria-modal="true"
        aria-labelledby="project-title"
      >
        <Button
          variant="ghost"
          size="icon"
          aria-label="Cerrar"
          class="detail-close"
          @click="selectedProject = null"
        >
          <X :size="20" />
        </Button>
        <div :class="['detail-art', `tone-${selectedProject.tone}`]">
          <ProjectGlyph :tone="selectedProject.tone" />
        </div>
        <div class="detail-body">
          <span class="eyebrow">
            {{ selectedProject.id }} · {{ selectedProject.category }} · DATO DE PRUEBA
          </span>
          <h2 id="project-title">{{ selectedProject.name }}</h2>
          <span :class="['status', `status-${getStatusKind(selectedProject.status)}`]">
            <span class="status-dot" />
            {{ selectedProject.status }}
          </span>
          <p>{{ selectedProject.description }}</p>
          <div class="detail-facts">
            <div>
              <span>Comisiones</span>
              <strong>{{ selectedProject.commission }}</strong>
            </div>
            <div>
              <span>Fecha estimada</span>
              <strong>{{ selectedProject.date }}</strong>
            </div>
            <div>
              <span>Avance</span>
              <strong>{{ selectedProject.progress }}%</strong>
            </div>
          </div>
          <div class="progress-track">
            <span :style="{ width: `${selectedProject.progress}%` }" />
          </div>

          <div
            v-if="roleDef.permissions.canUpdateProjectStatus"
            style="
              margin-top: 18px;
              padding: 14px;
              border-radius: 6px;
              background: var(--muted);
              border: 1px solid var(--border);
            "
          >
            <strong style="font-size: 11px; display: block; margin-bottom: 8px">
              Actualizar Etapa y Progreso ({{ roleDef.shortLabel }}):
            </strong>
            <div style="display: flex; flex-wrap: wrap; gap: 6px">
              <Button
                size="sm"
                :variant="selectedProject.status === 'Por comenzar' ? 'default' : 'outline'"
                style="height: 28px; font-size: 10px"
                @click="handleUpdateProjectStage(selectedProject, 'Por comenzar', 15)"
              >
                Por comenzar (15%)
              </Button>
              <Button
                size="sm"
                :variant="selectedProject.status === 'En desarrollo' ? 'default' : 'outline'"
                style="height: 28px; font-size: 10px"
                @click="handleUpdateProjectStage(selectedProject, 'En desarrollo', 68)"
              >
                En desarrollo (68%)
              </Button>
              <Button
                size="sm"
                :variant="selectedProject.status === 'En pruebas' ? 'default' : 'outline'"
                style="height: 28px; font-size: 10px"
                @click="handleUpdateProjectStage(selectedProject, 'En pruebas', 88)"
              >
                En pruebas QA (88%)
              </Button>
              <Button
                size="sm"
                :variant="selectedProject.status === 'Finalizado' ? 'default' : 'outline'"
                style="height: 28px; font-size: 10px"
                @click="handleUpdateProjectStage(selectedProject, 'Finalizado', 100)"
              >
                Finalizado (100%)
              </Button>
            </div>
          </div>
          <p v-else style="font-size: 11px; color: var(--muted-foreground); margin-top: 14px">
            Vista de lectura para {{ roleDef.shortLabel }}. Los cambios de estado los realizan
            Referentes, Socios de la comisión y el Consejo.
          </p>

          <div class="detail-team">
            <div class="avatar-stack">
              <span
                v-for="(ini, idx) in selectedProject.initials"
                :key="`${ini}-${idx}`"
                :class="['avatar', `avatar-${idx % 4}`]"
              >
                {{ ini }}
              </span>
            </div>
            <span>Equipo asignado al proyecto</span>
          </div>
        </div>
      </div>
    </div>

    <!-- =====================================================================
         MODAL 4: DETALLE DE COMISIÓN
    ===================================================================== -->
    <div
      v-if="selectedCommission && selectedCommissionObj"
      class="overlay"
      @mousedown.self="selectedCommission = null"
    >
      <div
        class="detail-dialog commission-dialog"
        role="dialog"
        aria-modal="true"
        aria-labelledby="commission-title"
      >
        <Button
          variant="ghost"
          size="icon"
          aria-label="Cerrar"
          class="detail-close"
          @click="selectedCommission = null"
        >
          <X :size="20" />
        </Button>
        <div class="detail-body">
          <span class="eyebrow">COMISIÓN DE TRABAJO ESTATUTARIA</span>
          <h2 id="commission-title">{{ selectedCommissionObj.name }}</h2>
          <p>{{ selectedCommissionObj.desc }}</p>
          <p style="font-size: 11px">{{ selectedCommissionObj.functions }}</p>
          <div class="detail-facts">
            <div>
              <span>Integrantes</span>
              <strong>{{ selectedCommissionObj.count }}</strong>
            </div>
            <div>
              <span>Referente (Vocal)</span>
              <strong>{{ selectedCommissionObj.lead }}</strong>
            </div>
          </div>
          <div class="detail-team">
            <div class="avatar-stack">
              <span
                v-for="(ini, idx) in selectedCommissionObj.initials"
                :key="`${ini}-${idx}`"
                :class="['avatar', `avatar-${idx % 4}`]"
              >
                {{ ini }}
              </span>
            </div>
            <span>Equipo activo de la comisión</span>
          </div>
        </div>
      </div>
    </div>

    <!-- =====================================================================
         MODAL 5: REDACTAR NUEVA ACTA DE ASAMBLEA
    ===================================================================== -->
    <div v-if="actaModal" class="overlay" @mousedown.self="actaModal = false">
      <div class="dialog" role="dialog" aria-modal="true">
        <div class="dialog-head">
          <div>
            <span class="eyebrow">LIBRO DE ACTAS FOLIADO DIGITAL (ART. 10)</span>
            <h2>Registrar acta de reunión</h2>
          </div>
          <Button variant="ghost" size="icon" @click="actaModal = false">
            <X :size="20" />
          </Button>
        </div>
        <p>
          Las actas publicadas por Secretaría quedan resguardadas y no admiten eliminación física.
        </p>
        <form @submit.prevent="handleCreateActa">
          <label>
            Título de la sesión *
            <input
              v-model="actaForm.title"
              required
              placeholder="Ej. Asamblea ordinaria de cierre de sprint"
            />
          </label>
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px">
            <label>
              Etiqueta de fecha *
              <input v-model="actaForm.date" required placeholder="Ej. 29 OCT" />
            </label>
            <label>
              Socios presentes (de 20) *
              <input
                v-model.number="actaForm.attendees"
                type="number"
                min="1"
                max="20"
              />
            </label>
          </div>
          <label>
            Acuerdos votados por mayoría * (mínimo 15 caracteres)
            <textarea
              v-model="actaForm.agreements"
              required
              rows="3"
              placeholder="Detallá las decisiones aprobadas por los socios..."
            />
          </label>
          <small v-if="actaError" style="color: var(--destructive); font-weight: 700">
            {{ actaError }}
          </small>
          <div class="dialog-actions">
            <Button type="button" variant="outline" @click="actaModal = false">
              Cancelar
            </Button>
            <Button type="submit">Publicar en Libro de Actas</Button>
          </div>
        </form>
      </div>
    </div>

    <!-- =====================================================================
         MODAL 6: REGISTRAR REPORTE DE PRUEBAS QA / BUGS (KPI PDFT)
    ===================================================================== -->
    <div v-if="qaModal" class="overlay" @mousedown.self="qaModal = false">
      <div class="dialog" role="dialog" aria-modal="true">
        <div class="dialog-head">
          <div>
            <span class="eyebrow">COMISIÓN DE PRUEBAS Y CALIDAD (KPI PDFT)</span>
            <h2>Registrar ejecución de pruebas QA</h2>
          </div>
          <Button variant="ghost" size="icon" @click="qaModal = false">
            <X :size="20" />
          </Button>
        </div>
        <p>
          Registrá las pruebas realizadas antes de la entrega para medir el Porcentaje de Defectos
          en Fase de Testing (PDFT ≤ 10%).
        </p>
        <form @submit.prevent="handleCreateQATest">
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px">
            <label>
              Proyecto evaluado *
              <select v-model="qaForm.projectId">
                <option v-for="p in projects" :key="p.id" :value="p.id">
                  {{ p.id }} · {{ p.name }}
                </option>
              </select>
            </label>
            <label>
              Tipo de prueba *
              <select v-model="qaForm.type">
                <option value="Validación de campos">Validación de campos</option>
                <option value="Diseño responsivo">Diseño responsivo</option>
                <option value="Enlaces y navegación">Enlaces y navegación</option>
                <option value="Accesibilidad y textos">Accesibilidad y textos</option>
                <option value="Rendimiento en PC de sala">Rendimiento en PC de sala</option>
              </select>
            </label>
          </div>
          <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px">
            <label>
              Casos de prueba ejecutados *
              <input
                v-model.number="qaForm.casesExecuted"
                type="number"
                min="1"
                max="200"
              />
            </label>
            <label>
              Fallas / Bugs detectados *
              <input
                v-model.number="qaForm.bugsFound"
                type="number"
                min="0"
                max="200"
              />
            </label>
          </div>
          <label>
            Detalle de lo probado o de las fallas detectadas *
            <textarea
              v-model="qaForm.description"
              required
              rows="3"
              placeholder="Ej. Al enviar el formulario sin correo institucional no mostraba borde rojo en celulares..."
            />
          </label>
          <small v-if="qaError" style="color: var(--destructive); font-weight: 700">
            {{ qaError }}
          </small>
          <div class="dialog-actions">
            <Button type="button" variant="outline" @click="qaModal = false">
              Cancelar
            </Button>
            <Button type="submit">Guardar Reporte QA</Button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
