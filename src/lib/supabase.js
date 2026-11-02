import { createClient } from '@supabase/supabase-js'

// =============================================================================
// CLIENTE SUPABASE EN JAVASCRIPT PURO (Puntos 3, 13, 14, 15 y 16)
// =============================================================================
// SEGURIDAD (Punto 16): Nunca se incluyen contraseñas ni claves secretas de
// administración (service_role) en el código del cliente ni en la documentación.
// Solo se admite la clave pública (anon / publishable key) protegida por RLS.
// =============================================================================

const STORAGE_URL_KEY = 'coop_supabase_url'
const STORAGE_ANON_KEY = 'coop_supabase_anon_key'

export function getSupabaseConfig() {
  const envUrl = (import.meta.env?.VITE_SUPABASE_URL || '').trim()
  const envKey = (
    import.meta.env?.VITE_SUPABASE_ANON_KEY ||
    import.meta.env?.VITE_SUPABASE_PUBLISHABLE_KEY ||
    ''
  ).trim()

  if (envUrl && envKey && !envUrl.includes('tu-proyecto-id')) {
    return { url: envUrl, anonKey: envKey, isConfigured: true, source: 'env' }
  }

  if (typeof window !== 'undefined') {
    const localUrl = (window.localStorage.getItem(STORAGE_URL_KEY) || '').trim()
    const localKey = (window.localStorage.getItem(STORAGE_ANON_KEY) || '').trim()
    if (localUrl && localKey) {
      return { url: localUrl, anonKey: localKey, isConfigured: true, source: 'local' }
    }
  }

  return { url: '', anonKey: '', isConfigured: false, source: 'none' }
}

export const isSupabaseConfigured = getSupabaseConfig().isConfigured

let cachedClient = null

export function getSupabaseClient() {
  const config = getSupabaseConfig()
  if (!config.isConfigured) return null
  if (!cachedClient) {
    cachedClient = createClient(config.url, config.anonKey, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
      },
    })
  }
  return cachedClient
}

export const supabase = getSupabaseClient()

export async function checkSupabaseConnection() {
  const client = getSupabaseClient()
  if (!client) {
    return {
      connected: false,
      mode: 'prototype_mock',
      message:
        'Modo Datos de Prueba Activo: Completá VITE_SUPABASE_URL y VITE_SUPABASE_PUBLISHABLE_KEY en tu archivo .env.',
    }
  }

  try {
    const [comRes, solRes, proyRes, actasRes] = await Promise.all([
      client.from('comisiones').select('id', { count: 'exact', head: true }),
      client.from('solicitudes').select('id', { count: 'exact', head: true }),
      client.from('proyectos').select('id', { count: 'exact', head: true }),
      client.from('asambleas_actas').select('id', { count: 'exact', head: true }),
    ])

    if (comRes.error) {
      return {
        connected: false,
        mode: 'error',
        message: `Supabase respondió con error (${comRes.error.message}).`,
      }
    }

    return {
      connected: true,
      mode: 'supabase_live',
      message: `Conectado en vivo a Supabase PostgreSQL (${comRes.count ?? 6} comisiones, ${solRes.count ?? 0} solicitudes, ${proyRes.count ?? 0} proyectos y ${actasRes.count ?? 0} actas sincronizadas).`,
    }
  } catch (err) {
    return {
      connected: false,
      mode: 'network_error',
      message: `No se pudo conectar con Supabase: ${err?.message || 'Error de red'}.`,
    }
  }
}

