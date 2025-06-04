<script>
  import { onMount } from 'svelte';
  export let inputTitle = 'Subir PDF';
export let componentId = 'pdfinput_' + Math.random().toString(36).substring(2, 10);
export let confirmado = false; // Nuevo prop para el borde

let marca1Confirmada = false;
let marca2Confirmada = false;
let fileElem;
let dropArea;
let marca1;
let estado1;
let marca2;
let estado2;
let modal;
let modalViewer;

const staticPdfPath = '/assets/simulacion.pdf';

function abrirModalPdf() {
    modalViewer.src = staticPdfPath;
    modal.classList.remove('hidden');
    modal.classList.add('flex');
    document.body.style.overflow = 'hidden';
  }
  function cerrarModalPdf() {
    modal.classList.add('hidden');
    modal.classList.remove('flex');
    modalViewer.src = '';
    document.body.style.overflow = 'auto';
  }
  function confirmar() {
  marca1Confirmada = true;
  // Marca 2 permanece igual
  cerrarModalPdf();
  // Si quieres actualizar el prop confirmado desde dentro, descomenta:
  // confirmado = true;
}

  onMount(() => {
  // Drag & Drop
  ['dragenter', 'dragover'].forEach(eventName => {
    dropArea.addEventListener(eventName, e => {
      e.preventDefault();
      dropArea.classList.add('border-blue-500', 'bg-blue-50');
    });
  });
  ['dragleave', 'drop'].forEach(eventName => {
    dropArea.addEventListener(eventName, e => {
      e.preventDefault();
      dropArea.classList.remove('border-blue-500', 'bg-blue-50');
    });
  });
  dropArea.addEventListener('drop', e => {
    e.preventDefault();
    if (e.dataTransfer.files && e.dataTransfer.files.length > 0) {
      abrirModalPdf();
    }
  });
  // Click para seleccionar archivo
  dropArea.addEventListener('click', () => fileElem.click());
  fileElem.addEventListener('change', e => {
    if (fileElem.files && fileElem.files.length > 0) {
      abrirModalPdf();
    }
  });
  // Estado inicial marcas
  marca1Confirmada = confirmado;
  marca2Confirmada = false;
});
</script>

<div class="w-full max-w-md mx-auto">
  <label class="block text-sm font-medium text-gray-700 mb-2">{inputTitle}</label>
  <!-- Área de input drag-and-drop + marcas -->
  <div
    bind:this={dropArea}
    class="border-2 border-dashed rounded-lg p-8 text-center cursor-pointer bg-white hover:bg-blue-50 transition-colors flex flex-col items-center gap-4"
    style="border-color: {confirmado || marca1Confirmada ? '#16a34a' : '#9ca3af'}; border-width: 2px; border-style: dashed;"
  >
    <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 48 48">
      <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.01" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
    </svg>
    <p class="mt-2 text-gray-700">Arrastra y suelta un archivo aquí o haz clic para seleccionar</p>
    <input bind:this={fileElem} type="file" accept=".pdf" class="hidden" />
    <!-- Marcas -->
    <div class="flex flex-col gap-2 mt-4 w-full items-center">
      <div class="flex items-center space-x-2">
        <span class="w-4 h-4 rounded-full border-2 transition-colors"
          style="background: {marca1Confirmada ? '#22c55e' : '#d1d5db'}; border-color: {marca1Confirmada ? '#16a34a' : '#9ca3af'}"
        ></span>
        <span class="text-gray-700">Marca 1: <span class="font-semibold">{marca1Confirmada ? 'Confirmado' : 'Pendiente'}</span></span>
      </div>
      <div class="flex items-center space-x-2">
        <span class="w-4 h-4 rounded-full border-2 transition-colors"
          style="background: {marca2Confirmada ? '#22c55e' : '#d1d5db'}; border-color: {marca2Confirmada ? '#16a34a' : '#9ca3af'}"
        ></span>
        <span class="text-gray-700">Marca 2: <span class="font-semibold">{marca2Confirmada ? 'Confirmado' : 'Pendiente'}</span></span>
      </div>
    </div>
  </div>

  <!-- Modal PDF -->
  <div bind:this={modal} class="fixed inset-0 bg-black bg-opacity-50 hidden flex items-center justify-center z-50 p-4">
    <div class="bg-white rounded-lg p-6 max-w-2xl w-full max-h-[90vh] flex flex-col">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-lg font-semibold">Vista previa del documento</h3>
        <button class="text-gray-500 hover:text-gray-700 focus:outline-none" on:click={cerrarModalPdf}>
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
      <div class="border rounded-lg overflow-hidden mb-4 bg-gray-100 flex-grow">
        <iframe bind:this={modalViewer} class="w-full h-full min-h-[50vh] border-0" src=""></iframe>
      </div>
      <div class="flex justify-end gap-4 pt-4 border-t">
        <button class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500" on:click={cerrarModalPdf}>Cancelar</button>
        <button class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500" on:click={confirmar}>Confirmar</button>
      </div>
    </div>
  </div>
</div>

<style>
  .flex { display: flex; }
  .hidden { display: none; }
  .transition-colors { transition: background 0.3s, border 0.3s; }
</style>
