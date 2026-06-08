-- =====================================================================
-- Script: CREATE TABLE tbHorarios
-- Descripción: Tabla consolidada de horarios escolares (reemplaza
--              tbHorarioAlumnos y tbHorarioProfesores)
-- Fecha: 2025-11-27
-- =====================================================================
-- Esta tabla representa una CLASE/SESIÓN académica con toda la información:
-- - Qué se enseña (Materia, Curso/Nivel)
-- - Quién lo enseña (Profesor)
-- - A quién se enseña (Sección)
-- - Dónde (Aula)
-- - Cuándo (Día, Hora, Semestre, Año)
-- =====================================================================

USE [DB_GestionColegial]
GO

-- Eliminar tabla si existe (solo para desarrollo)
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[app].[tbHorarios]') AND type in (N'U'))
BEGIN
    DROP TABLE [app].[tbHorarios]
    PRINT 'Tabla tbHorarios eliminada.'
END
GO

-- Crear tabla consolidada
CREATE TABLE [app].[tbHorarios]
(
    -- =====================================================================
    -- CLAVE PRIMARIA
    -- =====================================================================
    [Hor_Id] INT IDENTITY(1,1) NOT NULL,
    CONSTRAINT [PK_tbHorarios] PRIMARY KEY CLUSTERED ([Hor_Id] ASC),

    -- =====================================================================
    -- INFORMACIÓN ACADÉMICA (QUÉ SE ENSEÑA)
    -- =====================================================================
    [Cur_Id] INT NOT NULL,                  -- Curso (ej: Matemáticas)
    [Cun_Id] INT NOT NULL,                  -- Curso Nivel (ej: Nivel I, II, III)
    [Mat_Id] INT NOT NULL,                  -- Materia específica

    -- =====================================================================
    -- PARTICIPANTES (QUIÉN ENSEÑA Y A QUIÉN)
    -- =====================================================================
    [Emp_Id] INT NOT NULL,                  -- Profesor que imparte la clase
    [Sec_Id] INT NOT NULL,                  -- Sección (grupo de alumnos)

    -- =====================================================================
    -- UBICACIÓN (DÓNDE)
    -- =====================================================================
    [Aul_Id] INT NOT NULL,                  -- Aula donde se imparte

    -- =====================================================================
    -- TIEMPO (CUÁNDO)
    -- =====================================================================
    [Dia_Id] INT NOT NULL,                  -- Día de la semana (Lunes, Martes, etc.)
    [Hor_HoraInicio] INT NOT NULL,          -- Hora de inicio (FK a tbHoras)
    [Hor_HoraFinaliza] INT NOT NULL,        -- Hora de finalización (FK a tbHoras)

    -- =====================================================================
    -- CONTEXTO ACADÉMICO (PERÍODO)
    -- =====================================================================
    [Sem_Id] INT NOT NULL,                  -- Semestre (1er, 2do semestre)
    [Mda_Id] INT NULL,                      -- Modalidad (Presencial, Virtual, etc.) - Opcional
    [Hor_Año] INT NOT NULL,                 -- Año académico (2024, 2025, etc.)

    -- =====================================================================
    -- AUDITORÍA
    -- =====================================================================
    [Hor_UsuarioRegistra] INT NOT NULL,     -- Usuario que registró
    [Hor_FechaRegistra] DATETIME NOT NULL DEFAULT GETDATE(),
    [Hor_UsuarioModifica] INT NULL,         -- Usuario que modificó
    [Hor_FechaModifica] DATETIME NULL
);
GO

-- =====================================================================
-- FOREIGN KEYS (RELACIONES)
-- =====================================================================

-- FK: Curso
ALTER TABLE [app].[tbHorarios] WITH CHECK
ADD CONSTRAINT [FK_tbHorarios_tbCursos]
FOREIGN KEY([Cur_Id])
REFERENCES [app].[tbCursos] ([Cur_Id]);
GO

-- FK: Curso Nivel
ALTER TABLE [app].[tbHorarios] WITH CHECK
ADD CONSTRAINT [FK_tbHorarios_tbCursosNiveles]
FOREIGN KEY([Cun_Id])
REFERENCES [app].[tbCursosNiveles] ([Cun_Id]);
GO

-- FK: Materia
ALTER TABLE [app].[tbHorarios] WITH CHECK
ADD CONSTRAINT [FK_tbHorarios_tbMaterias]
FOREIGN KEY([Mat_Id])
REFERENCES [app].[tbMaterias] ([Mat_Id]);
GO

-- FK: Profesor (Empleado)
ALTER TABLE [app].[tbHorarios] WITH CHECK
ADD CONSTRAINT [FK_tbHorarios_tbEmpleados]
FOREIGN KEY([Emp_Id])
REFERENCES [app].[tbEmpleados] ([Emp_Id]);
GO

-- FK: Sección
ALTER TABLE [app].[tbHorarios] WITH CHECK
ADD CONSTRAINT [FK_tbHorarios_tbSecciones]
FOREIGN KEY([Sec_Id])
REFERENCES [app].[tbSecciones] ([Sec_Id]);
GO

-- FK: Aula
ALTER TABLE [app].[tbHorarios] WITH CHECK
ADD CONSTRAINT [FK_tbHorarios_tbAulas]
FOREIGN KEY([Aul_Id])
REFERENCES [app].[tbAulas] ([Aul_Id]);
GO

-- FK: Día
ALTER TABLE [app].[tbHorarios] WITH CHECK
ADD CONSTRAINT [FK_tbHorarios_tbDias]
FOREIGN KEY([Dia_Id])
REFERENCES [app].[tbDias] ([Dia_Id]);
GO

