<script lang="ts">
  import { onMount } from 'svelte';
  import ProgressTracker from './ProgressTracker.svelte';

  export let autoPrint = false;

  type Proceso = {
    titulo: string;
    descripcion: string;
    estado: 'pendiente' | 'iniciado' | 'sellado' | 'validado' | 'alertado';
    subprocesos: Record<string, boolean>;
    pasoActual?: number;
    totalPasos?: number;
  };

  type ProcesosData = {
    usuario: { nombre: string; [key: string]: any };
    fecha: string;
    estacion: { nombre: string; [key: string]: any };
    procesos: Proceso[];
  };

  export let data: string | ProcesosData | null = null;

  $: parsedData = (() => {
    const dataObj = typeof data === 'string' ? JSON.parse(data) : data;
    if (!dataObj?.procesos) return dataObj;
    const procesosActualizados = dataObj.procesos.map((proceso: Proceso) => {
      const subprocesos = Object.entries(proceso.subprocesos || {});
      let ultimoCompletado = 0;
      subprocesos.forEach(([_, completado], index) => {
        if (completado) ultimoCompletado = index + 1;
      });
      return { ...proceso, pasoActual: ultimoCompletado, totalPasos: subprocesos.length };
    });
    return { ...dataObj, procesos: procesosActualizados };
  })();

  // Si quieres que imprima automáticamente al montar el componente:
  onMount(() => {
    if (autoPrint) {
      handlePrint();
    }
  });

  // Formato de fecha
  function formatDate(dateString: string) {
    const options = { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' };
    return new Date(dateString).toLocaleDateString('es-MX', options);
  }

  // Aquí está la clave: sólo llama window.print() para imprimir la página actual
  function handlePrint() {
    window.print();
  }
</script>

<style>
  /* PARA IMPRESIÓN: oculta TODO excepto #printable-content */
  @media print {
    body * {
      visibility: hidden !important;
    }
    #printable-content, #printable-content * {
      visibility: visible !important;
    }
    #printable-content {
      position: absolute;
      left: 0;
      top: 0;
      width: 100%;
      padding: 1rem;
      background: white;
    }
  }
</style>

<!-- Botón para imprimir -->
<button
  on:click={handlePrint}
  class="bg-gray-600 hover:bg-gray-700 text-white font-medium text-sm py-2 px-4 rounded-md transition-colors flex items-center justify-center gap-2 mx-auto"
>
  <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
      d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
  </svg>

</button>



<!-- Contenido que se imprimirá -->
<div id="printable-content" class="hidden print:block p-4 border rounded-md mt-4">
  <h3 class="text-lg font-medium text-gray-900 mb-4">Resumen de Procesos</h3>

  {#if parsedData}
    <div class="bg-gray-50 p-4 rounded-lg mb-6">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <h4 class="text-sm font-medium text-gray-500">Usuario</h4>
          <p class="mt-1 text-sm text-gray-900">{parsedData.usuario?.nombre || 'N/A'}</p>
        </div>
        <div>
          <h4 class="text-sm font-medium text-gray-500">Estación</h4>
          <p class="mt-1 text-sm text-gray-900">{parsedData.estacion?.nombre || 'N/A'}</p>
        </div>
        <div class="md:col-span-2">
          <h4 class="text-sm font-medium text-gray-500">Fecha y hora</h4>
          <p class="mt-1 text-sm text-gray-900">{formatDate(parsedData.fecha)}</p>
        </div>
      </div>
    </div>

    <div class="flex flex-wrap gap-4">
      {#each parsedData.procesos as proceso}
        <div class="w-full sm:w-[calc(50%-0.5rem)] border border-gray-200 rounded-lg overflow-hidden">
          <ProgressTracker
            titulo={proceso.titulo}
            descripcion={proceso.descripcion}
            estadoProp={proceso.estado}
            subprocesos={proceso.subprocesos}
            pasoActual={proceso.pasoActual}
            totalPasos={proceso.totalPasos}
          />
        </div>
      {/each}
    </div>
  {:else}
    <div class="text-center py-8">
      <p class="text-gray-500">No hay datos disponibles</p>
    </div>
  {/if}
</div>
