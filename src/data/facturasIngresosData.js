// Get today's date in DD/MM/YYYY format
const today = new Date().toLocaleDateString('es-ES', {
  day: '2-digit',
  month: '2-digit',
  year: 'numeric'
});

// Track which ingresos have been used
export const usedIngresos = new Set();

export const facturasData = [
  {
    id: 1,
    numero: 'F2023-001',
    estado: 'pendiente', // 'pendiente' o 'justificado'
    fecha: today
  },
  {
    id: 2,
    numero: 'F2023-002',
    estado: 'pendiente',
    fecha: today,
    ingresoId: 2 // Referencia al ingreso relacionado
  },
  {
    id: 3,
    numero: 'F2023-003',
    estado: 'pendiente',
    fecha: today
  }
];

export const ingresosData = [
  {
    id: 1,
    fecha: today,
    numeroRemision: 'REM-001',
    numeroBomba: 'B-03',
    importe: '1,250.00 €',
    litros: '500.00 L',
    observaciones: 'Suministro normal - Turno mañana'
  },
  {
    id: 2,
    fecha: today,
    numeroRemision: 'REM-002',
    numeroBomba: 'B-05',
    importe: '980.50 €',
    litros: '392.20 L',
    observaciones: 'Pago con tarjeta - Cliente corporativo'
  },
  {
    id: 3,
    fecha: today,
    numeroRemision: 'REM-003',
    numeroBomba: 'B-02',
    importe: '1,500.00 €',
    litros: '600.00 L',
    observaciones: 'Suministro normal - Turno tarde'
  },
  {
    id: 4,
    fecha: today,
    numeroRemision: 'REM-004',
    numeroBomba: 'B-01',
    importe: '2,100.00 €',
    litros: '840.00 L',
    observaciones: 'Suministro para flota de transporte'
  },
  {
    id: 5,
    fecha: today,
    numeroRemision: 'REM-005',
    numeroBomba: 'B-04',
    importe: '1,750.50 €',
    litros: '700.20 L',
    observaciones: 'Cliente frecuente - Descuento aplicado',
    isUsed: false
  }
];
