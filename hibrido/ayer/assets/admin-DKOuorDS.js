var D=Object.defineProperty;var R=(d,u,e)=>u in d?D(d,u,{enumerable:!0,configurable:!0,writable:!0,value:e}):d[u]=e;var O=(d,u,e)=>R(d,typeof u!="symbol"?u+"":u,e);import{c as G,R as U}from"./client-B4bZkblM.js";import{D as L,c as $}from"./dc-CfeAgKAK.js";const c="var(--good)",g="var(--bad-strong)",P="var(--warn)",k="var(--accent)",b="var(--text-2)",h="chinola-admin-token",V=[["metricas","Métricas"],["usuarios","Usuarios"],["libretas","Libretas"],["ajustes","Ajustes"],["entrar","Entrar"],["ia","IA"],["whatsapp","WhatsApp"],["telegram","Telegram"],["cobro","Cobro"],["plantillas","Plantillas"],["correo","Correo"],["integraciones","Integraciones"],["auditoria","Auditoría"],["equipo","Equipo"]],B={metricas:["Panel general","Cómo va Chinola"],usuarios:["Gestión de usuarios","Usuarios"],libretas:["Libretas de la plataforma","Libretas"],ajustes:["Configuración del servicio","Ajustes"],entrar:["Entrar con Apple y con Google","Entrar"],cobro:["Cobro por la App Store","Cobro"],plantillas:["Correos que envía la app","Plantillas"],correo:["Avisos y registro de envíos","Correo"],integraciones:["Claves de API y llamadas","Integraciones"],auditoria:["Registro de auditoría","Auditoría"],equipo:["Tu cuenta y el equipo de administradores","Equipo"]},Q=[{seccion:"ajustes",titulo:"General",desc:"Identidad del servicio y reglas de entrada.",campos:[{clave:"general.nombre",etiqueta:"Nombre del servicio"},{clave:"general.url",etiqueta:"URL pública",ayuda:"Se usa para armar los enlaces de los correos."},{clave:"general.soporte",etiqueta:"Correo de soporte"},{clave:"general.idioma",etiqueta:"Idioma por defecto",tipo:"select",opciones:[["es","Español"],["en","English"],["fr","Français"]]},{clave:"general.permitirRegistro",etiqueta:"Permitir registros nuevos",tipo:"switch"},{clave:"general.requerirVerificacion",etiqueta:"Exigir verificar el correo",tipo:"switch",ayuda:"Si se activa, nadie entra hasta confirmar su correo."}]},{seccion:"entrar",titulo:"Entrar con Apple y con Google",desc:"Aquí no hay secretos: para comprobar un token de identidad basta con las llaves públicas del proveedor y saber para qué app tiene que ser. Vacío = ese botón apagado.",campos:[{clave:"apple.servicioWeb",etiqueta:"Services ID de Apple (web)",ayuda:"El que creaste en Identifiers → Services IDs. En el teléfono no hace falta: allí vale el Bundle ID."},{clave:"google.clienteWeb",etiqueta:"Client ID de Google (web)",ayuda:"El del tipo «Web application», acaba en .apps.googleusercontent.com."},{clave:"google.clienteIos",etiqueta:"Client ID de Google (iOS)",ayuda:"El del tipo «iOS», con el bundle de la app."},{clave:"google.secretoWeb",etiqueta:"Client secret de Google (web)",tipo:"clave",ayuda:"Empieza por GOCSPX-. Solo hace falta para el botón del navegador."}]},{seccion:"ia",titulo:"Chino con IA",desc:"Varios proveedores a la vez, en orden: si uno falla o se queda sin crédito, se pasa al siguiente. Sin ninguno activo la IA no se ofrece a nadie; con alguno, cada persona la enciende en su app (viene apagada).",campos:[{clave:"ia.instrucciones",etiqueta:"Instrucciones extra para Chino",ayuda:"Se añaden a las de la casa: tono, reglas, lo que no debe hacer. Opcional."}]},{seccion:"whatsapp",titulo:"WhatsApp (Cloud API de Meta)",desc:"Crea una app en developers.facebook.com con el producto WhatsApp, pega el token permanente y el id del número, y registra el webhook https://chinola.fente.com.do/api/whatsapp/webhook con el verify token que pongas aquí.",campos:[{clave:"whatsapp.token",etiqueta:"Token permanente",tipo:"clave"},{clave:"whatsapp.phoneId",etiqueta:"Phone number ID"},{clave:"whatsapp.numero",etiqueta:"Número (como se marca)",ayuda:"Se le enseña a la gente para que le escriba: +1 809 …"},{clave:"whatsapp.verifyToken",etiqueta:"Verify token",tipo:"clave",ayuda:"Cualquier texto largo; el mismo que pongas en Meta."}]},{seccion:"telegram",titulo:"Telegram (dos pasos y anotar por mensaje)",desc:"Un bot de Telegram (gratis). Crea uno con @BotFather, pega aquí su token y prueba: el servidor pone el webhook solo. Sirve para el código de entrada y para anotar escribiéndole.",campos:[{clave:"telegram.botToken",etiqueta:"Token del bot",tipo:"clave",ayuda:"El que te da @BotFather: 123456789:AAAA…"},{clave:"telegram.bot",etiqueta:"Nombre del bot",ayuda:"Se rellena solo al probar (sin la @)."}]},{seccion:"cobro",titulo:"Cobro por la App Store",desc:"Sin estas cuatro cosas el cobro queda apagado y la app lo dice en vez de dar un plan por bueno.",campos:[{clave:"apple.bundleId",etiqueta:"Bundle ID",ayuda:"El mismo que lleva la app en App Store Connect."},{clave:"apple.issuerId",etiqueta:"Issuer ID",ayuda:"Users and Access → Integrations → App Store Server API."},{clave:"apple.keyId",etiqueta:"Key ID",ayuda:"El de la clave .p8 que descargaste ahí mismo."},{clave:"apple.clave",etiqueta:"Clave .p8",tipo:"clave",ayuda:"El archivo entero, con sus dos líneas de cabecera."},{clave:"apple.entorno",etiqueta:"Entorno",tipo:"select",opciones:[["produccion","Producción"],["sandbox","Sandbox (pruebas)"]]},{clave:"apple.productoPro",etiqueta:"Producto del plan Pro"},{clave:"apple.productoNegocio",etiqueta:"Producto del plan Negocio"}]},{seccion:"ajustes",titulo:"Notificaciones",desc:"Qué correos salen automáticamente. Apagar uno no borra su plantilla.",campos:[{clave:"notif.bienvenida",etiqueta:"Bienvenida al registrarse",tipo:"switch"},{clave:"notif.verificar",etiqueta:"Verificación de correo",tipo:"switch"},{clave:"notif.restablecer",etiqueta:"Restablecer contraseña",tipo:"switch"},{clave:"notif.claveCambiada",etiqueta:"Aviso de contraseña cambiada",tipo:"switch"},{clave:"notif.invitacion",etiqueta:"Invitación a una libreta",tipo:"switch"},{clave:"notif.avisoMasivo",etiqueta:"Avisos masivos",tipo:"switch"}]}],v=(d,u)=>{if(!d)return"—";try{const e=new Date(d),r=e.toLocaleDateString("es-DO",{day:"2-digit",month:"short",year:"2-digit"});return u?r+" "+e.toLocaleTimeString("es-DO",{hour:"2-digit",minute:"2-digit"}):r}catch{return d.slice(0,16).replace("T"," ")}},S=d=>{const u=String(d||"").trim().split(/\s+/);return((u[0]||"")[0]||"?").toUpperCase()+((u[1]||"")[0]||"").toUpperCase()};class H extends L{constructor(){super(...arguments);O(this,"state",{paso:localStorage.getItem(h)?"comprobando":"acceso",acceso:{email:"",clave:""},error:"",entrando:!1,reto:"",codigo:"",pistaCorreo:"",admin:null,vista:"metricas",aviso:"",avisoTipo:"ok",cargando:!1,tema:(()=>{try{return localStorage.getItem("chinola-admin-tema")||""}catch{return""}})(),q:"",filtro:"Todos",menu:null,metricas:null,usuarios:[],libretas:[],auditoria:[],envios:[],apiRegistro:[],apiClaves:[],config:{},cambios:{},guardando:!1,pruebaDestino:"",erroresCampo:{},probando:"",pruebaApple:null,plantillas:[],plantillaId:null,editor:null,previa:null,creando:!1,nuevaPlantilla:"",avisoDestino:"todos",avisoTitulo:"",avisoMensaje:"",enviandoAviso:!1,proveedores:[],provForm:null,guardandoProv:!1,iaProveedores:[],iaPresets:{},iaEjemplo:null,iaForm:null,guardandoIA:!1,pruebaIAProv:{},admins:[],nuevoAdmin:{email:"",nombre:"",clave:""},creandoAdmin:!1,claveForm:{actual:"",nueva:""},cambiandoClave:!1,guardandoMfa:!1})}componentDidMount(){this.state.paso==="comprobando"&&this.comprobar()}async api(e,r={}){const o=await fetch("/api"+e,{method:r.metodo||"GET",headers:{"content-type":"application/json",authorization:"Bearer "+(localStorage.getItem(h)||"")},body:r.cuerpo?JSON.stringify(r.cuerpo):void 0});let t={};try{t=await o.json()}catch{}if(!o.ok){const n=new Error(t.error||"Error "+o.status);throw n.estado=o.status,n}return t}avisar(e,r="ok"){clearTimeout(this.tAviso),this.setState({aviso:e,avisoTipo:r}),this.tAviso=setTimeout(()=>this.setState({aviso:""}),5e3)}async comprobar(){try{const{admin:e}=await this.api("/admin/yo");this.setState({paso:"consola",admin:e}),this.cargar()}catch{localStorage.removeItem(h),this.setState({paso:"acceso"})}}async entrar(){const{email:e,clave:r}=this.state.acceso;this.setState({entrando:!0,error:""});try{const o=await this.api("/admin/entrar",{metodo:"POST",cuerpo:{email:String(e).trim().toLowerCase(),clave:r}});if(o.mfa){this.setState({paso:"codigo",reto:o.reto,pistaCorreo:o.pista||"",codigo:""});return}localStorage.setItem(h,o.token),this.setState({paso:"consola",admin:o.admin,acceso:{email:"",clave:""}}),this.cargar()}catch(o){this.setState({error:o.message})}finally{this.setState({entrando:!1})}}async entrarCodigo(){this.setState({entrando:!0,error:""});try{const e=await this.api("/admin/entrar/codigo",{metodo:"POST",cuerpo:{reto:this.state.reto,codigo:this.state.codigo}});localStorage.setItem(h,e.token),this.setState({paso:"consola",admin:e.admin,acceso:{email:"",clave:""},reto:"",codigo:""}),this.cargar()}catch(e){this.setState({error:e.message})}finally{this.setState({entrando:!1})}}async salir(){try{await this.api("/admin/salir",{metodo:"POST"})}catch{}localStorage.removeItem(h),this.setState({paso:"acceso",admin:null})}alternaTema(){let e;try{const o=document.documentElement.dataset.tema;e=o?o==="dark":!window.matchMedia("(prefers-color-scheme: light)").matches}catch{e=!0}const r=e?"light":"dark";document.documentElement.dataset.tema=r;try{localStorage.setItem("chinola-admin-tema",r)}catch{}this.setState({tema:r})}async cargar(){var e;this.setState({cargando:!0});try{const[r,o,t,n,s,x,y,w,A,C,m]=await Promise.all([this.api("/admin/metricas"),this.api("/admin/usuarios"),this.api("/admin/libretas"),this.api("/admin/auditoria"),this.api("/admin/config"),this.api("/admin/plantillas"),this.api("/admin/envios"),this.api("/admin/api-log"),this.api("/admin/admins"),this.api("/admin/correo/proveedores"),this.api("/admin/ia/proveedores").catch(()=>({proveedores:[],presets:{},ejemplo:null}))]);this.setState({metricas:r,usuarios:o.usuarios,libretas:t.libretas,auditoria:n.auditoria,config:s.config,cambios:{},plantillas:x.plantillas,envios:y.envios,apiRegistro:w.registro,apiClaves:w.claves,admins:A.admins,proveedores:C.proveedores,pruebaDestino:this.state.pruebaDestino||((e=this.state.admin)==null?void 0:e.email)||"",iaProveedores:m.proveedores||[],iaPresets:m.presets||{},iaEjemplo:m.ejemplo||null}),!this.state.plantillaId&&x.plantillas.length&&this.elegirPlantilla(x.plantillas[0].id,x.plantillas)}catch(r){if(r.estado===401)return this.salir();this.avisar(r.message,"error")}finally{this.setState({cargando:!1})}}valor(e){const r=this.state;return e in r.cambios?r.cambios[e]:r.config[e]}cambiar(e,r){const o={...this.state.erroresCampo};delete o[e],this.setState({cambios:{...this.state.cambios,[e]:r},erroresCampo:o})}async guardarAjustes(){const e=this.state.cambios;if(!Object.keys(e).length)return this.avisar("No hay nada que guardar.","ok");this.setState({guardando:!0});try{const r=await this.api("/admin/config",{metodo:"PUT",cuerpo:{config:e}}),o=r.errores||{},t={};for(const s of Object.keys(e))s in o&&(t[s]=e[s]);this.setState({config:r.config,cambios:t,erroresCampo:o});const n=Object.keys(o).length;n?this.avisar(n===1?"Un campo tiene un error, revísalo.":`${n} campos tienen errores, revísalos.`,"error"):this.avisar("Ajustes guardados. Ya están en uso."),this.api("/admin/metricas").then(s=>this.setState({metricas:s})).catch(()=>{})}catch(r){this.avisar(r.message,"error")}finally{this.setState({guardando:!1})}}async probarCorreo(e){var o;const r=this.state.pruebaDestino||((o=this.state.admin)==null?void 0:o.email);if(Object.keys(this.state.cambios).length){this.avisar("Guarda los ajustes antes de probar, para que la prueba use la configuración nueva.","error");return}this.avisar("Enviando…");try{const t=await this.api("/admin/correo/probar",{metodo:"POST",cuerpo:{destino:r,plantilla:e}});this.avisar(t.ok?"Correo enviado a "+r+".":"No salió: "+t.error,t.ok?"ok":"error")}catch(t){this.avisar(t.message,"error")}this.api("/admin/envios").then(t=>this.setState({envios:t.envios})).catch(()=>{})}async recargaIA(){const e=await this.api("/admin/ia/proveedores");this.setState({iaProveedores:e.proveedores||[],iaPresets:e.presets||{},iaEjemplo:e.ejemplo||null})}nuevoIA(e){const r=(this.state.iaPresets||{})[e]||(this.state.iaPresets||{}).deepseek||{nombre:"",tipo:"openai",base:"",modelo:""};this.setState({iaForm:{id:null,preset:e||"deepseek",nombre:r.nombre,tipo:r.tipo,base:r.base,modelo:r.modelo,clave:"",activo:!0}})}editarIA(e){this.setState({iaForm:{...e,preset:"otro"}})}campoIA(e,r){this.setState({iaForm:{...this.state.iaForm,[e]:r}})}presetIA(e){const r=(this.state.iaPresets||{})[e];r&&this.setState({iaForm:{...this.state.iaForm,preset:e,nombre:r.nombre,tipo:r.tipo,base:r.base,modelo:r.modelo}})}async guardarIA(){const e=this.state.iaForm;this.setState({guardandoIA:!0});try{e.id?await this.api("/admin/ia/proveedores/"+e.id,{metodo:"PUT",cuerpo:e}):await this.api("/admin/ia/proveedores",{metodo:"POST",cuerpo:e}),await this.recargaIA(),this.setState({iaForm:null}),this.avisar("Proveedor guardado.")}catch(r){this.avisar(r.message,"error")}finally{this.setState({guardandoIA:!1})}}async alternaIA(e,r){try{await this.api("/admin/ia/proveedores/"+e+"/activo",{metodo:"POST",cuerpo:{activo:r}}),await this.recargaIA()}catch(o){this.avisar(o.message,"error")}}async quitarIA(e,r){if(window.confirm("¿Quitar el proveedor «"+r+"»?"))try{await this.api("/admin/ia/proveedores/"+e,{metodo:"DELETE"}),await this.recargaIA()}catch(o){this.avisar(o.message,"error")}}async subeIA(e,r){const o=this.state.iaProveedores.map(s=>s.id),t=o.indexOf(e),n=t+r;if(!(t<0||n<0||n>=o.length)){[o[t],o[n]]=[o[n],o[t]];try{await this.api("/admin/ia/proveedores/orden",{metodo:"POST",cuerpo:{ids:o}}),await this.recargaIA()}catch(s){this.avisar(s.message,"error")}}}async probarIAProv(e){this.setState({pruebaIAProv:{...this.state.pruebaIAProv,[e]:{mensaje:"Preguntando…"}}});try{const r=await this.api("/admin/ia/proveedores/"+e+"/probar",{metodo:"POST"});this.setState({pruebaIAProv:{...this.state.pruebaIAProv,[e]:r}}),await this.recargaIA()}catch(r){this.setState({pruebaIAProv:{...this.state.pruebaIAProv,[e]:{ok:!1,mensaje:r.message}}})}}async probarIA(){if(Object.keys(this.state.cambios).length){this.avisar("Guarda los ajustes antes de probar, para que la prueba use lo que acabas de escribir.","error");return}this.setState({probando:"ia",pruebaIA:null});try{const e=await this.api("/admin/probar/ia",{metodo:"POST"});this.setState({pruebaIA:e})}catch(e){this.setState({pruebaIA:{ok:!1,mensaje:e.message}})}finally{this.setState({probando:""})}}async probarTelegram(){if(Object.keys(this.state.cambios).length){this.avisar("Guarda los ajustes antes de probar, para que la prueba use lo que acabas de escribir.","error");return}this.setState({probando:"telegram",pruebaTelegram:null});try{const e=await this.api("/admin/probar/telegram",{metodo:"POST"});this.setState({pruebaTelegram:e}),e.ok&&this.cargar()}catch(e){this.setState({pruebaTelegram:{ok:!1,mensaje:e.message}})}finally{this.setState({probando:""})}}async probarApple(){if(Object.keys(this.state.cambios).length){this.avisar("Guarda los ajustes antes de probar, para que la prueba use lo que acabas de escribir.","error");return}this.setState({probando:"apple",pruebaApple:null});try{const e=await this.api("/admin/probar/apple",{metodo:"POST"});this.setState({pruebaApple:e})}catch(e){this.setState({pruebaApple:{ok:!1,mensaje:e.message}})}finally{this.setState({probando:""})}}nuevoProveedor(){this.setState({provForm:{id:null,tipo:"resend",nombre:"",activo:!0,remitenteNombre:"",remitenteEmail:"",responderA:"",apiKey:"",host:"",puerto:587,seguro:!1,usuario:"",clave:""}})}editarProveedor(e){this.setState({provForm:{...e}})}cerrarProvForm(){this.setState({provForm:null})}campoProv(e,r){this.setState({provForm:{...this.state.provForm,[e]:r}})}async guardarProveedor(){const e=this.state.provForm;this.setState({guardandoProv:!0});try{e.id?await this.api("/admin/correo/proveedores/"+e.id,{metodo:"PUT",cuerpo:e}):await this.api("/admin/correo/proveedores",{metodo:"POST",cuerpo:e});const{proveedores:r}=await this.api("/admin/correo/proveedores");this.setState({proveedores:r,provForm:null}),this.avisar("Proveedor guardado.")}catch(r){this.avisar(r.message,"error")}finally{this.setState({guardandoProv:!1})}}async alternaProveedor(e,r){try{await this.api("/admin/correo/proveedores/"+e+"/activo",{metodo:"POST",cuerpo:{activo:r}});const{proveedores:o}=await this.api("/admin/correo/proveedores");this.setState({proveedores:o})}catch(o){this.avisar(o.message,"error")}}async quitarProveedor(e,r){if(confirm("¿Quitar el proveedor "+r+"? Los envíos dejarán de usarlo."))try{await this.api("/admin/correo/proveedores/"+e,{metodo:"DELETE"});const{proveedores:o}=await this.api("/admin/correo/proveedores");this.setState({proveedores:o}),this.avisar("Proveedor quitado.")}catch(o){this.avisar(o.message,"error")}}async subeProveedor(e,r){const o=this.state.proveedores.map(s=>s.id),t=o.indexOf(e),n=t+r;if(!(t<0||n<0||n>=o.length)){[o[t],o[n]]=[o[n],o[t]];try{await this.api("/admin/correo/proveedores/orden",{metodo:"POST",cuerpo:{ids:o}});const{proveedores:s}=await this.api("/admin/correo/proveedores");this.setState({proveedores:s})}catch(s){this.avisar(s.message,"error")}}}elegirPlantilla(e,r){const o=(r||this.state.plantillas).find(t=>t.id===e);o&&this.setState({plantillaId:e,editor:{...o},previa:null})}async crearPlantilla(){const e=String(this.state.nuevaPlantilla||"").trim();if(!e)return this.avisar("Ponle nombre a la plantilla.","error");const r=e.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g,"").replace(/[^a-z0-9]+/g,"-").replace(/^-|-$/g,"").slice(0,40);try{await this.api("/admin/plantillas",{metodo:"POST",cuerpo:{id:r,nombre:e,descripcion:"Plantilla propia.",asunto:e+" · {{nombreApp}}",cuerpo:`<p>Hola {{nombre}},</p>
<p>Escribe aquí el mensaje.</p>`,variables:["nombre","email","enlace","nombreApp","soporte"]}});const o=await this.api("/admin/plantillas");this.setState({plantillas:o.plantillas,creando:!1,nuevaPlantilla:""}),this.elegirPlantilla(r,o.plantillas),this.avisar("Plantilla creada. Escríbele el asunto y el cuerpo.")}catch(o){this.avisar(o.message,"error")}}async eliminarPlantilla(){const e=this.state.editor;if(confirm(`¿Eliminar la plantilla «${e.nombre}»? No se puede deshacer.`))try{await this.api("/admin/plantillas/"+e.id,{metodo:"DELETE"});const r=await this.api("/admin/plantillas");this.setState({plantillas:r.plantillas,editor:null,plantillaId:null,previa:null}),r.plantillas.length&&this.elegirPlantilla(r.plantillas[0].id,r.plantillas),this.avisar("Plantilla eliminada.")}catch(r){this.avisar(r.message,"error")}}async guardarPlantilla(){const e=this.state.editor;try{await this.api("/admin/plantillas/"+e.id,{metodo:"PUT",cuerpo:{nombre:e.nombre,asunto:e.asunto,cuerpo:e.cuerpo,activa:e.activa}});const r=await this.api("/admin/plantillas");this.setState({plantillas:r.plantillas}),this.avisar("Plantilla guardada.")}catch(r){this.avisar(r.message,"error")}}async verPrevia(){if(this.state.previa)return this.setState({previa:null});try{const e=await this.api("/admin/plantillas/"+this.state.editor.id+"/vista");this.setState({previa:e})}catch(e){this.avisar(e.message,"error")}}async accionUsuario(e,r,o){try{const t=await this.api(`/admin/usuarios/${e}/${r}`,{metodo:"POST",cuerpo:o}),n=await this.api("/admin/usuarios");this.setState({usuarios:n.usuarios,menu:null}),r==="restablecer"?this.avisar(t.ok?"Correo de restablecimiento enviado.":"No salió el correo: "+(t.error||"revisa Ajustes → Correo."),t.ok?"ok":"error"):this.avisar("Listo."),this.api("/admin/auditoria").then(s=>this.setState({auditoria:s.auditoria})).catch(()=>{})}catch(t){this.avisar(t.message,"error"),this.setState({menu:null})}}async enviarAviso(){const{avisoTitulo:e,avisoMensaje:r,avisoDestino:o}=this.state;if(!e.trim())return this.avisar("Escribe un título.","error");this.setState({enviandoAviso:!0});try{const t=await this.api("/admin/aviso",{metodo:"POST",cuerpo:{titulo:e,mensaje:r,destino:o}});this.avisar(`Aviso enviado a ${t.enviados} de ${t.total}${t.fallidos?` · ${t.fallidos} fallaron`:""}.`,t.fallidos?"error":"ok"),this.setState({avisoTitulo:"",avisoMensaje:""});const n=await this.api("/admin/envios");this.setState({envios:n.envios})}catch(t){this.avisar(t.message,"error")}finally{this.setState({enviandoAviso:!1})}}async alternaMfa(){var r;const e=!((r=this.state.admin)!=null&&r.mfa);this.setState({guardandoMfa:!0});try{await this.api("/admin/mfa",{metodo:"POST",cuerpo:{activar:e}}),this.setState({admin:{...this.state.admin,mfa:e}}),this.avisar(e?"Verificación en dos pasos activada.":"Verificación en dos pasos desactivada.")}catch(o){this.avisar(o.message,"error")}finally{this.setState({guardandoMfa:!1})}}async crearAdmin(){const{email:e,nombre:r,clave:o}=this.state.nuevoAdmin;this.setState({creandoAdmin:!0});try{await this.api("/admin/admins",{metodo:"POST",cuerpo:{email:e,nombre:r,clave:o}});const{admins:t}=await this.api("/admin/admins");this.setState({admins:t,nuevoAdmin:{email:"",nombre:"",clave:""}}),this.avisar("Administrador agregado.")}catch(t){this.avisar(t.message,"error")}finally{this.setState({creandoAdmin:!1})}}async quitarAdmin(e,r){if(confirm(`¿Quitar a ${r} del portal? Perderá el acceso al instante.`))try{await this.api("/admin/admins/"+e,{metodo:"DELETE"});const{admins:o}=await this.api("/admin/admins");this.setState({admins:o}),this.avisar("Administrador quitado.")}catch(o){this.avisar(o.message,"error")}}async cambiarClave(){const{actual:e,nueva:r}=this.state.claveForm;this.setState({cambiandoClave:!0});try{await this.api("/admin/clave",{metodo:"POST",cuerpo:{actual:e,nueva:r}}),this.setState({claveForm:{actual:"",nueva:""}}),this.avisar("Contraseña cambiada.")}catch(o){this.avisar(o.message,"error")}finally{this.setState({cambiandoClave:!1})}}renderVals(){var w,A,C,m,z,T,I,q,E,j,F,M;const e=this.state,r=this;if(e.paso!=="consola")return{esAcceso:e.paso==="acceso",esConsola:!1,esCodigo:e.paso==="codigo",acceso:e.acceso,onAcceso:{email:a=>r.setState({acceso:{...e.acceso,email:a.target.value},error:""}),clave:a=>r.setState({acceso:{...e.acceso,clave:a.target.value},error:""})},entrar:()=>r.entrar(),botonAcceso:e.entrando?"Entrando…":"Entrar",codigo:e.codigo,pistaCorreo:e.pistaCorreo,onCodigo:a=>r.setState({codigo:a.target.value.replace(/\D/g,"").slice(0,6),error:""}),confirmarCodigo:()=>r.entrarCodigo(),botonCodigo:e.entrando?"Comprobando…":"Entrar",volverAcceso:()=>r.setState({paso:"acceso",codigo:"",reto:"",error:""}),hayError:!!e.error,error:e.error};const o=e.metricas||{},t=Math.max(1,...(o.serie||[]).map(a=>Math.max(a.altas,a.libretas))),n=Math.max(1,o.libretas||1),s=e.q.toLowerCase(),x=e.usuarios.filter(a=>!s||(a.nombre+" "+a.email).toLowerCase().includes(s)).filter(a=>e.filtro==="Todos"||(e.filtro==="Admins"?a.rol==="admin":e.filtro==="Suspendidos"?a.estado!=="activo":!a.verificado)).map((a,i)=>({nombre:a.nombre,email:a.email,inicial:S(a.nombre||a.email),rol:a.rol==="admin"?"Admin":"Usuario",plan:{gratis:"Gratis",pro:"Pro",negocio:"Negocio"}[a.plan]||"Gratis",planBg:a.plan==="gratis"?"var(--border)":"var(--good-soft)",planFg:a.plan==="gratis"?b:c,rolBg:a.rol==="admin"?"var(--good-soft)":"var(--border)",rolFg:a.rol==="admin"?c:b,libretas:a.libretas,acceso:v(a.acceso,!0),registro:v(a.creado),estado:a.estado==="activo"?a.verificado?"Activo":"Sin verificar":"Suspendido",estadoColor:a.estado!=="activo"?g:a.verificado?c:P,avatarBg:["var(--link)","oklch(0.80 0.12 250)","oklch(0.82 0.12 300)","oklch(0.84 0.14 90)"][i%4],menuOpen:e.menu===a.id,menuBg:e.menu===a.id?"var(--border)":"transparent",onMenu:l=>{l&&l.stopPropagation&&l.stopPropagation(),r.setState({menu:e.menu===a.id?null:a.id})},acciones:[...["gratis","pro","negocio"].filter(l=>l!==(a.plan||"gratis")).map(l=>({label:"Poner en plan "+{gratis:"Gratis",pro:"Pro",negocio:"Negocio"}[l],color:l==="gratis"?"var(--text)":k,go:()=>r.accionUsuario(a.id,"plan",{plan:l})})),{label:"Enviar restablecer contraseña",color:"var(--text)",go:()=>r.accionUsuario(a.id,"restablecer")},{label:a.verificado?"Ya está verificado":"Marcar como verificado",color:"var(--text)",go:()=>r.accionUsuario(a.id,"verificar")},{label:a.rol==="admin"?"Quitar rol de admin":"Hacer administrador",color:k,go:()=>r.accionUsuario(a.id,"rol",{rol:a.rol==="admin"?"usuario":"admin"})},{label:a.estado==="activo"?"Suspender cuenta":"Reactivar cuenta",color:g,go:()=>r.accionUsuario(a.id,"suspender")},{label:"Eliminar cuenta y sus libretas",color:g,go:()=>{confirm(`¿Eliminar la cuenta ${a.email} y todas sus libretas? No se puede deshacer.`)&&r.accionUsuario(a.id,"eliminar")}}]})),y=r.valor("correo.proveedor");return{esAcceso:!1,esConsola:!0,nav:V.map(a=>({label:a[1],badge:a[0]==="usuarios"?String(o.usuarios??""):a[0]==="libretas"?String(o.libretas??""):a[0]==="correo"&&o.fallidos?String(o.fallidos)+"⚠":"",bg:e.vista===a[0]?"var(--nav-active)":"transparent",fg:e.vista===a[0]?"var(--text)":"var(--text-2)",go:()=>r.setState({vista:a[0],menu:null})})),...(()=>{let a=!0;try{const i=document.documentElement.dataset.tema;a=i?i==="dark":!window.matchMedia("(prefers-color-scheme: light)").matches}catch{}return{temaEsOscuro:a,temaEsClaro:!a,temaTitulo:a?"Cambiar a claro":"Cambiar a oscuro"}})(),alternaTema:()=>r.alternaTema(),viewLabel:(B[e.vista]||["",""])[0],titulo:(B[e.vista]||["",""])[1],recargar:()=>r.cargar(),salir:()=>r.salir(),nombreAdmin:((w=e.admin)==null?void 0:w.nombre)||"Admin",inicial:S(((A=e.admin)==null?void 0:A.nombre)||"Admin"),estadoCorreo:y==="ninguno"?"Sin configurar":y==="smtp"?"SMTP":"Resend",estadoCorreoColor:y==="ninguno"?g:c,estadoCorreoNota:`${o.enviados||0} enviados · ${o.fallidos||0} con error (30 d)`,hayAviso:!!e.aviso,aviso:e.aviso,avisoBg:e.avisoTipo==="error"?"var(--bad-soft)":"var(--good-soft)",avisoFg:e.avisoTipo==="error"?"var(--bad-text)":"var(--good-text)",esMetricas:e.vista==="metricas",esUsuarios:e.vista==="usuarios",esLibretas:e.vista==="libretas",esAjustes:e.vista==="ajustes",esEntrar:e.vista==="entrar",esCobro:e.vista==="cobro",esTelegram:e.vista==="telegram",esIA:e.vista==="ia",esConfig:["ajustes","entrar","ia","whatsapp","telegram","cobro"].includes(e.vista),esPlantillas:e.vista==="plantillas",esCorreo:e.vista==="correo",esIntegraciones:e.vista==="integraciones",esAuditoria:e.vista==="auditoria",esEquipo:e.vista==="equipo",cuenta:{email:((C=e.admin)==null?void 0:C.email)||"",nombre:((m=e.admin)==null?void 0:m.nombre)||"Admin",inicial:(((z=e.admin)==null?void 0:z.nombre)||((T=e.admin)==null?void 0:T.email)||"A").trim().charAt(0).toUpperCase()},mfaActivo:!!((I=e.admin)!=null&&I.mfa),mfaEtiqueta:(q=e.admin)!=null&&q.mfa?"Activada":"Desactivada",mfaColor:(E=e.admin)!=null&&E.mfa?c:b,mfaBoton:e.guardandoMfa?"Guardando…":(j=e.admin)!=null&&j.mfa?"Desactivar":"Activar",alternaMfa:()=>r.alternaMfa(),claveForm:e.claveForm,onClaveActual:a=>r.setState({claveForm:{...e.claveForm,actual:a.target.value}}),onClaveNueva:a=>r.setState({claveForm:{...e.claveForm,nueva:a.target.value}}),cambiarClave:()=>r.cambiarClave(),botonClave:e.cambiandoClave?"Cambiando…":"Cambiar contraseña",admins:e.admins.map(a=>({id:a.id,email:a.email,nombre:a.nombre,inicial:(a.nombre||a.email).trim().charAt(0).toUpperCase(),esTu:a.esTu,etiqueta:a.esTu?"Tú":a.mfa?"Dos pasos":"",etiquetaColor:a.esTu?k:c,acceso:a.ultimo_acceso?v(a.ultimo_acceso,!0):"sin entrar aún",puedeQuitar:!a.esTu,quitar:()=>r.quitarAdmin(a.id,a.email)})),nuevoAdmin:e.nuevoAdmin,onNuevoEmail:a=>r.setState({nuevoAdmin:{...e.nuevoAdmin,email:a.target.value}}),onNuevoNombre:a=>r.setState({nuevoAdmin:{...e.nuevoAdmin,nombre:a.target.value}}),onNuevoClave:a=>r.setState({nuevoAdmin:{...e.nuevoAdmin,clave:a.target.value}}),crearAdmin:()=>r.crearAdmin(),botonCrearAdmin:e.creandoAdmin?"Agregando…":"Agregar administrador",apiClaves:e.apiClaves.map(a=>({nombre:a.nombre,email:a.email,prefijo:a.prefijo,creada:v(a.creada),uso:a.ultimo_uso?v(a.ultimo_uso,!0):"sin usar",estado:a.revocada?"Revocada":"Activa",color:a.revocada?g:c})),apiRegistro:e.apiRegistro.map(a=>({cuando:v(a.creado,!0),usuario:a.usuario||"—",ruta:a.ruta,estado:String(a.estado),detalle:a.detalle||"",color:a.estado<300?c:a.estado<500?P:g})),kpis:[{label:"Usuarios",valor:String(o.usuarios??"—"),nota:`${o.nuevos||0} nuevos en 30 días`,color:c},{label:"Activos (30 d)",valor:String(o.activos??"—"),nota:o.usuarios?Math.round((o.activos||0)/o.usuarios*100)+"% del total":"—",color:b},{label:"Libretas",valor:String(o.libretas??"—"),nota:`${o.compartidas||0} compartidas`,color:b},{label:"Movimientos",valor:(o.movimientos||0).toLocaleString("es-DO"),nota:"en todas las libretas",color:b},{label:"Invitaciones",valor:String(o.pendientes??0),nota:"pendientes de aceptar",color:o.pendientes?P:b},{label:"Correos (30 d)",valor:String(o.enviados??0),nota:`${o.fallidos||0} con error`,color:o.fallidos?g:c}],serie:(o.serie||[]).map(a=>({label:a.mes.slice(5),a:Math.round(a.altas/t*100),b:Math.round(a.libretas/t*100)})),tipos:(o.tipos||[]).map(a=>({tipo:a.tipo,n:a.n,pct:Math.round(a.n/n*100)})),q:e.q,onQ:a=>r.setState({q:a.target.value}),filtros:["Todos","Admins","Sin verificar","Suspendidos"].map(a=>({label:a,go:()=>r.setState({filtro:a}),bg:e.filtro===a?k:"var(--surface)",fg:e.filtro===a?"var(--accent-ink)":"var(--text)",border:e.filtro===a?k:"var(--border)"})),usuarios:x,conteoUsuarios:`${x.length} de ${e.usuarios.length} usuarios`,resumenUsuarios:`${o.usuarios||0} en total · ${o.activos||0} activos en 30 días`,libretas:e.libretas.map(a=>({nombre:a.nombre,tipo:a.tipo,dueno:a.dueno,color:a.color||"var(--avatar)",inicial:S(a.nombre),miembros:a.miembros+(a.miembros===1?" persona":" personas"),movs:(a.movs||0).toLocaleString("es-DO"),actualizado:v(a.actualizado,!0)})),grupos:Q.filter(a=>a.seccion===e.vista).map(a=>({titulo:a.titulo,desc:a.desc,campos:a.campos.map(i=>{const l=r.valor(i.clave),p=i.tipo||"texto";return{etiqueta:i.etiqueta,ayuda:i.ayuda||"",hayAyuda:!!i.ayuda,ancho:1,esTexto:p==="texto"||p==="numero"||p==="clave",tipoInput:p==="numero"?"number":p==="clave"?"password":"text",pista:p==="clave"?"Sin cambios":"",esSelect:p==="select",opciones:(i.opciones||[]).map(f=>({id:f[0],label:f[1]})),esSwitch:p==="switch",trackBg:l?c:"var(--border)",knob:l?29:3,valor:p==="switch"?"":l??"",hayError:!!e.erroresCampo[i.clave],error:e.erroresCampo[i.clave]||"",bordeError:e.erroresCampo[i.clave]?"var(--bad-border)":"var(--border)",onChange:f=>r.cambiar(i.clave,p==="numero"?Number(f.target.value):f.target.value),onToggle:()=>r.cambiar(i.clave,!l)}})})),pruebaDestino:e.pruebaDestino,onPruebaDestino:a=>r.setState({pruebaDestino:a.target.value}),probarCorreo:()=>r.probarCorreo("bienvenida"),estados:(()=>{const a=p=>r.valor(p),i=(p,f,N)=>({ok:p,texto:p?f:N,color:p?"var(--good)":"var(--text-3)"}),l=a("correo.proveedor")==="resend"?!!a("correo.resendApiKey")||(e.config["correo.resendApiKey"]||"").length>0:a("correo.proveedor")==="smtp"?!!a("correo.smtpHost"):!1;return{correo:i(a("correo.proveedor")!=="ninguno"&&l!==!1,"Configurado","Sin configurar"),appleCobro:i(!!(a("apple.issuerId")&&a("apple.keyId")&&(a("apple.clave")||(e.config["apple.clave"]||"").length)),"Listo para cobrar","Falta la clave"),appleEntrar:i(!!a("apple.servicioWeb"),"Web activa","Solo en la app"),google:i(!!a("google.clienteWeb"),"Activo","Apagado")}})(),iaProveedores:(e.iaProveedores||[]).map((a,i)=>{const l=(e.pruebaIAProv||{})[a.id];return{id:a.id,nombre:a.nombre,tipo:a.tipo==="anthropic"?"ANTHROPIC":"OPENAI-COMPAT",activo:a.activo,detalle:(a.modelo||"—")+" · "+(a.base||"api.anthropic.com").replace(/^https?:\/\//,""),estadoTexto:a.activo?"Activo":"Apagado",estadoColor:a.activo?"var(--good)":"var(--text-3)",fallosTexto:a.fallos>0?a.fallos+" fallo(s) seguidos: "+String(a.ultimoFallo||"").split(" · ").slice(1).join(" "):a.ultimoOk?"último ok "+v(a.ultimoOk,!0):"sin usar",fallosColor:a.fallos>0?"var(--bad)":"var(--text-3)",hayPrueba:!!l,pruebaMsg:l?l.mensaje:"",pruebaColor:l&&l.ok?"var(--good)":"var(--bad)",esPrimero:i===0,esUltimo:i===(e.iaProveedores||[]).length-1,toggle:()=>r.alternaIA(a.id,!a.activo),editar:()=>r.editarIA(a),probar:()=>r.probarIAProv(a.id),subir:()=>r.subeIA(a.id,-1),bajar:()=>r.subeIA(a.id,1),quitar:()=>r.quitarIA(a.id,a.nombre)}}),hayIAProveedores:(e.iaProveedores||[]).length>0,resumenIA:(e.iaProveedores||[]).length?(e.iaProveedores||[]).filter(a=>a.activo).length+" activo(s) de "+e.iaProveedores.length+" · se prueban en orden hasta que uno contesta":"Sin proveedores: la IA no se ofrece a nadie todavía.",iaPresets:Object.keys(e.iaPresets||{}).map(a=>({id:a,label:e.iaPresets[a].nombre,elegir:()=>e.iaForm?r.presetIA(a):r.nuevoIA(a)})),nuevoIA:()=>r.nuevoIA("deepseek"),iaAbierto:!!e.iaForm,iaForm:e.iaForm||{},iaTitulo:e.iaForm&&e.iaForm.id?"Editar proveedor":"Nuevo proveedor",iaEsAnthropic:!!e.iaForm&&e.iaForm.tipo==="anthropic",onIANombre:a=>r.campoIA("nombre",a.target.value),onIABase:a=>r.campoIA("base",a.target.value),onIAModelo:a=>r.campoIA("modelo",a.target.value),onIAClave:a=>r.campoIA("clave",a.target.value),onIAPreset:a=>r.presetIA(a.target.value),guardarIA:()=>r.guardarIA(),botonIA2:e.guardandoIA?"Guardando…":"Guardar proveedor",cerrarIAForm:()=>r.setState({iaForm:null}),iaEjemploTexto:e.iaEjemplo?JSON.stringify(e.iaEjemplo,null,2):"Cargando…",probarIA:()=>r.probarIA(),botonIA:e.probando==="ia"?"Preguntando…":"Probar la clave con una pregunta",hayPruebaIA:!!e.pruebaIA,pruebaIAMsg:e.pruebaIA?e.pruebaIA.mensaje:"",pruebaIABg:e.pruebaIA&&e.pruebaIA.ok?"oklch(0.95 0.05 155)":"oklch(0.96 0.04 30)",pruebaIAColor:e.pruebaIA&&e.pruebaIA.ok?"oklch(0.40 0.12 155)":"oklch(0.48 0.15 30)",probarTelegram:()=>r.probarTelegram(),botonTelegram:e.probando==="telegram"?"Probando con Telegram…":"Probar el bot y poner el webhook",hayPruebaTelegram:!!e.pruebaTelegram,pruebaTelegramMsg:e.pruebaTelegram?e.pruebaTelegram.mensaje:"",pruebaTelegramBg:e.pruebaTelegram&&e.pruebaTelegram.ok?"oklch(0.95 0.05 155)":"oklch(0.96 0.04 30)",pruebaTelegramColor:e.pruebaTelegram&&e.pruebaTelegram.ok?"oklch(0.40 0.12 155)":"oklch(0.48 0.15 30)",probarApple:()=>r.probarApple(),probandoApple:e.probando==="apple",botonApple:e.probando==="apple"?"Probando con Apple…":"Probar la clave con Apple",hayPruebaApple:!!e.pruebaApple,pruebaAppleOk:!!(e.pruebaApple&&e.pruebaApple.ok),pruebaAppleMsg:e.pruebaApple?e.pruebaApple.mensaje:"",pruebaAppleColor:e.pruebaApple?e.pruebaApple.ok?"var(--good)":"var(--bad)":"var(--text-3)",pruebaAppleBg:e.pruebaApple?e.pruebaApple.ok?"var(--good-soft)":"var(--bad-soft)":"transparent",guardarAjustes:()=>r.guardarAjustes(),botonGuardar:e.guardando?"Guardando…":Object.keys(e.cambios).length?`Guardar ${Object.keys(e.cambios).length} cambio(s)`:"Guardar",plantillas:e.plantillas.map(a=>({nombre:a.nombre,descripcion:a.descripcion||"",bg:a.id===e.plantillaId?"var(--border-soft)":"transparent",punto:a.activa?c:"var(--border-strong)",go:()=>r.elegirPlantilla(a.id)})),creando:e.creando,nuevaPlantilla:e.nuevaPlantilla,onNuevaPlantilla:a=>r.setState({nuevaPlantilla:a.target.value}),abrirNuevaPlantilla:()=>r.setState({creando:!e.creando,nuevaPlantilla:""}),crearPlantilla:()=>r.crearPlantilla(),cancelarPlantilla:()=>r.setState({creando:!1,nuevaPlantilla:""}),eliminarPlantilla:()=>r.eliminarPlantilla(),hayPlantilla:!!e.editor,editor:e.editor?{id:e.editor.id,nombre:e.editor.nombre,borrable:!["bienvenida","verificar","restablecer","clave-cambiada","invitacion","aviso"].includes(e.editor.id),asunto:e.editor.asunto,cuerpo:e.editor.cuerpo,estadoTexto:e.editor.activa?"Activa":"Desactivada",trackBg:e.editor.activa?c:"var(--border)",knob:e.editor.activa?29:3,variables:(e.editor.variables||[]).map(a=>({label:"{{"+a+"}}",go:()=>{var i;(i=navigator.clipboard)==null||i.writeText("{{"+a+"}}"),r.avisar("Copiado: {{"+a+"}}")}}))}:{},onAsunto:a=>r.setState({editor:{...e.editor,asunto:a.target.value}}),onCuerpo:a=>r.setState({editor:{...e.editor,cuerpo:a.target.value}}),toggleActiva:()=>r.setState({editor:{...e.editor,activa:!e.editor.activa}}),guardarPlantilla:()=>r.guardarPlantilla(),verPrevia:()=>r.verPrevia(),botonPrevia:e.previa?"Ocultar vista previa":"Ver cómo queda",probarPlantilla:()=>{var a;return r.probarCorreo((a=e.editor)==null?void 0:a.id)},hayPrevia:!!e.previa,previaAsunto:((F=e.previa)==null?void 0:F.asunto)||"",previaHtml:((M=e.previa)==null?void 0:M.html)||"",destinos:[["todos","Todos los usuarios activos"],["inactivos","Sin entrar en 30 días"],["admins","Solo administradores"]].map(a=>({id:a[0],label:a[1]})),proveedores:e.proveedores.map((a,i)=>({id:a.id,nombre:a.nombre,tipo:a.tipo.toUpperCase(),activo:a.activo,remitente:a.remitenteEmail||"(remitente general)",estadoTexto:a.activo?"Activo":"Apagado",estadoColor:a.activo?"var(--good)":"var(--text-3)",fallosTexto:a.fallos>0?a.fallos+" fallo(s) seguidos":a.ultimoOk?"último ok":"sin usar",fallosColor:a.fallos>0?"var(--bad)":"var(--text-3)",esPrimero:i===0,esUltimo:i===e.proveedores.length-1,toggle:()=>r.alternaProveedor(a.id,!a.activo),editar:()=>r.editarProveedor(a),subir:()=>r.subeProveedor(a.id,-1),bajar:()=>r.subeProveedor(a.id,1),quitar:()=>r.quitarProveedor(a.id,a.nombre)})),hayProveedores:e.proveedores.length>0,resumenPool:e.proveedores.length?e.proveedores.filter(a=>a.activo).length+" activo(s) de "+e.proveedores.length+" · se prueban en orden hasta que uno entrega":"Sin proveedores: la app no puede enviar correo todavía.",nuevoProveedor:()=>r.nuevoProveedor(),provAbierto:!!e.provForm,provForm:e.provForm||{},provEsResend:!!e.provForm&&e.provForm.tipo==="resend",provEsSmtp:!!e.provForm&&e.provForm.tipo==="smtp",provTitulo:e.provForm&&e.provForm.id?"Editar proveedor":"Nuevo proveedor",provTipoResend:()=>r.campoProv("tipo","resend"),provTipoSmtp:()=>r.campoProv("tipo","smtp"),provTipoBgR:e.provForm&&e.provForm.tipo==="resend"?"var(--accent)":"var(--surface-2)",provTipoFgR:e.provForm&&e.provForm.tipo==="resend"?"var(--accent-ink)":"var(--text-2)",provTipoBgS:e.provForm&&e.provForm.tipo==="smtp"?"var(--accent)":"var(--surface-2)",provTipoFgS:e.provForm&&e.provForm.tipo==="smtp"?"var(--accent-ink)":"var(--text-2)",onProvNombre:a=>r.campoProv("nombre",a.target.value),onProvRemNombre:a=>r.campoProv("remitenteNombre",a.target.value),onProvRemEmail:a=>r.campoProv("remitenteEmail",a.target.value),onProvResponder:a=>r.campoProv("responderA",a.target.value),onProvApiKey:a=>r.campoProv("apiKey",a.target.value),onProvHost:a=>r.campoProv("host",a.target.value),onProvPuerto:a=>r.campoProv("puerto",Number(a.target.value)),onProvUsuario:a=>r.campoProv("usuario",a.target.value),onProvClave:a=>r.campoProv("clave",a.target.value),provSeguro:!!(e.provForm&&e.provForm.seguro),provSeguroTrack:e.provForm&&e.provForm.seguro?"var(--good)":"var(--border)",provSeguroKnob:e.provForm&&e.provForm.seguro?29:3,onProvSeguro:()=>r.campoProv("seguro",!(e.provForm&&e.provForm.seguro)),guardarProveedor:()=>r.guardarProveedor(),botonProv:e.guardandoProv?"Guardando…":"Guardar proveedor",cerrarProvForm:()=>r.cerrarProvForm(),avisoDestino:e.avisoDestino,onAvisoDestino:a=>r.setState({avisoDestino:a.target.value}),avisoTitulo:e.avisoTitulo,onAvisoTitulo:a=>r.setState({avisoTitulo:a.target.value}),avisoMensaje:e.avisoMensaje,onAvisoMensaje:a=>r.setState({avisoMensaje:a.target.value}),enviarAviso:()=>r.enviarAviso(),botonAviso:e.enviandoAviso?"Enviando…":"Enviar aviso",envios:e.envios.map(a=>({cuando:v(a.creado,!0),destino:a.destino,plantilla:a.plantilla||"—",detalle:a.detalle||"",estado:a.estado,color:a.estado==="enviado"?c:a.estado==="omitido"?P:g})),auditoria:e.auditoria.map(a=>({cuando:v(a.creado,!0),actor:a.actor,accion:a.accion,origen:a.origen}))}}}const K=`<!-- Consola interna de Chinola. Sigue el lenguaje visual de
     \`diseno/Chinola Admin.dc.html\`, pero contra datos reales y con la sección
     de ajustes que el diseño no cubría. -->

<sc-if value="{{ esAcceso }}" hint-placeholder-val="{{ true }}">
  <div style="min-height:100vh;display:flex;align-items:center;justify-content:center;padding:40px">
    <div style="width:100%;max-width:400px;background:var(--surface);border:1px solid var(--border);border-radius:24px;padding:30px;display:flex;flex-direction:column;gap:14px;animation:entra 0.4s ease both">
      <div style="display:flex;align-items:center;gap:10px">
        <div style="width:32px;height:32px;border-radius:50%;background:var(--accent);display:flex;align-items:center;justify-content:center"><div style="width:12px;height:12px;border-radius:50%;background:var(--sidebar)"></div></div>
        <div>
          <div style="font-family:'Bricolage Grotesque',sans-serif;font-weight:800;font-size:18px;letter-spacing:-0.03em;line-height:1">Chinola</div>
          <div style="font-size:10px;letter-spacing:0.14em;text-transform:uppercase;color:var(--accent-dim)">Consola interna</div>
        </div>
      </div>
      <p style="margin:0;font-size:13px;line-height:1.55;color:var(--text-2)">Entra con tu cuenta de administrador del portal.</p>
      <input value="{{ acceso.email }}" onChange="{{ onAcceso.email }}" type="email" placeholder="correo@dominio.com" style="padding:13px;border-radius:12px;border:1px solid var(--border);background:var(--surface-2);color:inherit" />
      <input value="{{ acceso.clave }}" onChange="{{ onAcceso.clave }}" type="password" placeholder="Contraseña" style="padding:13px;border-radius:12px;border:1px solid var(--border);background:var(--surface-2);color:inherit" />
      <sc-if value="{{ hayError }}" hint-placeholder-val="{{ false }}">
        <div style="padding:12px 14px;border-radius:12px;background:var(--bad-soft);color:var(--bad-text);font-size:13px;line-height:1.5">{{ error }}</div>
      </sc-if>
      <button onClick="{{ entrar }}" style="padding:15px;border-radius:13px;border:none;background:var(--accent);color:var(--accent-ink);cursor:pointer;font-size:15px;font-weight:700">{{ botonAcceso }}</button>
      <a href="/app/" style="text-align:center;font-size:12px">← Volver a la app</a>
    </div>
  </div>
</sc-if>

<sc-if value="{{ esCodigo }}" hint-placeholder-val="{{ false }}">
  <div style="min-height:100vh;display:flex;align-items:center;justify-content:center;padding:40px">
    <div style="width:100%;max-width:400px;background:var(--surface);border:1px solid var(--border);border-radius:24px;padding:30px;display:flex;flex-direction:column;gap:14px;animation:entra 0.4s ease both">
      <div style="display:flex;align-items:center;gap:10px">
        <div style="width:32px;height:32px;border-radius:50%;background:var(--accent);display:flex;align-items:center;justify-content:center"><div style="width:12px;height:12px;border-radius:50%;background:var(--sidebar)"></div></div>
        <div>
          <div style="font-family:'Bricolage Grotesque',sans-serif;font-weight:800;font-size:18px;letter-spacing:-0.03em;line-height:1">Verificación</div>
          <div style="font-size:10px;letter-spacing:0.14em;text-transform:uppercase;color:var(--accent-dim)">Dos pasos</div>
        </div>
      </div>
      <p style="margin:0;font-size:13px;line-height:1.55;color:var(--text-2)">Te enviamos un código de seis cifras a {{ pistaCorreo }}. Escríbelo para entrar.</p>
      <input value="{{ codigo }}" onChange="{{ onCodigo }}" inputmode="numeric" autocomplete="one-time-code" placeholder="000000" style="padding:14px;border-radius:12px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:22px;letter-spacing:0.4em;text-align:center;font-family:'Bricolage Grotesque',monospace" />
      <sc-if value="{{ hayError }}" hint-placeholder-val="{{ false }}">
        <div style="padding:12px 14px;border-radius:12px;background:var(--bad-soft);color:var(--bad-text);font-size:13px;line-height:1.5">{{ error }}</div>
      </sc-if>
      <button onClick="{{ confirmarCodigo }}" style="padding:15px;border-radius:13px;border:none;background:var(--accent);color:var(--accent-ink);cursor:pointer;font-size:15px;font-weight:700">{{ botonCodigo }}</button>
      <button onClick="{{ volverAcceso }}" style="text-align:center;font-size:12px;background:none;border:none;color:var(--accent-dim);cursor:pointer">← Volver</button>
    </div>
  </div>
</sc-if>

<sc-if value="{{ esConsola }}" hint-placeholder-val="{{ false }}">
<div style="display:grid;grid-template-columns:236px minmax(0,1fr);min-height:100vh">
  <aside style="background:var(--sidebar);padding:22px 14px;display:flex;flex-direction:column;gap:20px;position:sticky;top:0;height:100vh;overflow-y:auto">
    <div style="display:flex;align-items:center;gap:10px;padding:0 4px">
      <div style="width:30px;height:30px;border-radius:50%;background:var(--accent);display:flex;align-items:center;justify-content:center"><div style="width:11px;height:11px;border-radius:50%;background:var(--sidebar)"></div></div>
      <div>
        <div style="font-family:'Bricolage Grotesque',sans-serif;font-weight:800;font-size:18px;letter-spacing:-0.03em;line-height:1">Chinola</div>
        <div style="font-size:10px;letter-spacing:0.14em;text-transform:uppercase;color:var(--accent-dim)">Consola interna</div>
      </div>
    </div>
    <nav style="display:flex;flex-direction:column;gap:3px">
      <sc-for list="{{ nav }}" as="i" hint-placeholder-count="7">
        <button onClick="{{ i.go }}" style="display:flex;align-items:center;justify-content:space-between;gap:10px;text-align:left;padding:11px 12px;border-radius:11px;border:none;cursor:pointer;font-size:14px;font-weight:600;background:{{ i.bg }};color:{{ i.fg }}">
          <span>{{ i.label }}</span><span style="font-size:11px;color:var(--text-2)">{{ i.badge }}</span>
        </button>
      </sc-for>
    </nav>
    <div style="margin-top:auto;display:flex;flex-direction:column;gap:10px">
      <div style="padding:13px;border-radius:14px;background:var(--hover)">
        <div style="font-size:10px;text-transform:uppercase;letter-spacing:0.1em;color:var(--text-3)">Correo</div>
        <div style="display:flex;align-items:center;gap:8px;margin-top:7px">
          <span style="width:9px;height:9px;border-radius:50%;background:{{ estadoCorreoColor }}"></span>
          <span style="font-size:13px;font-weight:700">{{ estadoCorreo }}</span>
        </div>
        <div style="font-size:11px;color:var(--text-3);margin-top:4px">{{ estadoCorreoNota }}</div>
      </div>
      <button onClick="{{ salir }}" style="display:flex;align-items:center;gap:10px;padding:9px;border-radius:13px;background:var(--hover-soft);border:none;cursor:pointer;color:inherit;text-align:left">
        <span style="width:32px;height:32px;border-radius:50%;background:var(--accent);color:var(--accent-ink);display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:800">{{ inicial }}</span>
        <span style="flex:1;min-width:0">
          <span style="display:block;font-size:13px;font-weight:700;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ nombreAdmin }}</span>
          <span style="display:block;font-size:11px;color:var(--text-3)">Cerrar sesión</span>
        </span>
      </button>
    </div>
  </aside>

  <main style="padding:24px 28px 60px;max-width:1320px;width:100%;min-width:0">
    <header style="display:flex;align-items:flex-end;justify-content:space-between;gap:18px;flex-wrap:wrap;margin-bottom:20px">
      <div>
        <div style="font-size:11px;text-transform:uppercase;letter-spacing:0.11em;color:var(--text-3);font-weight:700">{{ viewLabel }}</div>
        <h1 style="margin:6px 0 0;font-family:'Bricolage Grotesque',sans-serif;font-size:30px;font-weight:800;letter-spacing:-0.032em">{{ titulo }}</h1>
      </div>
      <div style="display:flex;align-items:center;gap:10px">
        <button onClick="{{ alternaTema }}" aria-label="Cambiar tema" title="{{ temaTitulo }}" style="width:42px;height:42px;flex:none;border-radius:12px;border:1px solid var(--border);background:var(--surface);color:var(--text-2);cursor:pointer;display:flex;align-items:center;justify-content:center">
          <sc-if value="{{ temaEsOscuro }}" hint-placeholder-val="{{ true }}">
            <svg viewBox="0 0 24 24" style="width:19px;height:19px" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="4"></circle><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"></path></svg>
          </sc-if>
          <sc-if value="{{ temaEsClaro }}" hint-placeholder-val="{{ false }}">
            <svg viewBox="0 0 24 24" style="width:19px;height:19px" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"></path></svg>
          </sc-if>
        </button>
        <button onClick="{{ recargar }}" style="padding:11px 16px;border-radius:12px;border:1px solid var(--border);background:var(--surface);color:var(--text);cursor:pointer;font-size:13px;font-weight:600">Actualizar</button>
      </div>
    </header>

    <sc-if value="{{ hayAviso }}" hint-placeholder-val="{{ false }}">
      <div style="padding:13px 17px;border-radius:14px;background:{{ avisoBg }};color:{{ avisoFg }};font-size:13px;font-weight:600;margin-bottom:16px;line-height:1.5;animation:aparece 0.2s ease both">{{ aviso }}</div>
    </sc-if>

    <!-- MÉTRICAS -->
    <sc-if value="{{ esMetricas }}" hint-placeholder-val="{{ true }}">
      <div style="display:flex;flex-direction:column;gap:16px">
        <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:14px">
          <sc-for list="{{ kpis }}" as="k" hint-placeholder-count="6">
            <div style="background:var(--surface);border:1px solid var(--border);border-radius:18px;padding:18px;animation:entra 0.4s ease both">
              <div style="font-size:11px;text-transform:uppercase;letter-spacing:0.08em;color:var(--text-3);font-weight:700">{{ k.label }}</div>
              <div style="font-family:'Bricolage Grotesque',sans-serif;font-size:26px;font-weight:800;margin-top:9px;letter-spacing:-0.03em">{{ k.valor }}</div>
              <div style="font-size:12px;margin-top:4px;color:{{ k.color }}">{{ k.nota }}</div>
            </div>
          </sc-for>
        </div>
        <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(330px,1fr));gap:16px;align-items:start">
          <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;padding:20px">
            <div style="display:flex;justify-content:space-between;align-items:baseline;margin-bottom:14px">
              <h2 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">Altas y actividad</h2>
              <span style="font-size:12px;color:var(--text-3)">12 meses</span>
            </div>
            <div style="display:flex;align-items:flex-end;gap:8px;height:170px">
              <sc-for list="{{ serie }}" as="m" hint-placeholder-count="12">
                <div style="flex:1;display:flex;flex-direction:column;align-items:center;gap:6px;height:100%">
                  <div style="flex:1;display:flex;align-items:flex-end;gap:2px;width:100%">
                    <div style="flex:1;border-radius:4px 4px 0 0;background:var(--good);height:{{ m.a }}%"></div>
                    <div style="flex:1;border-radius:4px 4px 0 0;background:var(--info);height:{{ m.b }}%"></div>
                  </div>
                  <span style="font-size:10px;color:var(--text-3)">{{ m.label }}</span>
                </div>
              </sc-for>
            </div>
            <div style="display:flex;gap:14px;margin-top:12px;font-size:12px;color:var(--text-3)">
              <span style="display:flex;align-items:center;gap:6px"><span style="width:9px;height:9px;border-radius:3px;background:var(--good)"></span>Usuarios nuevos</span>
              <span style="display:flex;align-items:center;gap:6px"><span style="width:9px;height:9px;border-radius:3px;background:var(--info)"></span>Libretas con actividad</span>
            </div>
          </div>
          <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;padding:20px">
            <h2 style="margin:0 0 14px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">Libretas por tipo</h2>
            <div style="display:flex;flex-direction:column;gap:12px">
              <sc-for list="{{ tipos }}" as="t" hint-placeholder-count="4">
                <div style="display:flex;flex-direction:column;gap:5px">
                  <div style="display:flex;justify-content:space-between;font-size:13px"><span>{{ t.tipo }}</span><span style="color:var(--text-3)">{{ t.n }}</span></div>
                  <div style="height:8px;border-radius:5px;background:var(--border-soft);overflow:hidden"><div style="height:100%;border-radius:5px;width:{{ t.pct }}%;background:var(--good)"></div></div>
                </div>
              </sc-for>
            </div>
          </div>
        </div>
      </div>
    </sc-if>

    <!-- USUARIOS -->
    <sc-if value="{{ esUsuarios }}" hint-placeholder-val="{{ false }}">
      <div style="display:flex;flex-direction:column;gap:14px">
        <div style="display:flex;gap:10px;flex-wrap:wrap;align-items:center">
          <input value="{{ q }}" onChange="{{ onQ }}" placeholder="Buscar por nombre o correo…" style="flex:1;min-width:230px;padding:13px 16px;border-radius:13px;border:1px solid var(--border);background:var(--surface);color:inherit" />
          <sc-for list="{{ filtros }}" as="f" hint-placeholder-count="4">
            <button onClick="{{ f.go }}" style="padding:11px 15px;border-radius:12px;border:1px solid {{ f.border }};background:{{ f.bg }};color:{{ f.fg }};cursor:pointer;font-size:13px;font-weight:600">{{ f.label }}</button>
          </sc-for>
        </div>
        <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;overflow-x:auto">
          <div style="display:grid;grid-template-columns:2fr 0.7fr 0.8fr 1fr 1fr 0.9fr 46px;gap:12px;min-width:900px;padding:14px 20px;background:var(--surface-2);font-size:11px;text-transform:uppercase;letter-spacing:0.07em;color:var(--text-3);font-weight:700">
            <span>Usuario</span><span>Rol</span><span>Libretas</span><span>Último acceso</span><span>Registro</span><span>Estado</span><span></span>
          </div>
          <sc-for list="{{ usuarios }}" as="u" hint-placeholder-count="8">
            <div style="display:grid;grid-template-columns:2fr 0.7fr 0.8fr 1fr 1fr 0.9fr 46px;gap:12px;min-width:900px;padding:12px 20px;border-top:1px solid var(--border-soft);align-items:center;font-size:13px">
              <span style="display:flex;align-items:center;gap:11px;min-width:0">
                <span style="width:32px;height:32px;border-radius:50%;background:{{ u.avatarBg }};display:flex;align-items:center;justify-content:center;font-size:11px;font-weight:800;color:var(--surface-sunken);flex:0 0 auto">{{ u.inicial }}</span>
                <span style="min-width:0">
                  <span style="display:block;font-weight:700;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ u.nombre }}</span>
                  <span style="display:block;font-size:11px;color:var(--text-3)">{{ u.email }}</span>
                </span>
              </span>
              <span style="display:flex;gap:5px;flex-wrap:wrap">
                <span style="padding:4px 10px;border-radius:20px;font-size:11px;font-weight:700;background:{{ u.rolBg }};color:{{ u.rolFg }}">{{ u.rol }}</span>
                <span style="padding:4px 10px;border-radius:20px;font-size:11px;font-weight:700;background:{{ u.planBg }};color:{{ u.planFg }}">{{ u.plan }}</span>
              </span>
              <span style="color:var(--text-2)">{{ u.libretas }}</span>
              <span style="color:var(--text-3)">{{ u.acceso }}</span>
              <span style="color:var(--text-3)">{{ u.registro }}</span>
              <span style="font-weight:700;color:{{ u.estadoColor }}">{{ u.estado }}</span>
              <span style="position:relative;display:flex;justify-content:flex-end">
                <button onClick="{{ u.onMenu }}" style="width:30px;height:30px;border-radius:10px;border:none;background:{{ u.menuBg }};cursor:pointer;color:var(--text-2);font-size:15px">⋯</button>
                <sc-if value="{{ u.menuOpen }}" hint-placeholder-val="{{ false }}">
                  <div style="position:absolute;top:34px;right:0;z-index:30;background:var(--surface-2);border:1px solid var(--border-strong);border-radius:13px;box-shadow:0 16px 32px var(--overlay);overflow:hidden;min-width:240px;display:flex;flex-direction:column;animation:aparece 0.15s ease both">
                    <sc-for list="{{ u.acciones }}" as="a" hint-placeholder-count="5">
                      <button onClick="{{ a.go }}" style="padding:11px 14px;border:none;border-bottom:1px solid var(--border);background:transparent;text-align:left;cursor:pointer;font-size:13px;font-weight:600;color:{{ a.color }}">{{ a.label }}</button>
                    </sc-for>
                  </div>
                </sc-if>
              </span>
            </div>
          </sc-for>
          <div style="display:flex;justify-content:space-between;gap:16px;padding:14px 20px;border-top:1px solid var(--border);background:var(--surface-2);font-size:13px;font-weight:700">
            <span>{{ conteoUsuarios }}</span><span style="color:var(--text-2)">{{ resumenUsuarios }}</span>
          </div>
        </div>
      </div>
    </sc-if>

    <!-- LIBRETAS -->
    <sc-if value="{{ esLibretas }}" hint-placeholder-val="{{ false }}">
      <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;overflow-x:auto">
        <div style="display:grid;grid-template-columns:1.6fr 1fr 1.4fr 1fr 1fr 1fr;gap:12px;min-width:860px;padding:14px 20px;background:var(--surface-2);font-size:11px;text-transform:uppercase;letter-spacing:0.07em;color:var(--text-3);font-weight:700">
          <span>Libreta</span><span>Tipo</span><span>Dueño</span><span>Miembros</span><span>Movimientos</span><span>Actualizada</span>
        </div>
        <sc-for list="{{ libretas }}" as="l" hint-placeholder-count="6">
          <div style="display:grid;grid-template-columns:1.6fr 1fr 1.4fr 1fr 1fr 1fr;gap:12px;min-width:860px;padding:13px 20px;border-top:1px solid var(--border-soft);align-items:center;font-size:13px">
            <span style="display:flex;align-items:center;gap:11px;min-width:0">
              <span style="width:28px;height:28px;border-radius:9px;background:{{ l.color }};display:flex;align-items:center;justify-content:center;font-size:10px;font-weight:800;color:#fff;flex:0 0 auto">{{ l.inicial }}</span>
              <span style="font-weight:700;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ l.nombre }}</span>
            </span>
            <span style="color:var(--text-2)">{{ l.tipo }}</span>
            <span style="color:var(--text-2);white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ l.dueno }}</span>
            <span style="color:var(--text-2)">{{ l.miembros }}</span>
            <span style="color:var(--text-2)">{{ l.movs }}</span>
            <span style="color:var(--text-3)">{{ l.actualizado }}</span>
          </div>
        </sc-for>
      </div>
    </sc-if>

    <!-- AJUSTES (general, correo, notificaciones) -->
    <sc-if value="{{ esConfig }}" hint-placeholder-val="{{ false }}">
      <div style="display:flex;flex-direction:column;gap:16px">
        <sc-for list="{{ grupos }}" as="g" hint-placeholder-count="3">
          <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;padding:22px">
            <h2 style="margin:0 0 4px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">{{ g.titulo }}</h2>
            <p style="margin:0 0 18px;font-size:13px;line-height:1.55;color:var(--text-3)">{{ g.desc }}</p>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:14px">
              <sc-for list="{{ g.campos }}" as="c" hint-placeholder-count="6">
                <div style="display:flex;flex-direction:column;gap:6px;min-width:0;grid-column:span {{ c.ancho }}">
                  <span style="font-size:12px;font-weight:700;color:var(--text-2)">{{ c.etiqueta }}</span>
                  <sc-if value="{{ c.esTexto }}" hint-placeholder-val="{{ true }}">
                    <input value="{{ c.valor }}" onChange="{{ c.onChange }}" type="{{ c.tipoInput }}" placeholder="{{ c.pista }}" style="width:100%;padding:12px;border-radius:11px;border:1px solid {{ c.bordeError }};background:var(--surface-2);color:inherit" />
                  </sc-if>
                  <sc-if value="{{ c.esSelect }}" hint-placeholder-val="{{ false }}">
                    <select value="{{ c.valor }}" onChange="{{ c.onChange }}" style="width:100%;padding:12px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit">
                      <sc-for list="{{ c.opciones }}" as="o" hint-placeholder-count="3"><option value="{{ o.id }}">{{ o.label }}</option></sc-for>
                    </select>
                  </sc-if>
                  <sc-if value="{{ c.esSwitch }}" hint-placeholder-val="{{ false }}">
                    <button onClick="{{ c.onToggle }}" style="align-self:flex-start;width:56px;height:30px;border-radius:20px;border:none;cursor:pointer;background:{{ c.trackBg }};position:relative;padding:0">
                      <span style="position:absolute;top:3px;left:{{ c.knob }}px;width:24px;height:24px;border-radius:50%;background:#fff"></span>
                    </button>
                  </sc-if>
                  <sc-if value="{{ c.hayAyuda }}" hint-placeholder-val="{{ false }}">
                    <span style="font-size:11px;line-height:1.5;color:var(--text-3)">{{ c.ayuda }}</span>
                  </sc-if>
                  <sc-if value="{{ c.hayError }}" hint-placeholder-val="{{ false }}">
                    <span style="font-size:11.5px;line-height:1.45;color:var(--bad);font-weight:600">{{ c.error }}</span>
                  </sc-if>
                </div>
              </sc-for>
            </div>
          </div>
        </sc-for>

        <sc-if value="{{ esCobro }}" hint-placeholder-val="{{ false }}">
        <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;padding:22px;display:flex;flex-direction:column;gap:14px">
          <div>
            <h2 style="margin:0 0 4px;font-family:'Bricolage Grotesque',sans-serif;font-size:16px;font-weight:800;letter-spacing:-0.02em">Estado de las integraciones</h2>
            <p style="margin:0;font-size:12.5px;line-height:1.5;color:var(--text-3)">Un vistazo rápido, y probar la clave de Apple sin esperar a que alguien compre.</p>
          </div>
          <div style="display:flex;flex-wrap:wrap;gap:8px">
            <span style="display:inline-flex;align-items:center;gap:7px;padding:7px 13px;border-radius:20px;background:var(--surface-2);font-size:12.5px;font-weight:600"><span style="width:8px;height:8px;border-radius:50%;background:{{ estados.correo.color }}"></span>Correo: {{ estados.correo.texto }}</span>
            <span style="display:inline-flex;align-items:center;gap:7px;padding:7px 13px;border-radius:20px;background:var(--surface-2);font-size:12.5px;font-weight:600"><span style="width:8px;height:8px;border-radius:50%;background:{{ estados.appleCobro.color }}"></span>Cobro Apple: {{ estados.appleCobro.texto }}</span>
            <span style="display:inline-flex;align-items:center;gap:7px;padding:7px 13px;border-radius:20px;background:var(--surface-2);font-size:12.5px;font-weight:600"><span style="width:8px;height:8px;border-radius:50%;background:{{ estados.appleEntrar.color }}"></span>Apple web: {{ estados.appleEntrar.texto }}</span>
            <span style="display:inline-flex;align-items:center;gap:7px;padding:7px 13px;border-radius:20px;background:var(--surface-2);font-size:12.5px;font-weight:600"><span style="width:8px;height:8px;border-radius:50%;background:{{ estados.google.color }}"></span>Google: {{ estados.google.texto }}</span>
          </div>
          <button onClick="{{ probarApple }}" style="align-self:flex-start;padding:11px 18px;border-radius:12px;border:1px solid var(--border-strong);background:transparent;color:var(--text);cursor:pointer;font-size:13px;font-weight:700">{{ botonApple }}</button>
          <sc-if value="{{ hayPruebaApple }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 15px;border-radius:12px;background:{{ pruebaAppleBg }};color:{{ pruebaAppleColor }};font-size:13px;line-height:1.5;font-weight:600">{{ pruebaAppleMsg }}</div>
          </sc-if>
        </div>
        </sc-if>

        <sc-if value="{{ esIA }}" hint-placeholder-val="{{ false }}">
        <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;padding:22px;display:flex;flex-direction:column;gap:14px">
          <div style="display:flex;align-items:flex-start;gap:12px;flex-wrap:wrap">
            <div style="flex:1;min-width:220px">
              <h2 style="margin:0 0 4px;font-family:'Bricolage Grotesque',sans-serif;font-size:16px;font-weight:800;letter-spacing:-0.02em">Proveedores de IA</h2>
              <p style="margin:0;font-size:12.5px;line-height:1.5;color:var(--text-3)">{{ resumenIA }}</p>
            </div>
            <button onClick="{{ nuevoIA }}" style="flex:none;padding:10px 16px;border-radius:11px;border:none;background:var(--accent);color:var(--accent-ink);cursor:pointer;font-size:13px;font-weight:700">+ Proveedor</button>
          </div>
          <sc-for list="{{ iaProveedores }}" as="p" hint-placeholder-count="2">
            <div style="display:flex;flex-direction:column;gap:8px;padding:12px 14px;border-radius:14px;background:var(--surface-2)">
              <div style="display:flex;align-items:center;gap:12px">
                <div style="display:flex;flex-direction:column;gap:2px">
                  <button onClick="{{ p.subir }}" aria-label="Subir" style="width:22px;height:18px;border:none;border-radius:6px;background:transparent;color:var(--text-3);cursor:pointer;display:flex;align-items:center;justify-content:center"><svg viewBox="0 0 24 24" style="width:13px;height:13px" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M6 15l6-6 6 6"></path></svg></button>
                  <button onClick="{{ p.bajar }}" aria-label="Bajar" style="width:22px;height:18px;border:none;border-radius:6px;background:transparent;color:var(--text-3);cursor:pointer;display:flex;align-items:center;justify-content:center"><svg viewBox="0 0 24 24" style="width:13px;height:13px" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6"></path></svg></button>
                </div>
                <div style="min-width:0;flex:1">
                  <div style="display:flex;align-items:center;gap:8px;flex-wrap:wrap">
                    <span style="font-weight:700;font-size:14px">{{ p.nombre }}</span>
                    <span style="font-size:10px;font-weight:800;letter-spacing:0.05em;color:var(--text-3);border:1px solid var(--border-strong);border-radius:20px;padding:1px 7px">{{ p.tipo }}</span>
                    <span style="display:inline-flex;align-items:center;gap:5px;font-size:11.5px;font-weight:600;color:{{ p.estadoColor }}"><span style="width:7px;height:7px;border-radius:50%;background:{{ p.estadoColor }}"></span>{{ p.estadoTexto }}</span>
                  </div>
                  <div style="font-size:12px;color:var(--text-3)">{{ p.detalle }} · <span style="color:{{ p.fallosColor }}">{{ p.fallosTexto }}</span></div>
                </div>
                <button onClick="{{ p.probar }}" style="flex:none;padding:7px 11px;border-radius:9px;border:1px solid var(--border-strong);background:transparent;color:var(--text-2);cursor:pointer;font-size:12px;font-weight:700">Probar</button>
                <button onClick="{{ p.toggle }}" style="flex:none;padding:7px 11px;border-radius:9px;border:1px solid var(--border-strong);background:transparent;color:var(--text-2);cursor:pointer;font-size:12px;font-weight:700">{{ p.estadoTexto }}</button>
                <button onClick="{{ p.editar }}" style="flex:none;padding:7px 11px;border-radius:9px;border:1px solid var(--border-strong);background:transparent;color:var(--text-2);cursor:pointer;font-size:12px;font-weight:700">Editar</button>
                <button onClick="{{ p.quitar }}" style="flex:none;padding:7px 10px;border-radius:9px;border:1px solid var(--bad-border);background:transparent;color:var(--bad);cursor:pointer;font-size:12px;font-weight:700">Quitar</button>
              </div>
              <sc-if value="{{ p.hayPrueba }}" hint-placeholder-val="{{ false }}">
                <div style="font-size:12.5px;font-weight:600;color:{{ p.pruebaColor }}">{{ p.pruebaMsg }}</div>
              </sc-if>
            </div>
          </sc-for>
          <sc-if value="{{ iaAbierto }}" hint-placeholder-val="{{ false }}">
            <div style="border-top:1px solid var(--border);padding-top:14px;display:flex;flex-direction:column;gap:11px">
              <div style="font-size:13px;font-weight:700">{{ iaTitulo }}</div>
              <div style="display:flex;gap:6px;flex-wrap:wrap">
                <sc-for list="{{ iaPresets }}" as="pr" hint-placeholder-count="6">
                  <button onClick="{{ pr.elegir }}" style="padding:8px 12px;border-radius:999px;border:1px solid var(--border-strong);background:transparent;color:var(--text-2);cursor:pointer;font-size:12px;font-weight:700">{{ pr.label }}</button>
                </sc-for>
              </div>
              <input value="{{ iaForm.nombre }}" onChange="{{ onIANombre }}" placeholder="Nombre (p. ej. DeepSeek principal)" style="padding:11px 13px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;width:100%" />
              <div style="display:flex;gap:10px;flex-wrap:wrap">
                <input value="{{ iaForm.base }}" onChange="{{ onIABase }}" placeholder="URL base de la API (https://api.deepseek.com)" style="padding:11px 13px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;width:100%;flex:2;min-width:220px" />
                <input value="{{ iaForm.modelo }}" onChange="{{ onIAModelo }}" placeholder="Modelo (deepseek-chat)" style="padding:11px 13px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;width:100%;flex:1;min-width:160px" />
              </div>
              <input value="{{ iaForm.clave }}" onChange="{{ onIAClave }}" type="password" placeholder="Clave de la API" style="padding:11px 13px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;width:100%" />
              <p style="margin:0;font-size:12px;line-height:1.5;color:var(--text-3)">Todos los de la lista hablan el formato de OpenAI (chat/completions con herramientas); Anthropic habla el suyo. La clave nunca sale entera de aquí.</p>
              <div style="display:flex;gap:10px">
                <button onClick="{{ guardarIA }}" style="padding:12px 20px;border-radius:12px;border:none;background:var(--accent);color:var(--accent-ink);cursor:pointer;font-size:14px;font-weight:700">{{ botonIA2 }}</button>
                <button onClick="{{ cerrarIAForm }}" style="padding:12px 16px;border-radius:12px;border:1px solid var(--border-strong);background:transparent;color:var(--text-2);cursor:pointer;font-size:13px;font-weight:700">Cancelar</button>
              </div>
            </div>
          </sc-if>
        </div>
        <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;padding:22px;display:flex;flex-direction:column;gap:10px">
          <h2 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-size:16px;font-weight:800;letter-spacing:-0.02em">Qué se le manda al modelo</h2>
          <p style="margin:0;font-size:12.5px;line-height:1.55;color:var(--text-3)">Esto es, tal cual, lo que viaja en cada mensaje: las instrucciones de la casa (más las tuyas de arriba), un resumen de la persona con sus categorías, cuentas, tarjetas, préstamos, presupuesto y totales del mes, las herramientas que el modelo puede pedir, y las últimas ocho vueltas de ese canal. Nunca los movimientos uno a uno, ni conceptos, ni correos. Los números de las respuestas los calcula Chinola con las herramientas; el modelo solo los explica.</p>
          <pre style="margin:0;padding:14px;border-radius:12px;background:var(--surface-2);font-size:11.5px;line-height:1.5;overflow:auto;max-height:420px;white-space:pre-wrap;word-break:break-word">{{ iaEjemploTexto }}</pre>
        </div>
        </sc-if>
        </div>
        </sc-if>
        <sc-if value="{{ esTelegram }}" hint-placeholder-val="{{ false }}">
        <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;padding:22px;display:flex;flex-direction:column;gap:14px">
          <div>
            <h2 style="margin:0 0 4px;font-family:'Bricolage Grotesque',sans-serif;font-size:16px;font-weight:800;letter-spacing:-0.02em">Probar el bot</h2>
            <p style="margin:0;font-size:12.5px;line-height:1.5;color:var(--text-3)">Comprueba el token con Telegram y deja puesto el webhook en la URL pública. Hay que repetirlo si cambia la URL.</p>
          </div>
          <button onClick="{{ probarTelegram }}" style="align-self:flex-start;padding:11px 18px;border-radius:12px;border:1px solid var(--border-strong);background:transparent;color:var(--text);cursor:pointer;font-size:13px;font-weight:700">{{ botonTelegram }}</button>
          <sc-if value="{{ hayPruebaTelegram }}" hint-placeholder-val="{{ false }}">
            <div style="padding:12px 15px;border-radius:12px;background:{{ pruebaTelegramBg }};color:{{ pruebaTelegramColor }};font-size:13px;line-height:1.5;font-weight:600">{{ pruebaTelegramMsg }}</div>
          </sc-if>
        </div>
        </sc-if>

        <div style="display:flex;justify-content:flex-end">
          <button onClick="{{ guardarAjustes }}" style="padding:13px 22px;border-radius:12px;border:none;background:var(--accent);color:var(--accent-ink);cursor:pointer;font-size:14px;font-weight:700">{{ botonGuardar }}</button>
        </div>
      </div>
    </sc-if>

    <!-- PLANTILLAS -->
    <sc-if value="{{ esPlantillas }}" hint-placeholder-val="{{ false }}">
      <div style="display:grid;grid-template-columns:270px minmax(0,1fr);gap:16px;align-items:start">
        <div style="display:flex;flex-direction:column;gap:10px">
          <sc-if value="{{ creando }}" hint-placeholder-val="{{ false }}">
            <div style="background:var(--surface);border:1px solid var(--border);border-radius:16px;padding:14px;display:flex;flex-direction:column;gap:9px">
              <span style="font-size:12px;font-weight:700;color:var(--text-2)">Nombre de la plantilla</span>
              <input value="{{ nuevaPlantilla }}" onChange="{{ onNuevaPlantilla }}" placeholder="Recordatorio de corte" style="padding:11px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit" />
              <div style="display:flex;gap:8px">
                <button onClick="{{ crearPlantilla }}" style="flex:1;padding:11px;border-radius:11px;border:none;background:var(--accent);color:var(--accent-ink);cursor:pointer;font-size:13px;font-weight:700">Crear</button>
                <button onClick="{{ cancelarPlantilla }}" style="padding:11px 14px;border-radius:11px;border:1px solid var(--border-strong);background:transparent;color:var(--text-2);cursor:pointer;font-size:13px">Cancelar</button>
              </div>
            </div>
          </sc-if>
          <button onClick="{{ abrirNuevaPlantilla }}" style="padding:12px;border-radius:14px;border:1px dashed var(--border-strong);background:transparent;color:var(--text);cursor:pointer;font-size:13px;font-weight:700">+ Nueva plantilla</button>
        <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;overflow:hidden">
          <sc-for list="{{ plantillas }}" as="p" hint-placeholder-count="6">
            <button onClick="{{ p.go }}" style="width:100%;display:flex;flex-direction:column;gap:3px;align-items:flex-start;padding:14px 16px;border:none;border-bottom:1px solid var(--border-soft);background:{{ p.bg }};cursor:pointer;text-align:left;color:inherit">
              <span style="display:flex;align-items:center;gap:8px;width:100%">
                <span style="flex:1;font-size:13px;font-weight:700">{{ p.nombre }}</span>
                <span style="width:8px;height:8px;border-radius:50%;background:{{ p.punto }}"></span>
              </span>
              <span style="font-size:11px;line-height:1.45;color:var(--text-3)">{{ p.descripcion }}</span>
            </button>
          </sc-for>
        </div>

        <sc-if value="{{ hayPlantilla }}" hint-placeholder-val="{{ true }}">
          <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;padding:22px;display:flex;flex-direction:column;gap:14px;min-width:0">
            <div style="display:flex;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap">
              <h2 style="margin:0;font-family:'Bricolage Grotesque',sans-serif;font-size:18px;font-weight:800;letter-spacing:-0.02em">{{ editor.nombre }}</h2>
              <span style="display:flex;align-items:center;gap:10px">
                <span style="font-size:12px;color:var(--text-2)">{{ editor.estadoTexto }}</span>
                <button onClick="{{ toggleActiva }}" style="width:56px;height:30px;border-radius:20px;border:none;cursor:pointer;background:{{ editor.trackBg }};position:relative;padding:0">
                  <span style="position:absolute;top:3px;left:{{ editor.knob }}px;width:24px;height:24px;border-radius:50%;background:#fff"></span>
                </button>
              </span>
            </div>
            <label style="display:flex;flex-direction:column;gap:6px">
              <span style="font-size:12px;font-weight:700;color:var(--text-2)">Asunto</span>
              <input value="{{ editor.asunto }}" onChange="{{ onAsunto }}" style="padding:12px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit" />
            </label>
            <div style="display:flex;gap:8px;flex-wrap:wrap;align-items:center">
              <span style="font-size:12px;color:var(--text-3)">Variables:</span>
              <sc-for list="{{ editor.variables }}" as="v" hint-placeholder-count="5">
                <button onClick="{{ v.go }}" title="Copiar" style="padding:5px 10px;border-radius:8px;border:1px solid var(--border-strong);background:var(--surface-2);color:var(--text-2);cursor:pointer;font-size:11px;font-weight:700">{{ v.label }}</button>
              </sc-for>
            </div>
            <label style="display:flex;flex-direction:column;gap:6px">
              <span style="font-size:12px;font-weight:700;color:var(--text-2)">Cuerpo (HTML)</span>
              <textarea value="{{ editor.cuerpo }}" onChange="{{ onCuerpo }}" rows="16" spellcheck="false" style="padding:13px;border-radius:12px;border:1px solid var(--border);background:var(--surface-sunken);color:var(--text);font-family:ui-monospace,SFMono-Regular,Menlo,monospace;font-size:12px;line-height:1.6;resize:vertical"></textarea>
            </label>
            <div style="display:flex;gap:10px;flex-wrap:wrap">
              <button onClick="{{ guardarPlantilla }}" style="padding:13px 22px;border-radius:12px;border:none;background:var(--accent);color:var(--accent-ink);cursor:pointer;font-size:14px;font-weight:700">Guardar plantilla</button>
              <button onClick="{{ verPrevia }}" style="padding:13px 18px;border-radius:12px;border:1px solid var(--border-strong);background:transparent;color:var(--text);cursor:pointer;font-size:13px;font-weight:700">{{ botonPrevia }}</button>
              <button onClick="{{ probarPlantilla }}" style="padding:13px 18px;border-radius:12px;border:1px solid var(--border-strong);background:transparent;color:var(--text);cursor:pointer;font-size:13px;font-weight:700">Enviarme una prueba</button>
              <sc-if value="{{ editor.borrable }}" hint-placeholder-val="{{ false }}">
                <button onClick="{{ eliminarPlantilla }}" style="margin-left:auto;padding:13px 18px;border-radius:12px;border:1px solid var(--bad-border);background:transparent;color:var(--bad-strong);cursor:pointer;font-size:13px;font-weight:700">Eliminar</button>
              </sc-if>
            </div>
            <sc-if value="{{ hayPrevia }}" hint-placeholder-val="{{ false }}">
              <div style="border-radius:14px;overflow:hidden;border:1px solid var(--border)">
                <div style="padding:10px 14px;background:var(--surface-2);font-size:12px;font-weight:700">{{ previaAsunto }}</div>
                <iframe srcdoc="{{ previaHtml }}" style="width:100%;height:420px;border:none;background:#fff"></iframe>
              </div>
            </sc-if>
          </div>
        </sc-if>
      </div>
      </div>
    </sc-if>

    <!-- CORREO: registro de envíos y aviso masivo -->
    <sc-if value="{{ esCorreo }}" hint-placeholder-val="{{ false }}">
      <div style="display:flex;flex-direction:column;gap:16px">

        <!-- Proveedores de correo (pool) -->
        <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;padding:22px;display:flex;flex-direction:column;gap:14px">
          <div style="display:flex;align-items:flex-start;justify-content:space-between;gap:12px;flex-wrap:wrap">
            <div style="min-width:0">
              <h2 style="margin:0 0 4px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">Proveedores de correo</h2>
              <p style="margin:0;font-size:12.5px;line-height:1.5;color:var(--text-3)">{{ resumenPool }}</p>
            </div>
            <button onClick="{{ nuevoProveedor }}" style="flex:none;padding:10px 16px;border-radius:11px;border:none;background:var(--accent);color:var(--accent-ink);cursor:pointer;font-size:13px;font-weight:700">+ Proveedor</button>
          </div>
          <div style="display:flex;gap:10px;flex-wrap:wrap;align-items:center;padding:12px 14px;border-radius:12px;background:var(--surface-2)">
            <span style="font-size:12.5px;font-weight:600;color:var(--text-2)">Probar el pool enviando un correo a</span>
            <input value="{{ pruebaDestino }}" onChange="{{ onPruebaDestino }}" type="email" placeholder="tu@correo.com" style="flex:1;min-width:180px;padding:9px 12px;border-radius:10px;border:1px solid var(--border);background:var(--surface);color:inherit;font-size:13px" />
            <button onClick="{{ probarCorreo }}" style="flex:none;padding:9px 15px;border-radius:10px;border:1px solid var(--border-strong);background:transparent;color:var(--text);cursor:pointer;font-size:12.5px;font-weight:700">Enviar prueba</button>
          </div>

          <sc-for list="{{ proveedores }}" as="p" hint-placeholder-count="2">
            <div style="display:flex;align-items:center;gap:12px;padding:12px 14px;border-radius:14px;background:var(--surface-2)">
              <div style="display:flex;flex-direction:column;gap:2px">
                <button onClick="{{ p.subir }}" aria-label="Subir" style="width:22px;height:18px;border:none;border-radius:6px;background:transparent;color:var(--text-3);cursor:pointer;display:flex;align-items:center;justify-content:center"><svg viewBox="0 0 24 24" style="width:13px;height:13px" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M6 15l6-6 6 6"></path></svg></button>
                <button onClick="{{ p.bajar }}" aria-label="Bajar" style="width:22px;height:18px;border:none;border-radius:6px;background:transparent;color:var(--text-3);cursor:pointer;display:flex;align-items:center;justify-content:center"><svg viewBox="0 0 24 24" style="width:13px;height:13px" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6"></path></svg></button>
              </div>
              <div style="min-width:0;flex:1">
                <div style="display:flex;align-items:center;gap:8px">
                  <span style="font-weight:700;font-size:14px">{{ p.nombre }}</span>
                  <span style="font-size:10px;font-weight:800;letter-spacing:0.05em;color:var(--text-3);border:1px solid var(--border-strong);border-radius:20px;padding:1px 7px">{{ p.tipo }}</span>
                  <span style="display:inline-flex;align-items:center;gap:5px;font-size:11.5px;font-weight:600;color:{{ p.estadoColor }}"><span style="width:7px;height:7px;border-radius:50%;background:{{ p.estadoColor }}"></span>{{ p.estadoTexto }}</span>
                </div>
                <div style="font-size:12px;color:var(--text-3)">{{ p.remitente }} · <span style="color:{{ p.fallosColor }}">{{ p.fallosTexto }}</span></div>
              </div>
              <button onClick="{{ p.toggle }}" style="flex:none;padding:7px 11px;border-radius:9px;border:1px solid var(--border-strong);background:transparent;color:var(--text-2);cursor:pointer;font-size:12px;font-weight:700">{{ p.estadoTexto }}</button>
              <button onClick="{{ p.editar }}" style="flex:none;padding:7px 11px;border-radius:9px;border:1px solid var(--border-strong);background:transparent;color:var(--text-2);cursor:pointer;font-size:12px;font-weight:700">Editar</button>
              <button onClick="{{ p.quitar }}" style="flex:none;padding:7px 10px;border-radius:9px;border:1px solid var(--bad-border);background:transparent;color:var(--bad);cursor:pointer;font-size:12px;font-weight:700">Quitar</button>
            </div>
          </sc-for>

          <sc-if value="{{ provAbierto }}" hint-placeholder-val="{{ false }}">
            <div style="border-top:1px solid var(--border);padding-top:14px;display:flex;flex-direction:column;gap:11px">
              <div style="font-size:13px;font-weight:700">{{ provTitulo }}</div>
              <div style="display:flex;gap:8px">
                <button onClick="{{ provTipoResend }}" style="flex:1;padding:10px;border-radius:10px;border:none;background:{{ provTipoBgR }};color:{{ provTipoFgR }};cursor:pointer;font-size:13px;font-weight:700">Resend (API)</button>
                <button onClick="{{ provTipoSmtp }}" style="flex:1;padding:10px;border-radius:10px;border:none;background:{{ provTipoBgS }};color:{{ provTipoFgS }};cursor:pointer;font-size:13px;font-weight:700">SMTP</button>
              </div>
              <input value="{{ provForm.nombre }}" onChange="{{ onProvNombre }}" placeholder="Nombre (p. ej. Resend principal)" style="padding:11px 13px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;width:100%" />
              <div style="display:flex;gap:10px;flex-wrap:wrap">
                <input value="{{ provForm.remitenteNombre }}" onChange="{{ onProvRemNombre }}" placeholder="Nombre del remitente" style="padding:11px 13px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;width:100%;flex:1;min-width:150px" />
                <input value="{{ provForm.remitenteEmail }}" onChange="{{ onProvRemEmail }}" type="email" placeholder="Correo del remitente (dominio verificado)" style="padding:11px 13px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;width:100%;flex:1;min-width:200px" />
              </div>
              <sc-if value="{{ provEsResend }}" hint-placeholder-val="{{ true }}">
                <input value="{{ provForm.apiKey }}" onChange="{{ onProvApiKey }}" type="password" placeholder="API key de Resend (re_…)" style="padding:11px 13px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;width:100%" />
              </sc-if>
              <sc-if value="{{ provEsSmtp }}" hint-placeholder-val="{{ false }}">
                <div style="display:flex;flex-direction:column;gap:11px">
                  <div style="display:flex;gap:10px;flex-wrap:wrap">
                    <input value="{{ provForm.host }}" onChange="{{ onProvHost }}" placeholder="Host SMTP" style="padding:11px 13px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;width:100%;flex:2;min-width:180px" />
                    <input value="{{ provForm.puerto }}" onChange="{{ onProvPuerto }}" type="number" placeholder="Puerto" style="padding:11px 13px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;width:100%;flex:1;min-width:90px" />
                  </div>
                  <div style="display:flex;gap:10px;flex-wrap:wrap">
                    <input value="{{ provForm.usuario }}" onChange="{{ onProvUsuario }}" placeholder="Usuario SMTP" style="padding:11px 13px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;width:100%;flex:1;min-width:150px" />
                    <input value="{{ provForm.clave }}" onChange="{{ onProvClave }}" type="password" placeholder="Contraseña SMTP" style="padding:11px 13px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;width:100%;flex:1;min-width:150px" />
                  </div>
                  <label style="display:flex;align-items:center;gap:10px;font-size:13px;color:var(--text-2)">
                    <button onClick="{{ onProvSeguro }}" style="width:50px;height:28px;border-radius:20px;border:none;cursor:pointer;background:{{ provSeguroTrack }};position:relative;padding:0;flex:none"><span style="position:absolute;top:3px;left:{{ provSeguroKnob }}px;width:22px;height:22px;border-radius:50%;background:#fff"></span></button>
                    TLS directo (puerto 465)
                  </label>
                </div>
              </sc-if>
              <div style="display:flex;gap:10px">
                <button onClick="{{ guardarProveedor }}" style="padding:11px 18px;border-radius:11px;border:none;background:var(--accent);color:var(--accent-ink);cursor:pointer;font-size:13px;font-weight:700">{{ botonProv }}</button>
                <button onClick="{{ cerrarProvForm }}" style="padding:11px 16px;border-radius:11px;border:1px solid var(--border-strong);background:transparent;color:var(--text-2);cursor:pointer;font-size:13px;font-weight:700">Cancelar</button>
              </div>
            </div>
          </sc-if>
        </div>

        <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;padding:22px">
          <h2 style="margin:0 0 4px;font-family:'Bricolage Grotesque',sans-serif;font-size:17px;font-weight:800;letter-spacing:-0.02em">Enviar un aviso</h2>
          <p style="margin:0 0 16px;font-size:13px;line-height:1.55;color:var(--text-3)">Usa la plantilla «Aviso masivo». Se envía uno por uno y queda en el registro de abajo.</p>
          <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:12px">
            <select value="{{ avisoDestino }}" onChange="{{ onAvisoDestino }}" style="padding:12px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit">
              <sc-for list="{{ destinos }}" as="d" hint-placeholder-count="3"><option value="{{ d.id }}">{{ d.label }}</option></sc-for>
            </select>
            <input value="{{ avisoTitulo }}" onChange="{{ onAvisoTitulo }}" placeholder="Título del aviso" style="padding:12px;border-radius:11px;border:1px solid var(--border);background:var(--surface-2);color:inherit" />
          </div>
          <textarea value="{{ avisoMensaje }}" onChange="{{ onAvisoMensaje }}" rows="4" placeholder="Mensaje" style="width:100%;margin-top:12px;padding:13px;border-radius:12px;border:1px solid var(--border);background:var(--surface-2);color:inherit;line-height:1.6;resize:vertical"></textarea>
          <button onClick="{{ enviarAviso }}" style="margin-top:12px;padding:14px 22px;border-radius:12px;border:none;background:var(--accent);color:var(--accent-ink);cursor:pointer;font-size:14px;font-weight:700">{{ botonAviso }}</button>
        </div>

        <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;overflow-x:auto">
          <div style="display:grid;grid-template-columns:1fr 1.6fr 1fr 2fr 0.8fr;gap:12px;min-width:820px;padding:14px 20px;background:var(--surface-2);font-size:11px;text-transform:uppercase;letter-spacing:0.07em;color:var(--text-3);font-weight:700">
            <span>Cuándo</span><span>Destino</span><span>Plantilla</span><span>Detalle</span><span>Estado</span>
          </div>
          <sc-for list="{{ envios }}" as="e" hint-placeholder-count="8">
            <div style="display:grid;grid-template-columns:1fr 1.6fr 1fr 2fr 0.8fr;gap:12px;min-width:820px;padding:12px 20px;border-top:1px solid var(--border-soft);align-items:center;font-size:13px">
              <span style="color:var(--text-3)">{{ e.cuando }}</span>
              <span style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ e.destino }}</span>
              <span style="color:var(--text-2)">{{ e.plantilla }}</span>
              <span style="color:var(--text-3);font-size:12px;line-height:1.45;overflow-wrap:anywhere">{{ e.detalle }}</span>
              <span style="font-weight:700;color:{{ e.color }}">{{ e.estado }}</span>
            </div>
          </sc-for>
        </div>
      </div>
    </sc-if>

    <!-- INTEGRACIONES -->
    <sc-if value="{{ esIntegraciones }}" hint-placeholder-val="{{ false }}">
      <div style="display:flex;flex-direction:column;gap:16px">
        <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;overflow-x:auto">
          <div style="display:grid;grid-template-columns:1.3fr 1.6fr 1fr 1fr 0.7fr;gap:12px;min-width:800px;padding:14px 20px;background:var(--surface-2);font-size:11px;text-transform:uppercase;letter-spacing:0.07em;color:var(--text-3);font-weight:700">
            <span>Clave</span><span>Cuenta</span><span>Creada</span><span>Último uso</span><span>Estado</span>
          </div>
          <sc-for list="{{ apiClaves }}" as="c" hint-placeholder-count="4">
            <div style="display:grid;grid-template-columns:1.3fr 1.6fr 1fr 1fr 0.7fr;gap:12px;min-width:800px;padding:12px 20px;border-top:1px solid var(--border-soft);align-items:center;font-size:13px">
              <span>
                <span style="display:block;font-weight:700">{{ c.nombre }}</span>
                <span style="display:block;font-size:11px;color:var(--text-3);font-family:ui-monospace,Menlo,monospace">{{ c.prefijo }}…</span>
              </span>
              <span style="color:var(--text-2);white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ c.email }}</span>
              <span style="color:var(--text-3)">{{ c.creada }}</span>
              <span style="color:var(--text-3)">{{ c.uso }}</span>
              <span style="font-weight:700;color:{{ c.color }}">{{ c.estado }}</span>
            </div>
          </sc-for>
        </div>

        <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;overflow-x:auto">
          <div style="display:grid;grid-template-columns:1fr 1.5fr 1.4fr 2fr 0.6fr;gap:12px;min-width:860px;padding:14px 20px;background:var(--surface-2);font-size:11px;text-transform:uppercase;letter-spacing:0.07em;color:var(--text-3);font-weight:700">
            <span>Cuándo</span><span>Cuenta</span><span>Ruta</span><span>Detalle</span><span>Código</span>
          </div>
          <sc-for list="{{ apiRegistro }}" as="r" hint-placeholder-count="8">
            <div style="display:grid;grid-template-columns:1fr 1.5fr 1.4fr 2fr 0.6fr;gap:12px;min-width:860px;padding:12px 20px;border-top:1px solid var(--border-soft);align-items:center;font-size:13px">
              <span style="color:var(--text-3)">{{ r.cuando }}</span>
              <span style="color:var(--text-2);white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ r.usuario }}</span>
              <span style="font-family:ui-monospace,Menlo,monospace;font-size:12px">{{ r.ruta }}</span>
              <span style="color:var(--text-3);font-size:12px;overflow-wrap:anywhere">{{ r.detalle }}</span>
              <span style="font-weight:700;color:{{ r.color }}">{{ r.estado }}</span>
            </div>
          </sc-for>
        </div>
      </div>
    </sc-if>

    <!-- AUDITORÍA -->
    <sc-if value="{{ esAuditoria }}" hint-placeholder-val="{{ false }}">
      <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;overflow-x:auto">
        <div style="display:grid;grid-template-columns:0.9fr 1.4fr 2.6fr 1fr;gap:12px;min-width:800px;padding:14px 20px;background:var(--surface-2);font-size:11px;text-transform:uppercase;letter-spacing:0.07em;color:var(--text-3);font-weight:700">
          <span>Cuándo</span><span>Actor</span><span>Acción</span><span>Origen</span>
        </div>
        <sc-for list="{{ auditoria }}" as="a" hint-placeholder-count="8">
          <div style="display:grid;grid-template-columns:0.9fr 1.4fr 2.6fr 1fr;gap:12px;min-width:800px;padding:12px 20px;border-top:1px solid var(--border-soft);font-size:13px;align-items:center">
            <span style="color:var(--text-3)">{{ a.cuando }}</span>
            <span style="font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ a.actor }}</span>
            <span style="color:var(--text-2);line-height:1.45">{{ a.accion }}</span>
            <span style="color:var(--text-3)">{{ a.origen }}</span>
          </div>
        </sc-for>
      </div>
    </sc-if>

    <sc-if value="{{ esEquipo }}" hint-placeholder-val="{{ false }}">
      <div style="display:flex;flex-direction:column;gap:22px;max-width:760px">

        <!-- Tu cuenta -->
        <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;padding:22px;display:flex;flex-direction:column;gap:18px">
          <div style="display:flex;align-items:center;gap:14px">
            <div style="width:46px;height:46px;border-radius:50%;background:var(--avatar);display:flex;align-items:center;justify-content:center;font-weight:800;font-size:18px">{{ cuenta.inicial }}</div>
            <div style="min-width:0">
              <div style="font-family:'Bricolage Grotesque',sans-serif;font-weight:800;font-size:17px;letter-spacing:-0.02em">{{ cuenta.nombre }}</div>
              <div style="font-size:13px;color:var(--text-3)">{{ cuenta.email }}</div>
            </div>
          </div>

          <!-- 2FA -->
          <div style="display:flex;align-items:center;justify-content:space-between;gap:14px;padding:14px 16px;border-radius:14px;background:var(--surface-2)">
            <div style="min-width:0">
              <div style="font-weight:700;font-size:14px">Verificación en dos pasos</div>
              <div style="font-size:12.5px;color:var(--text-3);line-height:1.45">Al entrar te pediremos un código de seis cifras por correo. Estado: <span style="color:{{ mfaColor }};font-weight:700">{{ mfaEtiqueta }}</span></div>
            </div>
            <button onClick="{{ alternaMfa }}" style="padding:10px 16px;border-radius:10px;border:1px solid var(--border-strong);background:transparent;color:inherit;cursor:pointer;font-size:13px;font-weight:700;white-space:nowrap">{{ mfaBoton }}</button>
          </div>

          <!-- Cambiar clave -->
          <div style="display:flex;flex-direction:column;gap:10px">
            <span style="font-size:11px;text-transform:uppercase;letter-spacing:0.07em;color:var(--text-3);font-weight:700">Cambiar mi contraseña</span>
            <div style="display:flex;gap:10px;flex-wrap:wrap">
              <input value="{{ claveForm.actual }}" onChange="{{ onClaveActual }}" type="password" placeholder="Contraseña actual" style="padding:12px 14px;border-radius:12px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;flex:1;min-width:180px" />
              <input value="{{ claveForm.nueva }}" onChange="{{ onClaveNueva }}" type="password" placeholder="Nueva (mín. 8)" style="padding:12px 14px;border-radius:12px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;flex:1;min-width:180px" />
            </div>
            <button onClick="{{ cambiarClave }}" style="padding:12px 18px;border-radius:12px;border:none;background:var(--accent);color:var(--accent-ink);cursor:pointer;font-size:14px;font-weight:700;align-self:flex-start">{{ botonClave }}</button>
          </div>
        </div>

        <!-- Equipo -->
        <div style="background:var(--surface);border:1px solid var(--border);border-radius:20px;padding:22px;display:flex;flex-direction:column;gap:16px">
          <div>
            <div style="font-family:'Bricolage Grotesque',sans-serif;font-weight:800;font-size:16px;letter-spacing:-0.02em">Administradores</div>
            <div style="font-size:12.5px;color:var(--text-3);line-height:1.45;margin-top:2px">Cuentas con acceso al portal. No tienen que ser usuarios de la app.</div>
          </div>

          <div style="display:flex;flex-direction:column;gap:8px">
            <sc-for list="{{ admins }}" as="a" hint-placeholder-count="2">
              <div style="display:flex;align-items:center;gap:12px;padding:12px 14px;border-radius:14px;background:var(--surface-2)">
                <div style="width:34px;height:34px;border-radius:50%;background:var(--avatar);display:flex;align-items:center;justify-content:center;font-weight:800;font-size:14px;flex:none">{{ a.inicial }}</div>
                <div style="min-width:0;flex:1">
                  <div style="display:flex;align-items:center;gap:8px">
                    <span style="font-weight:700;font-size:14px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis">{{ a.nombre }}</span>
                    <sc-if value="{{ a.etiqueta }}" hint-placeholder-val="{{ false }}"><span style="font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:0.06em;color:{{ a.etiquetaColor }};border:1px solid {{ a.etiquetaColor }};border-radius:20px;padding:1px 8px">{{ a.etiqueta }}</span></sc-if>
                  </div>
                  <div style="font-size:12px;color:var(--text-3)">{{ a.email }} · {{ a.acceso }}</div>
                </div>
                <sc-if value="{{ a.puedeQuitar }}" hint-placeholder-val="{{ true }}">
                  <button onClick="{{ a.quitar }}" style="padding:8px 12px;border-radius:10px;border:1px solid var(--bad-border);background:transparent;color:var(--bad);cursor:pointer;font-size:12.5px;font-weight:700;white-space:nowrap">Quitar</button>
                </sc-if>
              </div>
            </sc-for>
          </div>

          <div style="border-top:1px solid var(--border);padding-top:16px;display:flex;flex-direction:column;gap:10px">
            <span style="font-size:11px;text-transform:uppercase;letter-spacing:0.07em;color:var(--text-3);font-weight:700">Agregar administrador</span>
            <div style="display:flex;gap:10px;flex-wrap:wrap">
              <input value="{{ nuevoAdmin.nombre }}" onChange="{{ onNuevoNombre }}" placeholder="Nombre" style="padding:12px 14px;border-radius:12px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;flex:1;min-width:150px" />
              <input value="{{ nuevoAdmin.email }}" onChange="{{ onNuevoEmail }}" type="email" placeholder="correo@dominio.com" style="padding:12px 14px;border-radius:12px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;flex:1;min-width:180px" />
              <input value="{{ nuevoAdmin.clave }}" onChange="{{ onNuevoClave }}" type="password" placeholder="Contraseña (mín. 8)" style="padding:12px 14px;border-radius:12px;border:1px solid var(--border);background:var(--surface-2);color:inherit;font-size:14px;flex:1;min-width:170px" />
            </div>
            <button onClick="{{ crearAdmin }}" style="padding:12px 18px;border-radius:12px;border:none;background:var(--accent);color:var(--accent-ink);cursor:pointer;font-size:14px;font-weight:700;align-self:flex-start">{{ botonCrearAdmin }}</button>
          </div>
        </div>

      </div>
    </sc-if>
  </main>
</div>
</sc-if>
`;try{const d=localStorage.getItem("chinola-admin-tema");(d==="light"||d==="dark")&&(document.documentElement.dataset.tema=d)}catch{}const W=$(K,H,{});G(document.getElementById("raiz")).render(U.createElement(W));
