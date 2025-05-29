-- =============================================
-- Tabla: Roles
-- Almacena los diferentes roles de usuarios del sistema
-- =============================================
CREATE TABLE Roles (
    RolID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(50) NOT NULL,
    Descripcion NVARCHAR(255) NULL,
    NivelAcceso INT NOT NULL DEFAULT 1, -- Para jerarquía de permisos (mayor número = más privilegios)
    Activo BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    FechaActualizacion DATETIME NULL,
    CONSTRAINT UQ_Roles_Nombre UNIQUE (Nombre)
);

-- Insertar roles básicos
INSERT INTO Roles (Nombre, Descripcion, NivelAcceso) VALUES 
('Administrador', 'Acceso completo al sistema', 100),
('Supervisor', 'Supervisa y valida procesos', 80),
('Verificador', 'Verifica y registra procesos', 50),
('Usuario', 'Acceso básico', 10);

-- =============================================
-- Tabla: Usuarios
-- Almacena la información de los usuarios del sistema
-- =============================================
CREATE TABLE Usuarios (
    UsuarioID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    ContraseñaHash NVARCHAR(255) NOT NULL,
    RolID INT NOT NULL,
    Activo BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    FechaUltimoAcceso DATETIME NULL,
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (RolID) REFERENCES Roles(RolID),
    CONSTRAINT UQ_Usuarios_Email UNIQUE (Email)
);

-- Insertar usuario administrador por defecto (contraseña: admin123)
INSERT INTO Usuarios (Nombre, Email, ContraseñaHash, RolID)
VALUES ('Administrador', 'admin@sistema.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1);

-- =============================================
-- Tabla: Procesos
-- Almacena los 12 procesos principales del sistema
-- =============================================
CREATE TABLE Procesos (
    ProcesoID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(500) NULL,
    Orden INT NOT NULL, -- Orden de visualización
    Activo BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    FechaActualizacion DATETIME NULL,
    CreadoPor INT NULL,
    ActualizadoPor INT NULL,
    CONSTRAINT FK_Procesos_Usuarios_Creador FOREIGN KEY (CreadoPor) REFERENCES Usuarios(UsuarioID),
    CONSTRAINT FK_Procesos_Usuarios_Actualizador FOREIGN KEY (ActualizadoPor) REFERENCES Usuarios(UsuarioID)
);

-- Insertar los 12 procesos principales
INSERT INTO Procesos (Nombre, Descripcion, Orden, CreadoPor) VALUES
('1. Hoja de Liquidación', 'Proceso de liquidación diaria', 1, 1),
('2. Movimientos de caja', 'Registro de movimientos financieros', 2, 1),
('3. Nóminas', 'Gestión de nóminas del personal', 3, 1),
('4. Listados de contadores, OpenPos y Mediciones', 'Registro de mediciones y contadores', 4, 1),
('5. Hojas de corte de periféricos', 'Control de cortes de periféricos', 5, 1),
('6. Recepción de carburantes con soportes', 'Control de entrada de combustibles', 6, 1),
('7. Listado de remisión de periféricos', 'Seguimiento de periféricos', 7, 1),
('8. Regularización de existencias (Mermas)', 'Control de inventario y mermas', 8, 1),
('9. Jarreo', 'Proceso de medición de tanques', 9, 1),
('10. Vales por empresa', 'Control de vales corporativos', 10, 1),
('11. Corte de terminales con vouchers', 'Conciliación de terminales', 11, 1),
('12. Lista de placas con tag', 'Control de vehículos con identificación', 12, 1);

-- =============================================
-- Tabla: Subprocesos
-- Almacena los subprocesos para cada proceso principal
-- =============================================
CREATE TABLE Subprocesos (
    SubprocesoID INT IDENTITY(1,1) PRIMARY KEY,
    ProcesoID INT NOT NULL,
    Nombre NVARCHAR(200) NOT NULL,
    Descripcion NVARCHAR(500) NULL,
    Orden INT NOT NULL, -- Orden dentro del proceso
    EsRequerido BIT DEFAULT 1,
    Activo BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    FechaActualizacion DATETIME NULL,
    CreadoPor INT NULL,
    ActualizadoPor INT NULL,
    CONSTRAINT FK_Subprocesos_Procesos FOREIGN KEY (ProcesoID) REFERENCES Procesos(ProcesoID) ON DELETE CASCADE,
    CONSTRAINT FK_Subprocesos_Usuarios_Creador FOREIGN KEY (CreadoPor) REFERENCES Usuarios(UsuarioID),
    CONSTRAINT FK_Subprocesos_Usuarios_Actualizador FOREIGN KEY (ActualizadoPor) REFERENCES Usuarios(UsuarioID)
);

-- Insertar subprocesos de ejemplo para el primer proceso
INSERT INTO Subprocesos (ProcesoID, Nombre, Descripcion, Orden, CreadoPor) VALUES
(1, 'Subida de Hoja Open Pos', 'Carga del archivo de caja', 1, 1),
(1, 'Comparación y confirmación', 'Verificación de montos', 2, 1);

-- =============================================
-- Tabla: RegistrosDiarios
-- Registro diario de actividades por usuario
-- =============================================
CREATE TABLE RegistrosDiarios (
    RegistroDiarioID INT IDENTITY(1,1) PRIMARY KEY,
    Fecha DATE NOT NULL,
    UsuarioID INT NOT NULL,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    FechaActualizacion DATETIME NULL,
    FechaCierre DATETIME NULL,
    EstadoGeneral NVARCHAR(20) DEFAULT 'pendiente', -- pendiente, en_progreso, completado, validado
    Comentarios NVARCHAR(1000) NULL,
    ValidadoPor INT NULL,
    FechaValidacion DATETIME NULL,
    CONSTRAINT FK_RegistrosDiarios_Usuarios FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID),
    CONSTRAINT FK_RegistrosDiarios_Validadores FOREIGN KEY (ValidadoPor) REFERENCES Usuarios(UsuarioID),
    CONSTRAINT CHK_EstadoGeneral CHECK (EstadoGeneral IN ('pendiente', 'en_progreso', 'completado', 'validado')),
    CONSTRAINT UQ_RegistroDiario_Usuario_Fecha UNIQUE (UsuarioID, Fecha)
);

