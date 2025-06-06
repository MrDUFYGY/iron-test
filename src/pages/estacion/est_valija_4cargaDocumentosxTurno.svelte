<script lang="ts">
  import PdfInputGroup from '../../components/customInput/PdfInputGroup.svelte';

  let activeTab = 1;

  // Estado de sellado por grupo
  let sealedGroups: Record<string, boolean> = {
    'mediciones-comprobantes': false,
    'Listado de tarjetas con Tag': false,
    'Listado de Contadores': false,
    'Listado de Open POS': false,
  };

  // Handler para el evento sealed
  function handleSealed(event: CustomEvent<{ groupId: string; sealed: boolean }>) {
    sealedGroups[event.detail.groupId] = event.detail.sealed;
  }
</script>

<div class="font-sans flex items-center justify-center max-w-4xl mx-auto">
  <div class="w-full">
    <div class="p-5 mx-auto">
      <div class="mb-4 flex space-x-4 p-2 bg-white rounded-lg shadow-md">
        <button
          on:click={() => activeTab = 1}
          class="flex-1 py-2 px-4 rounded-md focus:outline-none focus:shadow-outline-blue transition-all duration-300 {activeTab === 1 ? 'bg-blue-600 text-white' : ''} {sealedGroups['mediciones-comprobantes'] ? ' border-yellow-400 border-2' : ''}"
        >Mediciones Comprobantes</button>
        <button
          on:click={() => activeTab = 2}
          class="flex-1 py-2 px-4 rounded-md focus:outline-none focus:shadow-outline-blue transition-all duration-300 {activeTab === 2 ? 'bg-blue-600 text-white' : ''} {sealedGroups['Listado de tarjetas con Tag'] ? ' border-yellow-400 border-2' : ''}"
        >Listados Tag</button>
        <button
          on:click={() => activeTab = 3}
          class="flex-1 py-2 px-4 rounded-md focus:outline-none focus:shadow-outline-blue transition-all duration-300 {activeTab === 3 ? 'bg-blue-600 text-white' : ''} {sealedGroups['Listado de Contadores'] ? ' border-yellow-400 border-2' : ''}"
        >Listados Contadores</button>
        <button
          on:click={() => activeTab = 4}
          class="flex-1 py-2 px-4 rounded-md focus:outline-none focus:shadow-outline-blue transition-all duration-300 {activeTab === 4 ? 'bg-blue-600 text-white' : ''} {sealedGroups['Listado de Open POS'] ? ' border-yellow-400 border-2' : ''}"
        >Hojas OpenPOS</button>
      </div>

      {#if activeTab === 1}
        <h2 class="text-2xl font-semibold mb-2 text-blue-600">Listado de Mediciones con Comprobantes</h2>
        <PdfInputGroup
          groupId="mediciones-comprobantes"
          title="Mediciones y Comprobantes"
          on:sealed={handleSealed}
        />
      {/if}
      {#if activeTab === 2}
        <h2 class="text-2xl font-semibold mb-2 text-blue-600">Listado de tarjetas con Tag</h2>
        <PdfInputGroup
          groupId="Listado de tarjetas con Tag"
          title="Listado de tarjetas con Tag"
          on:sealed={handleSealed}
        />
      {/if}
      {#if activeTab === 3}
        <h2 class="text-2xl font-semibold mb-2 text-blue-600">Listado de Contadores</h2>
        <PdfInputGroup
          groupId="Listado de Contadores"
          title="Listado de Contadores"
          on:sealed={handleSealed}
        />
      {/if}
      {#if activeTab === 4}
        <h2 class="text-2xl font-semibold mb-2 text-blue-600">Listado de Open POS</h2>
        <PdfInputGroup
          groupId="Listado de Open POS"
          title="Listado de Open POS"
          on:sealed={handleSealed}
        />
      {/if}
    </div>
  </div>
</div>
