<script lang="ts">
  export let titulo: string;
  export let descripcion: string;
  export let estado: 'pendiente' | 'iniciado' | 'sellado' | 'validado' | 'alertado';
  export let subprocesos: Record<string, boolean> = {}; // true = activo (negro), false = inactivo (gris)
  export let pasoActual: number = 1;
  export let totalPasos: number = 10;

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
      base: 'text-xs font-medium px-2.5 py-0.5 rounded-full whitespace-nowrap',
      pendiente: 'bg-blue-100 text-blue-800',
      iniciado: 'bg-blue-100 text-blue-800',
      sellado: 'bg-yellow-100 text-yellow-800',
      validado: 'bg-green-100 text-green-800',
      alertado: 'bg-red-100 text-red-800'
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

  // Función para obtener clases de subproceso (activo/inactivo)
  function getClasesSubproceso(activo: boolean) {
    return `text-sm ${activo ? 'text-gray-900 font-medium' : 'text-gray-400'}`;
  }
</script>

<div class="proceso-card bg-white border border-gray-200 rounded-lg p-4 mb-1 shadow-sm hover:shadow-md transition-shadow">
  <!-- Encabezado del proceso principal -->
  <div class="flex justify-between items-start mb-4">
    <h3 class="text-lg font-semibold text-gray-800">{titulo}</h3>
    <span class={getClasesEstado(estado)}>
      {formatearEstado(estado)}
    </span>
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
