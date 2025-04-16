<script>
  import { onMount } from 'svelte';

  let usuarios = [];
  let nuevoNombre = '';
  let editandoId = null;
  let nombreEditado = '';

  // Cargar usuarios al montar
  onMount(() => {
    listarUsuarios();
  });

  async function listarUsuarios() {
    const res = await fetch('/ApiHandler/UsuariosApi.ashx?accion=listar');
    usuarios = await res.json();
  }

  async function agregarUsuario() {
    if (!nuevoNombre.trim()) return;

    const res = await fetch(`/ApiHandler/UsuariosApi.ashx?accion=crear&nombre=${encodeURIComponent(nuevoNombre)}`);
    const nuevo = await res.json();
    usuarios.push(nuevo);
    nuevoNombre = '';
  }

  async function eliminarUsuario(id) {
    await fetch(`/ApiHandler/UsuariosApi.ashx?accion=eliminar&id=${id}`);
    usuarios = usuarios.filter(u => u.Id !== id);
  }

  function iniciarEdicion(usuario) {
    editandoId = usuario.Id;
    nombreEditado = usuario.Nombre;
  }

  async function guardarEdicion(id) {
    await fetch(`/ApiHandler/UsuariosApi.ashx?accion=editar&id=${id}&nombre=${encodeURIComponent(nombreEditado)}`);
    const usuario = usuarios.find(u => u.Id === id);
    if (usuario) usuario.Nombre = nombreEditado;
    editandoId = null;
    nombreEditado = '';
  }

  function cancelarEdicion() {
    editandoId = null;
    nombreEditado = '';
  }
</script>

<h2>Usuarios</h2>

<input bind:value={nuevoNombre} placeholder="Nuevo nombre" />
<button on:click={agregarUsuario}>Agregar</button>

<ul>
  {#each usuarios as usuario}
    <li>
      {#if editandoId === usuario.Id}
        <input bind:value={nombreEditado} />
        <button on:click={() => guardarEdicion(usuario.Id)}>Guardar</button>
        <button on:click={cancelarEdicion}>Cancelar</button>
      {:else}
        {usuario.Nombre}
        <button on:click={() => iniciarEdicion(usuario)}>Editar</button>
        <button on:click={() => eliminarUsuario(usuario.Id)}>Eliminar</button>
      {/if}
    </li>
  {/each}
</ul>
