<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';

  export let inputId: string;
  export let label: string;
  export let isConfirmed = false;
  export let borderColor = 'border-green-500'; // Default to green, can be overridden

  const dispatch = createEventDispatcher<{
    pdfConfirmed: { inputId: string; file: File | null };
  }>();

  let dropArea: HTMLDivElement;
  let fileInput: HTMLInputElement;
  let isModalOpen = false;
  const staticPdfPath = '/assets/simulacion.pdf';

  function openModal() {
    isModalOpen = true;
    document.body.style.overflow = 'hidden';
  }

  function closeModal() {
    isModalOpen = false;
    document.body.style.overflow = 'auto';
  }

  function confirmSelection() {
    const file = fileInput.files?.[0] || null;
    isConfirmed = true;
    dispatch('pdfConfirmed', { inputId, file });
    closeModal();
  }

  function handleFileChange() {
    if (fileInput.files?.length) {
      openModal();
    }
  }

  onMount(() => {
    const handleDragOver = (e: DragEvent) => {
      e.preventDefault();
      dropArea.classList.add('border-blue-500', 'bg-blue-50');
    };

    const handleDragLeave = () => {
      dropArea.classList.remove('border-blue-500', 'bg-blue-50');
    };

    const handleDrop = (e: DragEvent) => {
      e.preventDefault();
      dropArea.classList.remove('border-blue-500', 'bg-blue-50');
      if (e.dataTransfer?.files?.length) {
        fileInput.files = e.dataTransfer.files;
        handleFileChange();
      }
    };

    dropArea.addEventListener('dragover', handleDragOver);
    dropArea.addEventListener('dragleave', handleDragLeave);
    dropArea.addEventListener('drop', handleDrop);
    dropArea.addEventListener('click', () => fileInput.click());

    return () => {
      dropArea.removeEventListener('dragover', handleDragOver);
      dropArea.removeEventListener('dragleave', handleDragLeave);
      dropArea.removeEventListener('drop', handleDrop);
      dropArea.removeEventListener('click', () => fileInput.click());
    };
  });
</script>

<div class="w-full">
  <label for={inputId} class="block text-sm font-medium text-gray-700 mb-2">
    {label}
  </label>
  
  <div
    bind:this={dropArea}
    class="rounded-lg p-6 text-center cursor-pointer bg-white hover:bg-blue-50 transition-colors border-2 border-dashed {isConfirmed ? borderColor : 'border-gray-300'}"
  >
    <svg class="mx-auto h-12 w-12 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 48 48">
      <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.01" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
    </svg>
    <p class="mt-2 text-gray-700">
      {isConfirmed ? 'Documento cargado' : 'Arrastra y suelta un archivo PDF o haz clic para seleccionar'}
    </p>
    <input
      bind:this={fileInput}
      type="file"
      accept=".pdf"
      class="hidden"
      id={inputId}
      on:change={handleFileChange}
    />
  </div>

  {#if isModalOpen}
    <div 
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4" 
      on:click|self={closeModal}
      tabindex="-1"
      on:keydown={(e) => e.key === 'Escape' && closeModal()}
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
    >
      <div class="bg-white rounded-lg shadow-xl w-full max-w-4xl max-h-[90vh] flex flex-col">
        <div class="px-6 py-4 border-b flex justify-between items-center">
          <h3 id="modal-title" class="text-lg font-semibold">Vista previa del documento</h3>
          <button
            type="button"
            on:click={closeModal}
            class="text-gray-500 hover:text-gray-700"
            aria-label="Cerrar"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        
        <div class="flex-1 overflow-auto p-6">
          <iframe
            src={staticPdfPath}
            class="w-full h-full min-h-[60vh] border rounded"
            title="Vista previa del documento"
          ></iframe>
        </div>
        
        <div class="px-6 py-4 border-t flex justify-end space-x-3">
          <button
            type="button"
            on:click={closeModal}
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded hover:bg-gray-200"
          >
            Cancelar
          </button>
          <button
            type="button"
            on:click={confirmSelection}
            class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded hover:bg-blue-700"
          >
            Confirmar selección
          </button>
        </div>
      </div>
    </div>
  {/if}
</div>
