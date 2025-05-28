<script lang="ts">
  import { onMount } from 'svelte';
  import ProgressTracker from './ProgressTracker.svelte';
  
  type Proceso = {
    titulo: string;
    descripcion: string;
    estado: 'pendiente' | 'iniciado' | 'sellado' | 'validado' | 'alertado';
    subprocesos: Record<string, boolean>;
    pasoActual?: number;
    totalPasos?: number;
  };

  type ProcesosData = {
    usuario: {
      nombre: string;
      [key: string]: any;
    };
    fecha: string;
    estacion: {
      nombre: string;
      [key: string]: any;
    };
    procesos: Proceso[];
  };

  // Internal state
  let isOpen = false;
  export let data: string | ProcesosData | null = null;
  
  // Parse data if it's a string and calculate progress
  $: parsedData = (() => {
    const dataObj = typeof data === 'string' ? JSON.parse(data) : data;
    if (!dataObj?.procesos) return dataObj;
    
    // Process each proceso to calculate pasoActual based on subprocesos
    const procesosActualizados = dataObj.procesos.map((proceso: Proceso) => {
      if (!proceso.subprocesos) return proceso;
      
      const subprocesos = Object.entries(proceso.subprocesos);
      const totalSubprocesos = subprocesos.length;
      
      // Find the index of the last true subprocess (1-based index)
      let ultimoCompletado = 0;
      Object.entries(proceso.subprocesos).forEach(([_, completado], index) => {
        if (completado) ultimoCompletado = index + 1;
      });
      
      return {
        ...proceso,
        pasoActual: ultimoCompletado,
        totalPasos: totalSubprocesos
      };
    });
    
    return {
      ...dataObj,
      procesos: procesosActualizados
    };
  })();
  
  // Button props
  export let buttonText = 'Ver Resumen Completo';
  export let buttonClass = 'w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-md transition-colors flex items-center justify-center gap-2 mt-4';
  
  // Toggle modal visibility
  function toggleModal() {
    isOpen = !isOpen;
  }
  
  function closeModal() {
    isOpen = false;
  }

  // Generar un ID único para el modal
  const modalId = `resumen-procesos-${Math.random().toString(36).substr(2, 9)}`;

  // Handle Escape key to close modal
  onMount(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) {
        closeModal();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  });

  // Función para manejar la impresión
  function handlePrint() {
    const printContents = document.getElementById('printable-content');
    if (!printContents) return;
    
    const printWindow = window.open('', '_blank');
    if (!printWindow) return;
    
    printWindow.document.write(`
      <!DOCTYPE html>
      <html>
        <head>
          <title>Resumen de Procesos</title>
          <script src="https://cdn.tailwindcss.com"><\/script>
          <style>
            @media print {
              @page { margin: 0.5cm; }
              body { -webkit-print-color-adjust: exact; }
              .no-print { display: none !important; }
            }
          <\/style>
        </head>
        <body class="p-4">
          ${printContents.outerHTML}
          <script>
            window.onload = function() {
              setTimeout(function() {
                window.print();
                window.onafterprint = function() {
                  window.close();
                };
              }, 200);
            };
          <\/script>
        </body>
      </html>
    `);
    printWindow.document.close();
  }

  // Formatear fecha
  const formatDate = (dateString: string) => {
    const options: Intl.DateTimeFormatOptions = { 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    };
    return new Date(dateString).toLocaleDateString('es-MX', options);
  };
</script>

<!-- Trigger Button -->
<div class="relative z-10">
  <button 
    on:click={toggleModal}
    class="{buttonClass}"
    aria-expanded="false"
    aria-controls={modalId}
  >
    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
    </svg>
    {buttonText}
  </button>
</div>

<!-- Modal -->
{#if isOpen}
  <div 
    id={modalId}
    class="fixed inset-0 z-[9999] overflow-y-auto"
    aria-labelledby="modal-title"
    role="dialog"
    aria-modal="true"
    style="background-color: rgba(0, 0, 0, 0.5); position: fixed; top: 0; left: 0; right: 0; bottom: 0; z-index: 9999;"
  >
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <!-- Fondo oscuro -->
      <div 
        class="fixed inset-0 bg-gray-900 bg-opacity-75 transition-opacity" 
        aria-hidden="true"
        on:click={closeModal}
      ></div>

      <!-- Contenido del modal -->
      <span class="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
      
      <div class="relative inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-4xl w-full z-[10000] max-h-[90vh] overflow-y-auto">
        <div id="printable-content" class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
          <div class="sm:flex sm:items-start">
            <div class="mt-3 text-center sm:mt-0 sm:text-left w-full">
              <div class="flex justify-between items-center mb-4">
                <h3 class="text-lg leading-6 font-medium text-gray-900" id="modal-title">
                  Resumen de Procesos
                </h3>
                <div class="flex items-center space-x-2">
                  <button 
                    type="button" 
                    class="p-1 text-gray-600 hover:text-gray-900 focus:outline-none"
                    on:click={handlePrint}
                    title="Imprimir"
                    aria-label="Imprimir resumen"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z" />
                    </svg>
                  </button>
                  <button 
                    type="button" 
                    class="p-1 text-gray-400 hover:text-gray-500 focus:outline-none"
                    on:click={closeModal}
                    title="Cerrar"
                    aria-label="Cerrar modal"
                  >
                    <span class="sr-only">Cerrar</span>
                    <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                </div>
              </div>

              {#if parsedData}
                <!-- Información del encabezado -->
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

                <!-- Lista de procesos -->
                <div class="space-y-4">
                  {#each parsedData.procesos as proceso}
                    <div class="border border-gray-200 rounded-lg overflow-hidden">
                      <ProgressTracker
                        titulo={proceso.titulo}
                        descripcion={proceso.descripcion}
                        estado={proceso.estado}
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
          </div>
        </div>
        <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
          <button
            type="button"
            class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-blue-600 text-base font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:ml-3 sm:w-auto sm:text-sm"
            on:click={closeModal}
          >
            Cerrar
          </button>
        </div>
      </div>
    </div>
  </div>
{/if}
