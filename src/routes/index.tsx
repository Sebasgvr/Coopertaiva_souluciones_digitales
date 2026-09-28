import { createFileRoute } from "@tanstack/react-router";
import { useState } from "react";
import {
  ArrowDownRight, ArrowRight, ArrowUpRight, Bell, BookOpen, CalendarDays,
  Check, CheckCircle2, ChevronDown, ChevronLeft, ChevronRight, CircleHelp,
  ClipboardList, Clock3, Code2, Download, FileText, Filter, Folders,
  HeartHandshake, LayoutDashboard, LayoutGrid, List, Menu, MessageCircle,
  MoreHorizontal, Plus, Search, Settings2, ShieldCheck, Sparkles, Users,
  X,
} from "lucide-react";
import { Button } from "@/components/ui/button";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Cooperativa Digital | Espacio de trabajo escolar" },
      { name: "description", content: "Un espacio para organizar solicitudes, proyectos, comisiones y acuerdos de la cooperativa escolar digital." },
      { property: "og:title", content: "Cooperativa Digital | Espacio de trabajo escolar" },
      { property: "og:description", content: "Proyectos y decisiones compartidas para crear soluciones digitales en la escuela." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
  component: Index,
});

type View = "inicio" | "solicitudes" | "proyectos" | "comisiones" | "asamblea";
type Project = { id: string; name: string; description: string; category: string; status: string; progress: number; tone: string; initials: string[]; date: string; commission: string };

const projects: Project[] = [
  { id: "PR-001", name: "Web para la feria escolar", description: "Un espacio para compartir los proyectos y actividades de la feria.", category: "Sitio web", status: "En desarrollo", progress: 68, tone: "coral", initials: ["ML", "JC", "SF"], date: "18 oct", commission: "Programación + Diseño" },
  { id: "PR-002", name: "Inscripción a talleres", description: "Formulario digital para organizar cupos y participantes.", category: "Formulario", status: "En pruebas", progress: 86, tone: "mint", initials: ["AR", "LP"], date: "24 oct", commission: "Programación + Pruebas" },
  { id: "PR-003", name: "Cartelera de novedades", description: "Información escolar clara y accesible para toda la comunidad.", category: "Herramienta", status: "Por comenzar", progress: 12, tone: "sun", initials: ["EV", "NS"], date: "05 nov", commission: "Contenidos + Diseño" },
  { id: "PR-004", name: "Guía digital de biblioteca", description: "Una manera sencilla de explorar los recursos disponibles.", category: "Sitio web", status: "Finalizado", progress: 100, tone: "lilac", initials: ["CM", "AT"], date: "12 sep", commission: "Documentación + Programación" },
];

const starterRequests = [
  { id: "SOL-014", title: "Registro para la muestra de ciencias", from: "Departamento de Ciencias", type: "Formulario", date: "Hace 2 días", status: "Por evaluar" },
  { id: "SOL-013", title: "Página informativa para el taller de radio", from: "Taller de Comunicación", type: "Sitio web", date: "Hace 4 días", status: "En revisión" },
  { id: "SOL-012", title: "Calendario de actividades deportivas", from: "Educación Física", type: "Herramienta", date: "Hace 1 semana", status: "Aprobada" },
  { id: "SOL-011", title: "Encuesta de hábitos de lectura", from: "Biblioteca Escolar", type: "Formulario", date: "Hace 2 semanas", status: "Aprobada" },
];

const commissions = [
  { name: "Programación", desc: "Construye y mantiene las soluciones digitales.", icon: Code2, tone: "mint", count: "6 integrantes", lead: "Martina L.", initials: ["ML", "JC", "AR", "+3"] },
  { name: "Diseño y experiencia", desc: "Da forma a interfaces claras y accesibles.", icon: LayoutGrid, tone: "coral", count: "4 integrantes", lead: "Sofía F.", initials: ["SF", "EV", "NS", "+1"] },
  { name: "Contenidos", desc: "Organiza la información y cuida las palabras.", icon: FileText, tone: "sun", count: "3 integrantes", lead: "Elena V.", initials: ["EV", "LP", "CM"] },
  { name: "Pruebas y calidad", desc: "Verifica que todo funcione antes de entregar.", icon: ShieldCheck, tone: "lilac", count: "4 integrantes", lead: "Agustín R.", initials: ["AR", "AT", "JC", "+1"] },
  { name: "Comunicación", desc: "Comparte los proyectos con la comunidad escolar.", icon: MessageCircle, tone: "mint", count: "3 integrantes", lead: "Lucía P.", initials: ["LP", "SF", "NS"] },
  { name: "Documentación y soporte", desc: "Conserva la memoria y acompaña cada entrega.", icon: BookOpen, tone: "coral", count: "3 integrantes", lead: "Camila M.", initials: ["CM", "ML", "AT"] },
];

