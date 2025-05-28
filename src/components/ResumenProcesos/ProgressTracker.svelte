<script lang="ts">
  export let titulo: string;
  export let descripcion: string = "";
  export let estadoProp: 'pendiente' | 'iniciado' | 'sellado' | 'validado' | 'alertado' | null = null;
  export let subprocesos: Record<string, boolean> = {}; // true = activo (negro), false = inactivo (gris)
  export let pasoActual: number = 1;
  export let totalPasos: number = 10;
  export let modalTarget: string = ''; // ID del modal a abrir
  export let validado: boolean | null = null; // Propiedad para forzar el estado validado
  
  // Determinar el estado basado en los subprocesos y la propiedad validado
  $: estado = (() => {
    // Si se proporciona un estado explícito, usarlo
    if (estadoProp) return estadoProp;
    
    const subprocesosArray = Object.values(subprocesos);
    
    // Si no hay subprocesos o todos son false, es 'pendiente'
    if (subprocesosArray.length === 0 || subprocesosArray.every(val => val === false)) {
      return 'pendiente';
    }
    
    // Verificar si el último subproceso es true
    const ultimoSubprocesoTieneExito = subprocesosArray[subprocesosArray.length - 1] === true;
    
    // Si el último subproceso es true y validado es true, es 'validado'
    if (ultimoSubprocesoTieneExito && validado === true) {
      return 'validado';
    }
    
    // Si solo el último subproceso es true, es 'sellado'
    if (ultimoSubprocesoTieneExito) {
      return 'sellado';
    }
    
    // Si hay al menos un subproceso true pero no es el último, es 'iniciado'
    return 'iniciado';
  })();
  
  // Mapa de títulos a IDs de modal
  const titleToModalMap: Record<string, string> = {
    '1. Hoja de Liquidación': 'modal-resumen-liquidacion',
    '2. Movimientos de caja': 'modal-movimientos-caja',
    '3. Nóminas': 'modal-nominas',
    '4. Listados de contadores, OpenPos y Mediciones': 'modal-listado-contadores',
    '5. Hojas de corte de periféricos': 'modal-hojas-corte-perifericos',
    '6. Recepción de carburantes con soportes': 'modal-recepcion-carburantes-soportes',
    '7. Listado de remisión de periféricos': 'modal-listado-remision-perifericos',
    '8. Regularización de existencias (Mermas)': 'modal-regularizacion-mermas',
    '9. Jarreo': 'modal-jarreo',
    '10. Vales por empresa': 'modal-vales-empresa',
    '11. Corte de terminales con vouchers': 'modal-corte-terminales',
    '12. Lista de placas con tag': 'modal-lista-placas'
  };
  
  // Determinar el ID del modal basado en el título
  $: modalId = modalTarget || (titulo in titleToModalMap ? titleToModalMap[titulo] : '');
  
  // Reaccionar a cambios en los subprocesos para actualizar el estado si es necesario
  $: if (!estadoProp) {
    // El estado se actualizará automáticamente en la próxima actualización
    estado = estado; // Forzar la actualización
  }
  
  // Función para manejar el clic en el botón
  function handleButtonClick() {
    if (!modalId) return;
    
    // Disparar un evento personalizado que será manejado por el script principal
    const event = new CustomEvent('openModal', { 
      detail: { modalId },
      bubbles: true,
      cancelable: true
    });
    
    // Disparar el evento
    window.dispatchEvent(event);
  }

  // Calcular el porcentaje completado basado en el paso actual
  $: porcentajeCompletado = totalPasos > 0 ? Math.round((pasoActual / totalPasos) * 100) : 0;
  
  // Generar array de pasos con sus subprocesos correspondientes
  $: pasos = (() => {
    const steps = [];
    let lastCompletedIndex = -1;
    
    // Primero encontramos el último paso completado
    Object.entries(subprocesos).forEach(([_, completado], index) => {
      if (completado) lastCompletedIndex = index;
    });
    
    // Creamos el array de pasos
    return Object.entries(subprocesos).map(([nombre, completado], index) => {
      const pasoNumero = index + 1;
      const esUltimoCompletado = completado && index === lastCompletedIndex;
      
      return {
        numero: pasoNumero,
        nombre: nombre || `Paso ${pasoNumero}`,
        activo: completado,
        esActual: pasoNumero === pasoActual,
        esUltimo: index === Object.keys(subprocesos).length - 1,
        mostrarCheck: esUltimoCompletado,
        mostrarNumero: true, // Mostrar siempre el número
        estaCompletado: completado // Para el estilo del número
      };
    });
  })();

  // Función para obtener las clases CSS según el estado
  function getClasesEstado(estado: string) {
    const clases = {
      base: 'text-sm font-semibold px-3 py-1 rounded-full whitespace-nowrap',
      pendiente: 'bg-blue-100 text-blue-800 border border-blue-200',
      iniciado: 'bg-blue-100 text-blue-800 border border-blue-200',
      sellado: 'bg-yellow-100 text-yellow-800 border border-yellow-200',
      validado: 'bg-green-100 text-green-800 border border-green-200',
      alertado: 'bg-red-100 text-red-800 border border-red-200'
    };
    
    return `${clases.base} ${clases[estado as keyof typeof clases] || ''}`;
  }

  // Función para formatear el texto del estado
  function formatearEstado(estado: string) {
    const estados: Record<string, string> = {
      pendiente: 'Pendiente',
      iniciado: 'Iniciado',
      sellado: 'Sellado',
      validado: 'Validado',
      alertado: 'Alertado'
    };
    
    return estados[estado] || estado;
  }

