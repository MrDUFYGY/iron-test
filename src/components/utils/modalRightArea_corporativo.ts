// Extend the Window interface to include _originalMenuContent
declare global {
  interface Window {
    _originalMenuContent: string | null;
  }
}

// Mapa para relacionar los IDs de los modales con las URLs correspondientes
const modalUrlMap: Record<string, string> = {
  'modal-hoja-liquidacion-contador' : '/corporativo/corp_valija_1hojaLiquidacion', //1
  'modal-movimientos-caja-contador' : '/corporativo/corp_valija_2resultadosBusqueda', //2
  'modal-nominas-contador' : '/corporativo/corp_valija_3nominas', //3
  'modal-listado-contadores-contador' : '/corporativo/corp_valija_4sistemaArchivosxTurno', //4
  'modal-recepcion-carburantes-contador' : '/corporativo/corp_valija_5historicoCarburante', //5
  'modal-listado-remision-perifericos-contador' : '/corporativo/corp_valija_6resultadoVentasxPeriodo', //6
  'modal-regularizacion-mermas-contador' : '/corporativo/corp_valija_7resultadosMermasRegul', //7
  'modal-jarreo-contador' : '/corporativo/corp_valija_8jarreo', //8 
  'modal-vales-empresa-contador' : '/corp_valija_11valesEmpresa', //9
  'modal-corte-terminales-contador' : '/corp_valija_10terminalesVoucher', //10
  'modal-placas-tag-contador' : '/corp_valija_11placasTag', //11
};

export function initResumenProcesos() {
  const header = document.getElementById("resumen-procesos-header");
  const content = document.getElementById("resumen-procesos-content");
  const icon = document.getElementById("resumen-procesos-icon");

  if (!header || !content || !icon) return;

  // Inicialmente cerrado
  let isOpen = false;

  header.addEventListener("click", () => {
    isOpen = !isOpen;

    if (isOpen) {
      content.style.maxHeight = content.scrollHeight + "px";
      content.classList.add("pb-2");
      icon.textContent = "▲";
    } else {
      content.style.maxHeight = "0";
      content.classList.remove("pb-2");
      icon.textContent = "▼";
    }
  });
}



export function modalRightArea() {
  // Función para abrir el contenido en el panel del modal
  document.addEventListener("click", function (event) {
    const target = (event.target as HTMLElement).closest(
      "[data-modal-target]"
    );
    
    if (!target) return;
    
    event.preventDefault();
    const modalId = target.getAttribute("data-modal-target") || "";
    const modalContainer = document.getElementById("modal-container");

    if (!modalContainer || !modalId || !modalUrlMap[modalId]) return;

    const url = modalUrlMap[modalId];

    // Guardar el contenido original del menú si no está guardado
    if (!window._originalMenuContent) {
      window._originalMenuContent = modalContainer.innerHTML;
    }

    // Limpiar contenido anterior
    modalContainer.innerHTML = "";

    // Crear el iframe para cargar la página
    const iframe = document.createElement("iframe");
    iframe.src = url;
    iframe.style.width = "100%";
    iframe.style.height = "85%";
    iframe.style.border = "none";
    iframe.title = "Contenido del modal";

    // Agregar título al modal
    const modalHeader = document.createElement("div");
    modalHeader.className = "relative sticky top-0 bg-white p-4 mb-4 rounded-lg shadow flex items-center justify-between z-50";

    const modalTitle = document.createElement("h2");
    modalTitle.className = "text-xl font-semibold text-gray-800";
    modalTitle.textContent = "Detalle de " + modalId.replace("modal-", "").replace(/-/g, " ");

    // Create button container for better spacing
    const buttonContainer = document.createElement("div");
    buttonContainer.className = "flex space-x-2";
    
    // Create button to open in new tab
    const newTabButton = document.createElement("button");
    newTabButton.className = "bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600 transition-colors flex items-center";
    newTabButton.innerHTML = `
      <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
      </svg>
      Abrir en nueva pestaña
    `;
    newTabButton.onclick = function (e) {
      e.stopPropagation();
      window.open(url, '_blank');
    };

    // Create close button
    const closeButton = document.createElement("button");
    closeButton.className = "bg-gray-500 text-white px-3 py-1 rounded hover:bg-gray-600 transition-colors";
    closeButton.textContent = "Cerrar";
    closeButton.onclick = function (e) {
      e.stopPropagation();
      // Restaurar el menú original sin recargar
      if (modalContainer && window._originalMenuContent) {
        modalContainer.innerHTML = window._originalMenuContent;
        window._originalMenuContent = null;
      }
    };

    // Append buttons to container
    buttonContainer.appendChild(newTabButton);
    buttonContainer.appendChild(closeButton);
    
    // Append title and buttons to header
    modalHeader.appendChild(modalTitle);
    modalHeader.appendChild(buttonContainer);

    modalContainer.appendChild(modalHeader);
    modalContainer.appendChild(iframe);
  });
}