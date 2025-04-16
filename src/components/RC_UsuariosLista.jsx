import React, { useEffect, useState } from 'react';

export default function UsuariosLista() {
  const [usuarios, setUsuarios] = useState([]);

  useEffect(() => {
    fetch('https://localhost:44376/ApiHandler/UsuariosApi.ashx?accion=listar')
      .then(res => res.json())
      .then(data => setUsuarios(data))
      .catch(err => console.error("Error:", err));
  }, []);

  return (
    <div>
      <h2>Usuarios</h2>
      {usuarios.length > 0 ? (
        <ul>
          {usuarios.map((u, i) => (
            <li key={i}>{u.Nombre}</li> // Asegúrate de que la propiedad sea correcta
          ))}
        </ul>
      ) : (
        <p>Cargando...</p>
      )}
    </div>
  );
}