</script>

<div class="proceso-card bg-white rounded-lg p-4 mb-1 ">
  <!-- Encabezado del proceso principal -->
  <div class="flex justify-between items-start mb-4">
    <div class="flex-1">
      <h3 class="text-lg font-semibold text-gray-800">{titulo}</h3>
    </div>
    <div class="flex items-center space-x-2">
      <span class={getClasesEstado(estado)}>
        {formatearEstado(estado)}
      </span>
      {#if estado === 'pendiente'}
        <button 
          on:click={handleButtonClick}
          data-modal-target={modalId}
          class="text-white bg-blue-500 hover:bg-blue-600 transition-colors px-3 py-1 rounded-full text-sm font-medium"
          aria-label="Subir archivos"
          title="Subir archivos"
        >
          Subir
        </button>
      {:else}
        <button 
          on:click={handleButtonClick}
          data-modal-target={modalId}
          class="text-blue-600 hover:text-white bg-blue-50 hover:bg-blue-500 transition-colors p-2 rounded-full hover:shadow-md"
          aria-label="Ver detalles"
          title="Ver detalles"
        >
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
          </svg>
        </button>
      {/if}
    </div>
  </div>
  

  
  <!-- Descripción del proceso -->
  <div class="mb-4 text-sm text-gray-700">
    {descripcion}
  </div>
  
  <!-- Contenedor de pasos y subprocesos -->
  <div class="relative">
    <!-- Línea vertical de progreso -->
    <div class="absolute left-3 top-0 bottom-0 w-0.5 bg-gray-200">
      <div 
        class="absolute top-0 left-0 w-full bg-blue-500 transition-all duration-300"
        style={`height: ${porcentajeCompletado}%`}
      ></div>
    </div>
    
    <!-- Lista de pasos y subprocesos -->
    <div class="space-y-2 pl-5">
      {#each pasos as paso, i}
        <div class="relative">
          <!-- Número del paso -->
          <div class="absolute -left-4 top-0 w-4 h-4 flex items-center justify-center rounded-full 
                   {paso.activo 
                     ? 'bg-blue-500 text-white' 
                     : 'bg-white border border-gray-300 text-gray-400'}
                   {paso.esActual ? 'ring-2 ring-blue-400 scale-110' : ''}
                   text-[9px] font-medium transition-all duration-200">
            {paso.mostrarCheck ? '✓' : paso.numero}
          </div>
          
          <!-- Contenido del subproceso -->
          <div class="ml-1.5">
            <div class={`text-[11px] leading-tight ${paso.activo ? 'text-gray-900 font-medium' : 'text-gray-500'}`}>
              {paso.nombre}
            </div>
            {#if !paso.esUltimo}
              <div class="h-3 w-0.5 bg-gray-200 ml-1.5 mt-0.5"></div>
            {/if}
          </div>
        </div>
      {/each}
    </div>
  </div>
</div>

<style>
  .proceso-card {
    transition: all 0.2s ease;
  }
  .proceso-card:hover {
    box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
  }
</style>