-- =============================================
-- Tabla: DetalleRegistroDiario
-- Detalle de cada proceso dentro de un registro diario
-- =============================================
CREATE TABLE DetalleRegistroDiario (
    DetalleID INT IDENTITY(1,1) PRIMARY KEY,
    RegistroDiarioID INT NOT NULL,
    ProcesoID INT NOT NULL,
    Estado NVARCHAR(20) DEFAULT 'pendiente', -- pendiente, iniciado, sellado, validado, alertado
    FechaInicio DATETIME NULL,
    FechaFin DATETIME NULL,
    Validado BIT DEFAULT 0,
    Comentarios NVARCHAR(1000) NULL,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    FechaActualizacion DATETIME NULL,
    CONSTRAINT FK_DetalleRegistroDiario_RegistrosDiarios FOREIGN KEY (RegistroDiarioID) REFERENCES RegistrosDiarios(RegistroDiarioID) ON DELETE CASCADE,
    CONSTRAINT FK_DetalleRegistroDiario_Procesos FOREIGN KEY (ProcesoID) REFERENCES Procesos(ProcesoID),
    CONSTRAINT CHK_EstadoProceso CHECK (Estado IN ('pendiente', 'iniciado', 'sellado', 'validado', 'alertado')),
    CONSTRAINT UQ_RegistroProceso UNIQUE (RegistroDiarioID, ProcesoID)
);