const nav: { id: View; label: string; icon: typeof LayoutDashboard }[] = [
  { id: "inicio", label: "Inicio", icon: LayoutDashboard },
  { id: "solicitudes", label: "Solicitudes", icon: ClipboardList },
  { id: "proyectos", label: "Proyectos", icon: Folders },
  { id: "comisiones", label: "Comisiones", icon: Users },
  { id: "asamblea", label: "Asamblea y actas", icon: HeartHandshake },
];

const titles: Record<View, { eyebrow: string; title: string; subtitle: string }> = {
  inicio: { eyebrow: "ESPACIO DE TRABAJO", title: "Buen día, equipo.", subtitle: "Así avanzan las ideas que estamos construyendo juntos." },
  solicitudes: { eyebrow: "BANDEJA DE ENTRADA", title: "Solicitudes", subtitle: "Necesidades de la escuela, listas para convertirse en soluciones." },
  proyectos: { eyebrow: "NUESTRO TRABAJO", title: "Proyectos", subtitle: "De la primera idea hasta la entrega a la comunidad." },
  comisiones: { eyebrow: "PERSONAS Y EQUIPOS", title: "Comisiones", subtitle: "Distintos saberes, un mismo propósito." },
  asamblea: { eyebrow: "DECISIONES COMPARTIDAS", title: "Asamblea y actas", subtitle: "Acuerdos abiertos para construir una cooperativa transparente." },
};

function AvatarStack({ initials, small = false }: { initials: string[]; small?: boolean }) {
  return <div className={`avatar-stack ${small ? "avatar-stack-small" : ""}`}>{initials.map((v, i) => <span key={`${v}-${i}`} className={`avatar avatar-${i % 4}`}>{v}</span>)}</div>;
}

function Status({ value }: { value: string }) {
  const kind = value === "Finalizado" || value === "Aprobada" ? "done" : value === "En desarrollo" || value === "En revisión" ? "active" : value === "En pruebas" ? "testing" : "waiting";
  return <span className={`status status-${kind}`}><span className="status-dot" />{value}</span>;
}

function SectionTitle({ title, action, onAction }: { title: string; action?: string; onAction?: () => void }) {
  return <div className="section-title"><h2>{title}</h2>{action && <Button variant="ghost" size="sm" onClick={onAction} className="text-primary font-semibold">{action}<ArrowRight size={15} /></Button>}</div>;
}