export async function fetchAllFromSupabase() {
  const client = getSupabaseClient()
  if (!client) return { connected: false }

  try {
    const [solRes, proyRes, tarRes, qaRes, actRes, histRes] = await Promise.all([
      client.from('solicitudes').select('*').order('id', { ascending: false }),
      client.from('proyectos').select('*').order('id', { ascending: true }),
      client.from('tareas_proyecto').select('*').order('id', { ascending: true }),
      client.from('casos_prueba_qa').select('*').order('id', { ascending: true }),
      client.from('asambleas_actas').select('*').order('id', { ascending: false }),
      client.from('historial_cambios').select('*').order('id', { ascending: false }).limit(50),
    ])

    if (solRes.error) {
      return { connected: false, error: solRes.error.message }
    }

    const solicitudes = (solRes.data || []).map((r) => ({
      id: String(r.id),
      title: String(r.titulo),
      from: String(r.area_solicitante),
      solicitanteCode: String(r.solicitante_id || 'D-02'),
      type: String(r.tipo_solucion || 'Formulario'),
      description: String(r.descripcion || ''),
      targetDate: r.fecha_objetivo ? String(r.fecha_objetivo) : '2026-11-15',
      priority: String(r.prioridad || 'Media'),
      date: String(r.etiqueta_fecha || 'Hace 2 días'),
      status: String(r.estado || 'Por evaluar'),
      cancelReason: r.motivo_cancelacion ? String(r.motivo_cancelacion) : undefined,
    }))

    const proyectos = (proyRes.data || []).map((p) => ({
      id: String(p.id),
      solicitudId: p.solicitud_origen_id ? String(p.solicitud_origen_id) : undefined,
      name: String(p.nombre),
      description: String(p.descripcion || ''),
      category: String(p.categoria || 'Sitio web'),
      status: String(p.estado || 'En desarrollo'),
      progress: Number(p.progreso ?? 0),
      tone: String(p.tono_visual || 'mint'),
      initials:
        Array.isArray(p.iniciales_equipo) && p.iniciales_equipo.length
          ? p.iniciales_equipo
          : ['ML', 'JC', 'SF'],
      date: String(p.fecha_estimada_etiqueta || '18 oct'),
      commission: String(p.comisiones_asignadas || 'Programación + Diseño'),
      hoursPc: Number(p.horas_pc_asignadas ?? 14),
      bugsCount: Number(p.bugs_detectados ?? 0),
      testCasesCount: Number(p.casos_prueba_ejecutados ?? 20),
    }))

    const tareas = (tarRes.data || []).map((t) => ({
      id: String(t.id),
      projectId: String(t.proyecto_id),
      projectName: String(t.proyecto_id),
      commission: String(t.comision_id === 'COM-02' ? 'Diseño y experiencia' : t.comision_id === 'COM-04' ? 'Pruebas y calidad' : t.comision_id === 'COM-03' ? 'Contenidos' : t.comision_id === 'COM-06' ? 'Documentación y soporte' : 'Programación'),
      assignee: String(t.responsable_nombre || 'Martina L. (S-01)'),
      title: String(t.titulo),
      status: String(t.estado || 'En curso'),
      dueDate: String(t.fecha_compromiso || '20 oct'),
      onTime: Boolean(t.entregada_en_fecha ?? true),
    }))

    const pruebasQA = (qaRes.data || []).map((q) => ({
      id: String(q.id),
      projectId: String(q.proyecto_id),
      projectName:
        proyectos.find((pr) => pr.id === String(q.proyecto_id))?.name || String(q.proyecto_id),
      type: String(q.tipo_prueba || 'Validación de campos'),
      description: String(q.descripcion_caso || ''),
      casesExecuted: Number(q.casos_ejecutados ?? 25),
      bugsFound: Number(q.bugs_detectados ?? 0),
      status: String(q.estado_correccion || 'En corrección'),
      reportedBy: String(q.reportado_por_id || 'Agustín R. (Ref. QA)'),
      date: '20 oct',
    }))

    const actas = (actRes.data || []).map((a) => ({
      id: String(a.id),
      date: String(a.fecha_etiqueta || '18 SEP'),
      title: String(a.titulo),
      type: String(a.tipo_sesion || 'Reunión del Consejo'),
      detail: String(a.resumen_detalle || ''),
      agreements: String(a.acuerdos_aprobados || ''),
      attendees: Number(a.asistentes_presentes ?? 19),
      totalMembers: Number(a.padron_total ?? 20),
      status: String(a.estado_acta || 'Publicada'),
    }))

    const historial = (histRes.data || []).map((h) => ({
      id: `LOG-${String(h.id).padStart(3, '0')}`,
      entity: String(h.entidad || 'Solicitudes'),
      recordId: String(h.registro_id),
      action: String(h.accion),
      previousState: String(h.estado_anterior || '—'),
      newState: String(h.estado_nuevo || '—'),
      detail: String(h.detalle || ''),
      user: String(h.usuario_responsable || 'Lucía Pereyra (S-05)'),
      role: String(h.rol_responsable || 'Consejo de Administración'),
      timestamp: h.fecha_hora
        ? new Date(h.fecha_hora).toLocaleString('es-AR', {
            day: '2-digit',
            month: 'short',
            hour: '2-digit',
            minute: '2-digit',
          })
        : 'Reciente',
    }))

    return {
      connected: true,
      solicitudes,
      proyectos,
      tareas,
      pruebasQA,
      actas,
      historial,
    }
  } catch (err) {
    return {
      connected: false,
      error: err?.message || 'Error al sincronizar con Supabase',
    }
  }
}