-- FK: Hora Inicio
ALTER TABLE [app].[tbHorarios] WITH CHECK
ADD CONSTRAINT [FK_tbHorarios_tbHoras_Inicio]
FOREIGN KEY([Hor_HoraInicio])
REFERENCES [app].[tbHoras] ([Hor_Id]);
GO

-- FK: Hora Finaliza
ALTER TABLE [app].[tbHorarios] WITH CHECK
ADD CONSTRAINT [FK_tbHorarios_tbHoras_Finaliza]
FOREIGN KEY([Hor_HoraFinaliza])
REFERENCES [app].[tbHoras] ([Hor_Id]);
GO

-- FK: Semestre
ALTER TABLE [app].[tbHorarios] WITH CHECK
ADD CONSTRAINT [FK_tbHorarios_tbSemestres]
FOREIGN KEY([Sem_Id])
REFERENCES [app].[tbSemestres] ([Sem_Id]);
GO

-- FK: Modalidad (opcional)
ALTER TABLE [app].[tbHorarios] WITH CHECK
ADD CONSTRAINT [FK_tbHorarios_tbModalidades]
FOREIGN KEY([Mda_Id])
REFERENCES [app].[tbModalidades] ([Mda_Id]);
GO

-- =====================================================================
-- ÍNDICES PARA MEJORAR RENDIMIENTO
-- =====================================================================

-- Índice para búsquedas por horario de alumnos (sección)
CREATE NONCLUSTERED INDEX [IX_tbHorarios_Seccion_Año_Sem_Dia]
ON [app].[tbHorarios]
(
    [Sec_Id] ASC,
    [Hor_Año] ASC,
    [Sem_Id] ASC,
    [Dia_Id] ASC,
    [Hor_HoraInicio] ASC
);
GO

-- Índice para búsquedas por horario de profesores
CREATE NONCLUSTERED INDEX [IX_tbHorarios_Profesor_Año_Sem_Dia]
ON [app].[tbHorarios]
(
    [Emp_Id] ASC,
    [Hor_Año] ASC,
    [Sem_Id] ASC,
    [Dia_Id] ASC,
    [Hor_HoraInicio] ASC
);
GO

-- Índice para detectar conflictos de aula (dos clases en misma aula/hora)
CREATE NONCLUSTERED INDEX [IX_tbHorarios_Aula_Año_Sem_Dia_Hora]
ON [app].[tbHorarios]
(
    [Aul_Id] ASC,
    [Hor_Año] ASC,
    [Sem_Id] ASC,
    [Dia_Id] ASC,
    [Hor_HoraInicio] ASC
);
GO

-- Índice para búsquedas por materia
CREATE NONCLUSTERED INDEX [IX_tbHorarios_Materia]
ON [app].[tbHorarios]
(
    [Mat_Id] ASC,
    [Hor_Año] ASC,
    [Sem_Id] ASC
);
GO

-- =====================================================================
-- RESTRICCIONES DE VALIDACIÓN
-- =====================================================================

-- Validar que la hora de finalización sea mayor que la de inicio
ALTER TABLE [app].[tbHorarios]
ADD CONSTRAINT [CHK_tbHorarios_Horas]
CHECK ([Hor_HoraFinaliza] > [Hor_HoraInicio]);
GO

-- Validar que el año sea razonable (entre 2020 y 2100)
ALTER TABLE [app].[tbHorarios]
ADD CONSTRAINT [CHK_tbHorarios_Año]
CHECK ([Hor_Año] >= 2020 AND [Hor_Año] <= 2100);
GO

-- =====================================================================
-- CONSTRAINT ÚNICO: Evitar duplicados
-- =====================================================================
-- Una sección no puede tener dos clases al mismo tiempo
CREATE UNIQUE NONCLUSTERED INDEX [UX_tbHorarios_Seccion_NoConflicto]
ON [app].[tbHorarios]
(
    [Sec_Id],
    [Hor_Año],
    [Sem_Id],
    [Dia_Id],
    [Hor_HoraInicio]
);
GO

-- Un profesor no puede tener dos clases al mismo tiempo
CREATE UNIQUE NONCLUSTERED INDEX [UX_tbHorarios_Profesor_NoConflicto]
ON [app].[tbHorarios]
(
    [Emp_Id],
    [Hor_Año],
    [Sem_Id],
    [Dia_Id],
    [Hor_HoraInicio]
);
GO

-- Un aula no puede tener dos clases al mismo tiempo
CREATE UNIQUE NONCLUSTERED INDEX [UX_tbHorarios_Aula_NoConflicto]
ON [app].[tbHorarios]
(
    [Aul_Id],
    [Hor_Año],
    [Sem_Id],
    [Dia_Id],
    [Hor_HoraInicio]
);
GO

PRINT '=====================================================================';
PRINT 'Tabla tbHorarios creada exitosamente.';
PRINT '';
PRINT 'Características:';
PRINT '  - 1 tabla consolidada (reemplaza tbHorarioAlumnos y tbHorarioProfesores)';
PRINT '  - 11 Foreign Keys';
PRINT '  - 4 Índices de búsqueda';
PRINT '  - 3 Índices únicos para evitar conflictos de horario';
PRINT '  - 2 Restricciones de validación (CHECK)';
PRINT '';
PRINT 'Próximos pasos:';
PRINT '  1. Ejecutar script de migración de datos';
PRINT '  2. Crear stored procedures';
PRINT '  3. Actualizar API y aplicación MVC';
PRINT '=====================================================================';
GO