function Index() {
  const [view, setView] = useState<View>("inicio");
  const [requests, setRequests] = useState(starterRequests);
  const [filter, setFilter] = useState("Todas");
  const [query, setQuery] = useState("");
  const [board, setBoard] = useState(false);
  const [modal, setModal] = useState(false);
  const [selectedProject, setSelectedProject] = useState<Project | null>(null);
  const [selectedCommission, setSelectedCommission] = useState<string | null>(null);
  const [mobileNav, setMobileNav] = useState(false);
  const [notification, setNotification] = useState(false);
  const [form, setForm] = useState({ title: "", from: "", type: "Sitio web", description: "" });

  const changeView = (next: View) => { setView(next); setMobileNav(false); setQuery(""); setFilter("Todas"); window.scrollTo({ top: 0, behavior: "smooth" }); };
  const submitRequest = (e: React.FormEvent) => {
    e.preventDefault();
    setRequests([{ id: `SOL-${String(requests.length + 11).padStart(3, "0")}`, title: form.title.trim(), from: form.from.trim(), type: form.type, date: "Ahora", status: "Por evaluar" }, ...requests]);
    setForm({ title: "", from: "", type: "Sitio web", description: "" }); setModal(false); changeView("solicitudes");
  };
  const visibleRequests = requests.filter(r => (filter === "Todas" || r.status === filter) && `${r.title} ${r.from} ${r.type}`.toLowerCase().includes(query.toLowerCase()));
  const visibleProjects = projects.filter(p => (filter === "Todas" || p.status === filter) && `${p.name} ${p.category}`.toLowerCase().includes(query.toLowerCase()));

  return <div className="app-shell">
    <aside className={`sidebar ${mobileNav ? "sidebar-open" : ""}`}>
      <div className="brand" onClick={() => changeView("inicio")} role="button" tabIndex={0} onKeyDown={e => e.key === "Enter" && changeView("inicio")}>
        <span className="brand-mark"><span /><span /><span /><span /></span>
        <span className="brand-copy">cooperativa<span>digital</span></span>
      </div>
      <div className="sidebar-rule" />
      <div className="workspace-label">ESPACIO DE TRABAJO</div>
      <nav className="nav-list" aria-label="Navegación principal">{nav.map(item => <Button key={item.id} variant="ghost" className={`nav-item ${view === item.id ? "nav-item-active" : ""}`} onClick={() => changeView(item.id)}><item.icon size={19} strokeWidth={1.8} /><span>{item.label}</span>{item.id === "solicitudes" && <span className="nav-count">{requests.filter(r => r.status === "Por evaluar").length}</span>}</Button>)}</nav>
      <div className="sidebar-bottom"><div className="sidebar-note"><span className="note-icon"><Sparkles size={17}/></span><strong>Una idea puede cambiar mucho.</strong><p>Hagamos tecnología útil para nuestra escuela.</p></div><div className="sidebar-user"><span className="user-avatar">CE</span><span><strong>Equipo cooperativo</strong><small>Espacio de ejemplo</small></span><MoreHorizontal size={18}/></div></div>
    </aside>

    <div className="main-shell">
      <header className="topbar"><div className="topbar-left"><Button variant="ghost" size="icon" className="mobile-menu" aria-label="Abrir menú" onClick={() => setMobileNav(!mobileNav)}>{mobileNav ? <X/> : <Menu/>}</Button><span className="breadcrumb">Cooperativa escolar</span><ChevronRight size={15} className="breadcrumb-chevron"/><strong>{nav.find(n => n.id === view)?.label}</strong></div><div className="topbar-actions"><span className="sample-label"><span/> VISTA DE EJEMPLO</span><Button variant="ghost" size="icon" aria-label="Notificaciones" title="Notificaciones" onClick={() => setNotification(!notification)} className="notification-button"><Bell size={19}/><i/></Button><span className="topbar-avatar">CE</span></div>{notification && <div className="notification-popover"><strong>Notificaciones</strong><p>No hay novedades por ahora.</p></div>}</header>
      <main className="content"><div className="page-heading"><div><p className="eyebrow">{titles[view].eyebrow}</p><h1>{titles[view].title}</h1><p className="page-subtitle">{titles[view].subtitle}</p></div>{view !== "asamblea" && view !== "comisiones" && <Button className="primary-action" onClick={() => setModal(true)}><Plus size={18}/>Nueva solicitud</Button>}</div>

      {view === "inicio" && <>
        <div className="welcome-band"><div className="welcome-content"><div className="welcome-kicker"><span className="live-dot"/> CONSTRUYENDO EN COMUNIDAD</div><h2>Pequeñas soluciones.<br/><em>Grandes cambios.</em></h2><p>Cada proyecto empieza escuchando una necesidad de nuestra escuela.</p><Button onClick={() => changeView("proyectos")} className="welcome-link">Explorar proyectos <ArrowUpRight size={16}/></Button></div><div className="welcome-art" aria-hidden="true"><div className="art-grid"/><div className="art-circle circle-one"/><div className="art-circle circle-two"/><div className="art-tile tile-one">&lt;/&gt;</div><div className="art-tile tile-two"><Check size={35}/></div><div className="art-spark spark-one">✳</div><div className="art-spark spark-two">✳</div><div className="art-line line-one"/><div className="art-line line-two"/></div></div>
        <div className="metrics"><div className="metric"><span className="metric-icon metric-coral"><Folders size={20}/></span><div><strong>04</strong><span>Proyectos en marcha</span></div><ArrowUpRight size={17} className="metric-arrow"/></div><div className="metric"><span className="metric-icon metric-mint"><ClipboardList size={20}/></span><div><strong>{requests.filter(r => r.status === "Por evaluar").length.toString().padStart(2, "0")}</strong><span>Solicitudes por evaluar</span></div><ArrowUpRight size={17} className="metric-arrow"/></div><div className="metric"><span className="metric-icon metric-sun"><Users size={20}/></span><div><strong>06</strong><span>Comisiones de trabajo</span></div><ArrowUpRight size={17} className="metric-arrow"/></div></div>
        <div className="dashboard-grid"><section className="dashboard-main"><SectionTitle title="Proyectos destacados" action="Ver todos" onAction={() => changeView("proyectos")}/><div className="featured-list">{projects.slice(0,3).map(p => <div className="featured-row" key={p.id} onClick={() => setSelectedProject(p)} role="button" tabIndex={0} onKeyDown={e => e.key === "Enter" && setSelectedProject(p)}><div className={`project-glyph tone-${p.tone}`}><ProjectGlyph tone={p.tone}/></div><div className="featured-info"><strong>{p.name}</strong><span>{p.category} <b>·</b> {p.commission}</span></div><div className="featured-status"><Status value={p.status}/><span>{p.progress}% completado</span></div><ChevronRight size={18} className="row-chevron"/></div>)}</div></section><section className="dashboard-side"><SectionTitle title="Próxima asamblea"/><div className="meeting-panel"><div className="date-badge"><span>OCT</span><strong>15</strong></div><div className="meeting-copy"><strong>Asamblea general</strong><span><Clock3 size={14}/> 14:00 h · Sala de informática</span></div><div className="meeting-divider"/><p>Ideas para nuevos proyectos y seguimiento de los equipos.</p><Button variant="outline" className="meeting-button" onClick={() => changeView("asamblea")}>Ver orden del día <ArrowRight size={16}/></Button></div></section></div>
        <div className="bottom-highlight"><div className="highlight-icon"><HeartHandshake size={24}/></div><div><strong>La tecnología se construye en equipo</strong><p>Conocé a las personas detrás de cada solución.</p></div><Button variant="ghost" onClick={() => changeView("comisiones")}>Conocer comisiones <ArrowRight size={16}/></Button></div>
      </>}

      {view === "solicitudes" && <><div className="view-summary"><span className="summary-icon"><ClipboardList size={22}/></span><div><strong>{requests.length} solicitudes recibidas</strong><p>Las ideas se evalúan en conjunto antes de convertirse en proyectos.</p></div><span className="summary-decoration">✳</span></div><div className="controls-row"><div className="filter-tabs">{["Todas", "Por evaluar", "En revisión", "Aprobada"].map(v => <Button key={v} variant="ghost" className={filter === v ? "filter-active" : ""} onClick={() => setFilter(v)}>{v}</Button>)}</div><div className="search-field"><Search size={17}/><input aria-label="Buscar solicitudes" placeholder="Buscar solicitudes..." value={query} onChange={e => setQuery(e.target.value)}/></div></div><div className="table-wrap"><table><thead><tr><th>SOLICITUD</th><th>SOLICITANTE</th><th>TIPO</th><th>ESTADO</th><th>RECIBIDA</th></tr></thead><tbody>{visibleRequests.map(r => <tr key={r.id}><td><span className="row-id">{r.id}</span><strong>{r.title}</strong></td><td>{r.from}</td><td><span className="type-pill">{r.type}</span></td><td><Status value={r.status}/></td><td>{r.date}</td></tr>)}</tbody></table>{visibleRequests.length === 0 && <div className="empty-state">No hay solicitudes con esos criterios.</div>}</div></>}

      {view === "proyectos" && <><div className="project-overview"><div><span className="eyebrow">PANORAMA GENERAL</span><h2>De la idea a la realidad.</h2><p>Seguimos cada paso para entregar soluciones útiles, accesibles y bien hechas.</p></div><div className="overview-count"><strong>04</strong><span>proyectos<br/>registrados</span></div></div><div className="controls-row"><div className="filter-tabs">{["Todas", "Por comenzar", "En desarrollo", "En pruebas", "Finalizado"].map(v => <Button key={v} variant="ghost" className={filter === v ? "filter-active" : ""} onClick={() => setFilter(v)}>{v}</Button>)}</div><div className="project-tools"><div className="search-field"><Search size={17}/><input aria-label="Buscar proyectos" placeholder="Buscar proyectos..." value={query} onChange={e => setQuery(e.target.value)}/></div><div className="view-switch"><Button variant="ghost" size="icon" title="Vista de tarjetas" aria-label="Vista de tarjetas" className={!board ? "switch-active" : ""} onClick={() => setBoard(false)}><LayoutGrid size={17}/></Button><Button variant="ghost" size="icon" title="Vista de tablero" aria-label="Vista de tablero" className={board ? "switch-active" : ""} onClick={() => setBoard(true)}><List size={18}/></Button></div></div></div>{board ? <div className="kanban">{["Por comenzar", "En desarrollo", "En pruebas", "Finalizado"].map(stage => <div className="kanban-column" key={stage}><div className="kanban-heading"><span className={`kanban-dot stage-${stage.replaceAll(" ", "-").toLowerCase()}`}/><strong>{stage}</strong><small>{visibleProjects.filter(p => p.status === stage).length}</small></div>{visibleProjects.filter(p => p.status === stage).map(p => <div className="kanban-card" key={p.id} onClick={() => setSelectedProject(p)} role="button" tabIndex={0} onKeyDown={e => e.key === "Enter" && setSelectedProject(p)}><span className="row-id">{p.id}</span><strong>{p.name}</strong><p>{p.description}</p><div><AvatarStack initials={p.initials} small/><ArrowUpRight size={16}/></div></div>)}</div>)}</div> : <div className="project-grid">{visibleProjects.map(p => <div className="project-card" key={p.id} onClick={() => setSelectedProject(p)} role="button" tabIndex={0} onKeyDown={e => e.key === "Enter" && setSelectedProject(p)}><div className={`project-card-art tone-${p.tone}`}><span className="project-card-tag">{p.category}</span><ProjectGlyph tone={p.tone}/><span className="art-corner">✳</span></div><div className="project-card-body"><div className="project-card-meta"><span>{p.id}</span><Status value={p.status}/></div><h3>{p.name}</h3><p>{p.description}</p><div className="progress-label"><span>Progreso</span><strong>{p.progress}%</strong></div><div className="progress-track"><span style={{ width: `${p.progress}%` }}/></div><div className="project-card-footer"><AvatarStack initials={p.initials} small/><span><CalendarDays size={14}/>{p.date}</span></div></div></div>)}</div>}{visibleProjects.length === 0 && <div className="empty-state">No hay proyectos con esos criterios.</div>}</>}

      {view === "comisiones" && <><div className="view-summary"><span className="summary-icon"><Users size={22}/></span><div><strong>Seis formas de aportar</strong><p>Cada integrante puede aprender, colaborar y rotar de comisión al terminar un proyecto.</p></div><span className="summary-decoration">✳</span></div><div className="commission-grid">{commissions.map((c, i) => <div className="commission-card" key={c.name}><div className="commission-top"><span className={`commission-icon tone-${c.tone}`}><c.icon size={25} strokeWidth={1.7}/></span><span className="commission-number">0{i+1}</span></div><h2>{c.name}</h2><p>{c.desc}</p><div className="commission-divider"/><div className="commission-people"><AvatarStack initials={c.initials} small/><span>{c.count}</span></div><Button variant="ghost" className="commission-link" onClick={() => setSelectedCommission(c.name)}>Ver comisión <ArrowUpRight size={16}/></Button></div>)}</div></>}

      {view === "asamblea" && <><div className="assembly-hero"><div className="assembly-symbol"><HeartHandshake size={30}/></div><div><span className="eyebrow">UN EQUIPO, UNA VOZ POR PERSONA</span><h2>Decidimos en conjunto.</h2><p>La asamblea reúne a todos los socios para conversar, proponer y tomar decisiones. Cada voz cuenta.</p></div><span className="assembly-art" aria-hidden="true">✳</span></div><div className="assembly-grid"><section><SectionTitle title="Próxima reunión"/><div className="agenda-panel"><div className="agenda-head"><div className="date-badge"><span>OCT</span><strong>15</strong></div><div><span className="eyebrow">ASAMBLEA GENERAL</span><h3>Encuentro de octubre</h3><p><Clock3 size={15}/> 14:00 h <span>·</span> Sala de informática</p></div></div><div className="agenda-divider"/><h4>Orden del día</h4><ol><li><span>01</span>Avance de proyectos en curso</li><li><span>02</span>Evaluación de nuevas solicitudes</li><li><span>03</span>Propuestas de las comisiones</li><li><span>04</span>Próximos pasos y acuerdos</li></ol></div></section><section><SectionTitle title="Actas recientes"/><div className="minutes-list">{[{ date: "18 SEP", title: "Reunión del Consejo", detail: "Seguimiento de proyectos y tareas" }, { date: "04 SEP", title: "Asamblea extraordinaria", detail: "Prioridades para el segundo semestre" }, { date: "12 AGO", title: "Reunión del Consejo", detail: "Organización de comisiones" }].map(m => <div className="minute-row" key={m.date}><span className="minute-icon"><FileText size={18}/></span><div><strong>{m.title}</strong><span>{m.detail}</span></div><small>{m.date}</small></div>)}</div><div className="principle-note"><ShieldCheck size={22}/><div><strong>Decisiones transparentes</strong><p>Los acuerdos y avances se registran para que toda la cooperativa pueda consultarlos.</p></div></div></section></div></>}
      <footer className="page-footer"><span>Cooperativa Escolar de Soluciones Digitales</span><span>Propuesta visual · Datos de ejemplo</span></footer>
      </main>
    </div>

    {modal && <div className="overlay" onMouseDown={e => e.target === e.currentTarget && setModal(false)}><div className="dialog" role="dialog" aria-modal="true" aria-labelledby="dialog-title"><div className="dialog-head"><div><span className="eyebrow">NUEVA IDEA</span><h2 id="dialog-title">Crear solicitud</h2></div><Button variant="ghost" size="icon" aria-label="Cerrar" onClick={() => setModal(false)}><X size={20}/></Button></div><p>Contanos qué necesita la escuela para que el equipo pueda evaluarlo.</p><form onSubmit={submitRequest}><label>Nombre de la solicitud<input required value={form.title} onChange={e => setForm({...form, title: e.target.value})} placeholder="Ej. Inscripción a la feria de ciencias"/></label><label>Área o persona solicitante<input required value={form.from} onChange={e => setForm({...form, from: e.target.value})} placeholder="Ej. Departamento de Ciencias"/></label><label>Tipo de solución<select value={form.type} onChange={e => setForm({...form, type: e.target.value})}><option>Sitio web</option><option>Formulario</option><option>Herramienta</option><option>Otro</option></select></label><label>¿Qué problema queremos resolver?<textarea required rows={3} value={form.description} onChange={e => setForm({...form, description: e.target.value})} placeholder="Describí brevemente la necesidad..."/></label><div className="dialog-actions"><Button type="button" variant="outline" onClick={() => setModal(false)}>Cancelar</Button><Button type="submit">Enviar solicitud <ArrowRight size={16}/></Button></div></form></div></div>}
    {selectedProject && <div className="overlay" onMouseDown={e => e.target === e.currentTarget && setSelectedProject(null)}><div className="detail-dialog" role="dialog" aria-modal="true" aria-labelledby="project-title"><Button variant="ghost" size="icon" aria-label="Cerrar" className="detail-close" onClick={() => setSelectedProject(null)}><X size={20}/></Button><div className={`detail-art tone-${selectedProject.tone}`}><ProjectGlyph tone={selectedProject.tone}/></div><div className="detail-body"><span className="eyebrow">{selectedProject.id} · {selectedProject.category}</span><h2 id="project-title">{selectedProject.name}</h2><Status value={selectedProject.status}/><p>{selectedProject.description}</p><div className="detail-facts"><div><span>Comisiones</span><strong>{selectedProject.commission}</strong></div><div><span>Fecha estimada</span><strong>{selectedProject.date}</strong></div><div><span>Avance</span><strong>{selectedProject.progress}%</strong></div></div><div className="progress-track"><span style={{width: `${selectedProject.progress}%`}}/></div><div className="detail-team"><AvatarStack initials={selectedProject.initials}/><span>Equipo del proyecto</span></div></div></div></div>}
    {selectedCommission && <div className="overlay" onMouseDown={e => e.target === e.currentTarget && setSelectedCommission(null)}><div className="detail-dialog commission-dialog" role="dialog" aria-modal="true" aria-labelledby="commission-title"><Button variant="ghost" size="icon" aria-label="Cerrar" className="detail-close" onClick={() => setSelectedCommission(null)}><X size={20}/></Button><div className="detail-body"><span className="eyebrow">COMISIÓN DE TRABAJO</span><h2 id="commission-title">{selectedCommission}</h2><p>{commissions.find(c => c.name === selectedCommission)?.desc}</p><div className="detail-facts"><div><span>Integrantes</span><strong>{commissions.find(c => c.name === selectedCommission)?.count}</strong></div><div><span>Referente</span><strong>{commissions.find(c => c.name === selectedCommission)?.lead}</strong></div></div><div className="detail-team"><AvatarStack initials={commissions.find(c => c.name === selectedCommission)?.initials ?? []}/><span>Equipo de la comisión</span></div></div></div></div>}
  </div>;
}

function ProjectGlyph({ tone }: { tone: string }) {
  return <div className={`glyph glyph-${tone}`} aria-hidden="true"><div className="glyph-window"><span className="glyph-dots"><i/><i/><i/></span><div className="glyph-content"><span/><span/><span/></div></div><div className="glyph-shape"/></div>;
}