-- =============================================
-- Tabla: DetalleSubprocesos
-- Seguimiento de cada subproceso completado
-- =============================================
CREATE TABLE DetalleSubprocesos (
    DetalleSubprocesoID INT IDENTITY(1,1) PRIMARY KEY,
    DetalleID INT NOT NULL,
    SubprocesoID INT NOT NULL,
    Completado BIT DEFAULT 0,
    FechaCompletado DATETIME NULL,
    Comentarios NVARCHAR(1000) NULL,
    ArchivoURL NVARCHAR(500) NULL, -- Ruta al archivo subido si aplica
    FechaCreacion DATETIME DEFAULT GETDATE(),
    UsuarioID INT NOT NULL, -- Usuario que completó el subproceso
    CONSTRAINT FK_DetalleSubprocesos_Detalle FOREIGN KEY (DetalleID) REFERENCES DetalleRegistroDiario(DetalleID) ON DELETE CASCADE,
    CONSTRAINT FK_DetalleSubprocesos_Subprocesos FOREIGN KEY (SubprocesoID) REFERENCES Subprocesos(SubprocesoID),
    CONSTRAINT FK_DetalleSubprocesos_Usuarios FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID),
    CONSTRAINT UQ_Detalle_Subproceso UNIQUE (DetalleID, SubprocesoID)
);

-- =============================================
-- Tabla: HistorialCambios
-- Registro de auditoría para todos los cambios importantes
-- =============================================
CREATE TABLE HistorialCambios (
    HistorialID INT IDENTITY(1,1) PRIMARY KEY,
    TablaAfectada NVARCHAR(50) NOT NULL,
    IDRegistro INT NOT NULL,
    Accion NVARCHAR(20) NOT NULL, -- INSERT, UPDATE, DELETE
    CampoModificado NVARCHAR(50) NOT NULL,
    ValorAnterior NVARCHAR(MAX) NULL,
    ValorNuevo NVARCHAR(MAX) NULL,
    UsuarioID INT NOT NULL,
    FechaCambio DATETIME DEFAULT GETDATE(),
    DireccionIP NVARCHAR(45) NULL,
    UserAgent NVARCHAR(500) NULL,
    CONSTRAINT FK_HistorialCambios_Usuarios FOREIGN KEY (UsuarioID) REFERENCES Usuarios(UsuarioID)
);

-- Índices para mejorar el rendimiento de las consultas de auditoría
CREATE INDEX IX_HistorialCambios_TablaID ON HistorialCambios(TablaAfectada, IDRegistro);
CREATE INDEX IX_HistorialCambios_Fecha ON HistorialCambios(FechaCambio);
CREATE INDEX IX_HistorialCambios_Usuario ON HistorialCambios(UsuarioID);

-- =============================================
-- Tabla: ConfiguracionEstados
-- Configuración visual de los estados del sistema
-- =============================================
CREATE TABLE ConfiguracionEstados (
    ConfiguracionID INT IDENTITY(1,1) PRIMARY KEY,
    Estado NVARCHAR(20) NOT NULL, -- pendiente, iniciado, sellado, validado, alertado
    ColorFondo NVARCHAR(20) NOT NULL,
    ColorTexto NVARCHAR(20) NOT NULL,
    Icono NVARCHAR(50) NULL,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    FechaActualizacion DATETIME NULL,
    CONSTRAINT UQ_ConfiguracionEstados_Estado UNIQUE (Estado)
);

-- Insertar configuración de estados
INSERT INTO ConfiguracionEstados (Estado, ColorFondo, ColorTexto, Icono)
VALUES 
('pendiente', 'bg-blue-100', 'text-blue-800', 'pending'),
('iniciado', 'bg-blue-100', 'text-blue-800', 'in_progress'),
('sellado', 'bg-yellow-100', 'text-yellow-800', 'seal'),
('validado', 'bg-green-100', 'text-green-800', 'check_circle'),
('alertado', 'bg-red-100', 'text-red-800', 'warning');

-- =============================================
-- Vistas útiles
-- =============================================