export async function insertSolicitudSupabase(newReq) {
  const client = getSupabaseClient()
  if (!client) return { savedInSupabase: false }

  const { data, error } = await client
    .from('solicitudes')
    .insert([
      {
        id: newReq.id,
        titulo: newReq.title,
        area_solicitante: newReq.from,
        tipo_solucion: newReq.type,
        prioridad: newReq.priority || 'Media',
        descripcion: newReq.description,
        estado: newReq.status || 'Por evaluar',
        etiqueta_fecha: newReq.date || 'Ahora',
      },
    ])
    .select()

  return { savedInSupabase: !error, data, error: error?.message }
}

export async function updateSolicitudSupabase(id, updates) {
  const client = getSupabaseClient()
  if (!client) return { savedInSupabase: false }

  const payload = {}
  if (updates.title) payload.titulo = updates.title
  if (updates.from) payload.area_solicitante = updates.from
  if (updates.type) payload.tipo_solucion = updates.type
  if (updates.description) payload.descripcion = updates.description
  if (updates.status) payload.estado = updates.status
  if (updates.cancelReason !== undefined) payload.motivo_cancelacion = updates.cancelReason

  const { error } = await client.from('solicitudes').update(payload).eq('id', id)
  return { savedInSupabase: !error, error: error?.message }
}

export async function insertProjectSupabase(newProj) {
  const client = getSupabaseClient()
  if (!client) return { savedInSupabase: false }

  const { data, error } = await client
    .from('proyectos')
    .insert([
      {
        id: newProj.id,
        solicitud_origen_id: newProj.solicitudId || null,
        nombre: newProj.name,
        descripcion: newProj.description,
        categoria: newProj.category || 'Herramienta',
        estado: newProj.status || 'Por comenzar',
        progreso: newProj.progress ?? 10,
        comision_principal_id: 'COM-01',
        comisiones_asignadas: newProj.commission || 'Programación + Diseño',
        tono_visual: newProj.tone || 'mint',
        iniciales_equipo: newProj.initials || ['ML', 'SF', 'EV'],
        fecha_estimada_etiqueta: newProj.date || '15 nov',
        horas_pc_asignadas: newProj.hoursPc ?? 4,
      },
    ])
    .select()

  return { savedInSupabase: !error, data, error: error?.message }
}

export async function updateProjectSupabase(id, { status, progress }) {
  const client = getSupabaseClient()
  if (!client) return { savedInSupabase: false }

  const payload = {}
  if (status) payload.estado = status
  if (progress !== undefined) payload.progreso = progress

  const { error } = await client.from('proyectos').update(payload).eq('id', id)
  return { savedInSupabase: !error, error: error?.message }
}
