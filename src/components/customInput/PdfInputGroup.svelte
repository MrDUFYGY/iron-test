<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import CustomPdfInput from './CustomPdfInput.svelte';

  export let groupId: string;
  export let title: string;
  export let isSealed = false; // Control sealed state from parent
  
  const inputs = [
    { id: 1, label: 'Turno 1' },
    { id: 2, label: 'Turno 2' },
    { id: 3, label: 'Turno 3' }
  ];

  const inputStates = new Map();
  let allConfirmed = false;
  let showSealModal = false;
  const borderColor = 'border-yellow-400';
  
  // Set all inputs to soloConsulta mode when sealed
  $: if (isSealed) {
    inputs.forEach(input => {
      const inputId = `${groupId}-turno-${input.id}`;
      inputStates.set(inputId, { 
        ...inputStates.get(inputId), 
        soloConsulta: true 
      });
    });
  }

  const dispatch = createEventDispatcher<{
    sealed: { groupId: string; sealed: boolean };
  }>();

  function handlePdfConfirmed(event: CustomEvent) {
    const { inputId, file } = event.detail;
    inputStates.set(inputId, { 
      ...inputStates.get(inputId),
      confirmed: true, 
      file 
    });
    checkAllConfirmed();
  }

  function checkAllConfirmed() {
    allConfirmed = inputs.every(input => 
      inputStates.get(`${groupId}-turno-${input.id}`)?.confirmed
    );
  }

  function handleSeal() {
    showSealModal = true;
  }

  function confirmSeal() {
    showSealModal = false;
    dispatch('sealed', { groupId, sealed: true });
  }

  function cancelSeal() {
    showSealModal = false;
  }
</script>

<div class="pdf-input-group p-4 rounded-md mb-6 shadow-md border-2 {isSealed ? borderColor : 'border-gray-200'} transition-colors duration-300">
  <h2 class="text-xl font-semibold mb-4 text-gray-700">{title}</h2>
  <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
    {#each inputs as input (input.id)}
      <CustomPdfInput
        inputId={`${groupId}-turno-${input.id}`}
        label={input.label}
        on:pdfConfirmed={handlePdfConfirmed}
        isConfirmed={inputStates.get(`${groupId}-turno-${input.id}`)?.confirmed || false}
        soloConsulta={inputStates.get(`${groupId}-turno-${input.id}`)?.soloConsulta || isSealed}
        {borderColor}
      />
    {/each}
  </div>
  
  {#if !isSealed}
    <button 
      class="w-full px-6 py-3 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-colors duration-150 ease-in-out mb-2"
      disabled={!allConfirmed}
      on:click={handleSeal}
    >
      Sellar
    </button>
  {/if}
  
  {#if showSealModal}
    <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4" 
         on:click|self={cancelSeal}
         on:keydown={(e) => e.key === 'Escape' && cancelSeal()}
         role="dialog"
         tabindex="-1"
         aria-modal="true"
         aria-labelledby="seal-modal-title">
      <div class="bg-white rounded-lg shadow-xl w-full max-w-6xl max-h-[90vh] flex flex-col">
        <div class="px-6 py-4 border-b flex justify-between items-center">
          <h3 id="seal-modal-title" class="text-lg font-semibold">Confirmar Sellado de Documentos</h3>
          <button
            type="button"
            on:click={cancelSeal}
            class="text-gray-500 hover:text-gray-700"
            aria-label="Cerrar"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        
        <div class="flex-1 overflow-auto p-6 grid grid-cols-1 md:grid-cols-3 gap-4">
          {#each inputs as input (input.id)}
            <div class="border rounded-lg overflow-hidden h-96">
              <h4 class="text-center p-2 bg-gray-100 font-medium">{input.label}</h4>
              <iframe
                src="/assets/simulacion.pdf"
                class="w-full h-full"
                title={`Vista previa ${input.label}`}
              ></iframe>
            </div>
          {/each}
        </div>
        
        <div class="px-6 py-4 border-t flex justify-end space-x-3">
          <button
            type="button"
            on:click={cancelSeal}
            class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded hover:bg-gray-200"
          >
            Cancelar
          </button>
          <button
            type="button"
            on:click={confirmSeal}
            class="px-4 py-2 text-sm font-medium text-white bg-yellow-500 rounded hover:bg-yellow-600"
          >
            Sellar los 3 turnos
          </button>
        </div>
      </div>
    </div>
  {/if}
</div>