-- Vista para obtener el resumen de procesos por usuario y fecha
CREATE OR ALTER VIEW vw_ResumenProcesos AS
SELECT 
    rd.RegistroDiarioID,
    rd.Fecha,
    u.UsuarioID,
    u.Nombre AS NombreUsuario,
    r.Nombre AS Rol,
    p.ProcesoID,
    p.Nombre AS NombreProceso,
    p.Orden AS OrdenProceso,
    drd.Estado,
    drd.FechaInicio,
    drd.FechaFin,
    drd.Validado,
    ce.ColorFondo,
    ce.ColorTexto,
    ce.Icono,
    (SELECT COUNT(*) FROM Subprocesos s WHERE s.ProcesoID = p.ProcesoID) AS TotalSubprocesos,
    (SELECT COUNT(*) FROM DetalleSubprocesos ds 
     INNER JOIN Subprocesos s ON ds.SubprocesoID = s.SubprocesoID 
     WHERE ds.DetalleID = drd.DetalleID AND ds.Completado = 1) AS SubprocesosCompletados
FROM 
    RegistrosDiarios rd
INNER JOIN 
    Usuarios u ON rd.UsuarioID = u.UsuarioID
INNER JOIN 
    Roles r ON u.RolID = r.RolID
INNER JOIN 
    DetalleRegistroDiario drd ON rd.RegistroDiarioID = drd.RegistroDiarioID
INNER JOIN 
    Procesos p ON drd.ProcesoID = p.ProcesoID
LEFT JOIN 
    ConfiguracionEstados ce ON drd.Estado = ce.Estado;

-- =============================================
-- Procedimientos almacenados
-- =============================================

-- Procedimiento para crear un nuevo registro diario
CREATE OR ALTER PROCEDURE sp_CrearRegistroDiario
    @UsuarioID INT,
    @Fecha DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Si no se proporciona fecha, usar la fecha actual
    IF @Fecha IS NULL
        SET @Fecha = CAST(GETDATE() AS DATE);
    
    -- Verificar si ya existe un registro para este usuario en la fecha
    IF EXISTS (SELECT 1 FROM RegistrosDiarios WHERE UsuarioID = @UsuarioID AND Fecha = @Fecha)
    BEGIN
        RAISERROR('Ya existe un registro para este usuario en la fecha especificada.', 16, 1);
        RETURN -1;
    END
    
    DECLARE @RegistroDiarioID INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Crear el registro diario
        INSERT INTO RegistrosDiarios (Fecha, UsuarioID, EstadoGeneral)
        VALUES (@Fecha, @UsuarioID, 'pendiente');
        
        SET @RegistroDiarioID = SCOPE_IDENTITY();
        
        -- Insertar los procesos pendientes
        INSERT INTO DetalleRegistroDiario (RegistroDiarioID, ProcesoID, Estado)
        SELECT @RegistroDiarioID, ProcesoID, 'pendiente'
        FROM Procesos
        WHERE Activo = 1;
        
        COMMIT TRANSACTION;
        
        SELECT @RegistroDiarioID AS RegistroDiarioID;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -1;
    END CATCH;
END;

-- =============================================
-- Índices adicionales para mejorar el rendimiento
-- =============================================

-- Índice para búsquedas por fecha en RegistrosDiarios
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_RegistrosDiarios_Fecha')
    CREATE INDEX IX_RegistrosDiarios_Fecha ON RegistrosDiarios(Fecha);

-- Índice para búsquedas por usuario en RegistrosDiarios
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_RegistrosDiarios_UsuarioID')
    CREATE INDEX IX_RegistrosDiarios_UsuarioID ON RegistrosDiarios(UsuarioID);

-- Índice para búsquedas por proceso en DetalleRegistroDiario
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DetalleRegistroDiario_ProcesoID')
    CREATE INDEX IX_DetalleRegistroDiario_ProcesoID ON DetalleRegistroDiario(ProcesoID);

-- Índice para búsquedas por estado en DetalleRegistroDiario
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_DetalleRegistroDiario_Estado')
    CREATE INDEX IX_DetalleRegistroDiario_Estado ON DetalleRegistroDiario(Estado);

PRINT 'Esquema de base de datos creado exitosamente con todos los objetos necesarios.';