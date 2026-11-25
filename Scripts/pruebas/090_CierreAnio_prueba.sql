/* =============================================================================
   Prueba del script 090 (cierre del año escolar). Todo corre dentro de UNA transacción que termina
   en ROLLBACK: no deja datos. Crea los años 2030 y 2031 de prueba con dos secciones (octavo y noveno),
   siete alumnos existentes, notas de los cuatro parciales publicados y los horarios mínimos; luego
   inicia el cierre, calcula, registra recuperaciones, decide, confirma, cierra y revisa el resultado.
   Lista las fallas y al final imprime "090 prueba: N fallas".
   Requiere que no existan los años 2030 ni 2031 y que existan los alumnos 96-99 (octavo A) y
   189-191 (noveno A) de los datos de demostración.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
IF EXISTS (SELECT 1 FROM app.tbAnioLectivo WHERE Ani_Anio IN (2030, 2031))
BEGIN
    PRINT '090 prueba: ya existen los años 2030 o 2031; no se corre.';
    RETURN;
END
DECLARE @Fallas TABLE (Caso nvarchar(200));
DECLARE @Dir int = (SELECT TOP (1) Usu_Id FROM seguridad.tbUsuarios WHERE Rol_Id = 1002 AND ISNULL(Usu_EsEliminado, 0) = 0 ORDER BY Usu_Id);
DECLARE @Swallow TABLE (a int NULL, b int NULL, c varchar(20) NULL, d bit NULL);

BEGIN TRANSACTION;

/* ───────────── Datos del año de prueba ───────────── */
INSERT INTO app.tbAnioLectivo (Ani_Anio, Ani_Nombre, Ani_FechaInicio, Ani_FechaFin, Ani_Estado, Ani_EsActivo, Ani_EsEliminado, Ani_UsuarioRegistra)
VALUES (2030, 'PRUEBA cierre 2030', '2030-02-01', '2030-11-30', 3, 1, 0, 1),
       (2031, 'PRUEBA 2031', '2031-02-01', '2031-11-30', 1, 1, 0, 1);
DECLARE @A30 int = (SELECT Ani_Id FROM app.tbAnioLectivo WHERE Ani_Anio = 2030);
DECLARE @A31 int = (SELECT Ani_Id FROM app.tbAnioLectivo WHERE Ani_Anio = 2031);

INSERT INTO app.tbSeccionesAnio (Ani_Id, Niv_Id, Cun_Id, Sec_Id, Mda_Id, Emp_Id, Sea_Nombre, Sea_Cupo, Sea_Estado, Sea_EsEliminado, Sea_UsuarioRegistra)
VALUES (@A30, 1, 2, 1, 1, 4,    'PRUEBA Octavo A', 35, 3, 0, 1),
       (@A30, 1, 3, 1, 1, NULL, 'PRUEBA Noveno A', 35, 3, 0, 1),
       (@A31, 1, 3, 1, 1, NULL, 'PRUEBA 2031 Noveno A', 35, 1, 0, 1),
       (@A31, 1, 2, 1, 1, NULL, 'PRUEBA 2031 Octavo A', 35, 1, 0, 1);
DECLARE @S8 int = (SELECT Sea_Id FROM app.tbSeccionesAnio WHERE Ani_Id = @A30 AND Cun_Id = 2);
DECLARE @S9 int = (SELECT Sea_Id FROM app.tbSeccionesAnio WHERE Ani_Id = @A30 AND Cun_Id = 3);

INSERT INTO app.tbMatriculaAnio (Alu_Id, Ani_Id, Sea_Id, Mta_Estado, Mta_EsEliminado, Mta_UsuarioRegistra)
SELECT v.Alu_Id, @A30, CASE WHEN v.Alu_Id < 150 THEN @S8 ELSE @S9 END, 1, 0, 1
FROM (VALUES (96), (97), (98), (99), (189), (190), (191)) v (Alu_Id);

-- Tres materias por sección, tomadas del horario 2026 de esas secciones.
DECLARE @M TABLE (Grupo int, Mat_Id int, Orden int);
INSERT INTO @M
SELECT 8, Mat_Id, ROW_NUMBER() OVER (ORDER BY Mat_Id)
FROM (SELECT DISTINCT Mat_Id FROM app.tbHorarios WHERE Hor_Año = 2026 AND Cur_Id = 2 AND Cun_Id = 2 AND Sec_Id = 1 AND Mda_Id = 1 AND ISNULL(Hor_EsEliminado, 0) = 0) x;
INSERT INTO @M
SELECT 9, Mat_Id, ROW_NUMBER() OVER (ORDER BY Mat_Id)
FROM (SELECT DISTINCT Mat_Id FROM app.tbHorarios WHERE Hor_Año = 2026 AND Cur_Id = 3 AND Cun_Id = 3 AND Sec_Id = 1 AND Mda_Id = 1 AND ISNULL(Hor_EsEliminado, 0) = 0) x;
DELETE FROM @M WHERE Orden > 3;

INSERT INTO app.tbHorarios (Cur_Id, Cun_Id, Mat_Id, Emp_Id, Sec_Id, Aul_Id, Dia_Id, Hor_HoraInicio, Hor_HoraFinaliza, Sem_Id, Mda_Id, Hor_Año, Hor_EsEliminado, Hor_UsuarioRegistra, Hor_FechaRegistra)
SELECT h.Cur_Id, h.Cun_Id, h.Mat_Id, h.Emp_Id, h.Sec_Id, h.Aul_Id, h.Dia_Id, h.Hor_HoraInicio, h.Hor_HoraFinaliza, h.Sem_Id, h.Mda_Id, 2030, 0, 1, GETDATE()
FROM @M m
CROSS APPLY (SELECT TOP (1) * FROM app.tbHorarios x
             WHERE x.Hor_Año = 2026 AND ISNULL(x.Hor_EsEliminado, 0) = 0 AND x.Mat_Id = m.Mat_Id AND x.Sec_Id = 1 AND x.Mda_Id = 1
               AND x.Cun_Id = CASE m.Grupo WHEN 8 THEN 2 ELSE 3 END AND x.Cur_Id = CASE m.Grupo WHEN 8 THEN 2 ELSE 3 END AND x.Sem_Id = 1
             ORDER BY x.Hor_Id) h;

DECLARE @N TABLE (Alu_Id int, Orden int, Nota int, Nota2 int);
INSERT INTO @N VALUES
 (96, 1, 85, 85), (96, 2, 90, 90), (96, 3, 80, 80),     -- aprueba todo: promovido
 (97, 1, 85, 85), (97, 2, 64, 64), (97, 3, 80, 80),     -- 1 reprobada: recuperación
 (98, 1, 60, 60), (98, 2, 62, 62), (98, 3, 80, 80),     -- 2 reprobadas: recuperación (máximo 2)
 (99, 1, 50, 50), (99, 2, 55, 55), (99, 3, 60, 60),     -- 3 reprobadas: repite
 (189, 1, 90, 90), (189, 2, 88, 88), (189, 3, 92, 92),  -- último grado: se gradúa
 (190, 1, 75, 75), (190, 2, 72, 72), (190, 3, 69, 70),  -- 69,5 se redondea a 70: aprueba
 (191, 1, 65, 65), (191, 2, 80, 80), (191, 3, 85, 85);  -- 1 reprobada: recuperación

INSERT INTO app.tbNotas (Alu_Id, Aul_Id, Sec_Id, Not_Nota, Mat_Id, Sem_Id, Pac_Id, Not_Año, Not_EsActivo, Not_EsEliminado, Not_UsuarioRegistra, Not_FechaRegistra)
SELECT n.Alu_Id, h.Aul_Id, 1, CASE WHEN p.Pac_Id = 1 THEN n.Nota ELSE n.Nota2 END, m.Mat_Id, p.Sem_Id, p.Pac_Id,
       DATEFROMPARTS(2030, CASE p.Sem_Id WHEN 1 THEN 3 ELSE 8 END, 1), 1, 0, 1, GETDATE()
FROM @N n
INNER JOIN @M m ON m.Grupo = CASE WHEN n.Alu_Id < 150 THEN 8 ELSE 9 END AND m.Orden = n.Orden
CROSS JOIN (VALUES (1, 1), (1, 2), (2, 1), (2, 2)) p (Sem_Id, Pac_Id)
CROSS APPLY (SELECT TOP (1) Aul_Id FROM app.tbHorarios WHERE Hor_Año = 2030 AND Mat_Id = m.Mat_Id) h;

INSERT INTO app.tbCierresParcial (Cpa_Anio, Sem_Id, Pac_Id, Cpa_Estado, Cpa_FechaCierre, Usu_IdCierre, Cpa_Publicado, Cpa_FechaPublicacion, Usu_IdPublicacion, Cpa_UsuarioRegistra)
SELECT 2030, s.Sem_Id, p.Pac_Id, 'cerrado', GETDATE(), 1, 1, GETDATE(), 1, 1
FROM (VALUES (1), (2)) s (Sem_Id) CROSS JOIN (VALUES (1), (2)) p (Pac_Id);

/* ───────────── 1. Revisión con el año abierto ───────────── */
IF NOT EXISTS (SELECT 1 FROM app.FN_CierreAnio_Revision(@A30) WHERE Clave = 'resultados' AND Nivel = 'bloquea')
    INSERT @Fallas VALUES ('revision: resultados debe bloquear');
IF EXISTS (SELECT 1 FROM app.FN_CierreAnio_Revision(@A30) WHERE Grupo = 'antes' AND Nivel = 'bloquea')
    INSERT @Fallas VALUES ('revision: nada de "antes" debe bloquear');

/* ───────────── 2. Iniciar, calcular y clasificar (70 y hasta 2 en recuperación) ───────────── */
INSERT @Swallow (a, b, c, d) EXEC app.PR_CierreAnio_CambiarEstado @Ani_Id = @A30, @Accion = 'iniciar', @Usuario = @Dir, @PuedeCerrar = 1;
IF (SELECT Ani_Estado FROM app.tbAnioLectivo WHERE Ani_Id = @A30) <> 4 INSERT @Fallas VALUES ('iniciar: el año debe quedar en Cerrando');
DECLARE @Calc TABLE (Alumnos int, Materias int, Parciales int, Aprobadas int, EnRecuperacion int, Reprobadas int, SinNotas int);
INSERT @Calc EXEC app.PR_CierreAnio_Calcular @A30, @Dir, 1;
IF NOT EXISTS (SELECT 1 FROM @Calc WHERE Alumnos = 7 AND Materias = 21 AND Parciales = 4 AND EnRecuperacion = 4 AND Reprobadas = 3)
    INSERT @Fallas VALUES ('calcular: 7 alumnos, 21 materias, 4 en recuperación y 3 reprobadas');
IF NOT EXISTS (SELECT 1 FROM app.tbResultadosAnio WHERE Ani_Id = @A30 AND Alu_Id = 190 AND Rea_Promedio = 69.5 AND Rea_NotaFinal = 70 AND Rea_Resultado = 'aprobado')
    INSERT @Fallas VALUES ('redondeo: 69,5 queda en 70 y aprueba');
IF ISNULL((SELECT Pra_Propuesta FROM app.tbPromocionesAnio WHERE Ani_Id = @A30 AND Alu_Id = 96), '') <> 'promovido'
   OR ISNULL((SELECT Pra_Propuesta FROM app.tbPromocionesAnio WHERE Ani_Id = @A30 AND Alu_Id = 99), '') <> 'repite'
   OR ISNULL((SELECT Pra_Propuesta FROM app.tbPromocionesAnio WHERE Ani_Id = @A30 AND Alu_Id = 189), '') <> 'gradua'
   OR ISNULL((SELECT Pra_Propuesta FROM app.tbPromocionesAnio WHERE Ani_Id = @A30 AND Alu_Id = 98), '') <> 'pendiente'
    INSERT @Fallas VALUES ('propuestas: 96 promovido, 99 repite, 189 se gradúa, 98 pendiente');

/* ───────────── 3. Recuperaciones ───────────── */
DECLARE @Rea int, @Rea97 int;
DECLARE @Rec TABLE (Rea_Id int, Resultado varchar(12), NotaFinal decimal(5,2), AproboRecuperacion bit, Propuesta varchar(12));
SELECT @Rea97 = Rea_Id FROM app.tbResultadosAnio WHERE Ani_Id = @A30 AND Alu_Id = 97 AND Rea_Resultado = 'recuperacion';
INSERT @Rec EXEC app.PR_CierreAnio_Recuperacion @Rea97, 75, @Dir, 1;
SELECT @Rea = Rea_Id FROM app.tbResultadosAnio WHERE Ani_Id = @A30 AND Alu_Id = 191 AND Rea_Resultado = 'recuperacion';
INSERT @Rec EXEC app.PR_CierreAnio_Recuperacion @Rea, 80, @Dir, 1;
SELECT TOP (1) @Rea = Rea_Id FROM app.tbResultadosAnio WHERE Ani_Id = @A30 AND Alu_Id = 98 AND Rea_Resultado = 'recuperacion' ORDER BY Rea_Id;
INSERT @Rec EXEC app.PR_CierreAnio_Recuperacion @Rea, 72, @Dir, 1;
IF ISNULL((SELECT Pra_Propuesta FROM app.tbPromocionesAnio WHERE Ani_Id = @A30 AND Alu_Id = 97), '') <> 'promovido'
   OR ISNULL((SELECT Pra_Propuesta FROM app.tbPromocionesAnio WHERE Ani_Id = @A30 AND Alu_Id = 191), '') <> 'gradua'
   OR ISNULL((SELECT Pra_Propuesta FROM app.tbPromocionesAnio WHERE Ani_Id = @A30 AND Alu_Id = 98), '') <> 'pendiente'
    INSERT @Fallas VALUES ('recuperación: 97 promovido, 191 se gradúa, 98 sigue pendiente');
IF ISNULL((SELECT Rea_NotaFinal FROM app.tbResultadosAnio WHERE Rea_Id = @Rea97), 0) <> 75
    INSERT @Fallas VALUES ('recuperación aprobada: la nota final es la de la recuperación');

/* ───────────── 4. Decisión de Dirección y confirmación de las secciones ───────────── */
DECLARE @Pra int = (SELECT Pra_Id FROM app.tbPromocionesAnio WHERE Ani_Id = @A30 AND Alu_Id = 98);
DECLARE @Dec TABLE (Pra_Id int, Propuesta varchar(12), Decision varchar(12), Efectiva varchar(12));
INSERT @Dec EXEC app.PR_CierreAnio_Decidir @Pra, 'repite', N'Prueba: no se presentó a la segunda recuperación.', @Dir, 1;
-- (ConfirmarSeccion usa INSERT ... EXEC por dentro: se llama directo y se revisan las tablas.)
EXEC app.PR_CierreAnio_ConfirmarSeccion @A30, @S8, @Dir, 1;
EXEC app.PR_CierreAnio_ConfirmarSeccion @A30, @S9, @Dir, 1;
IF (SELECT COUNT(*) FROM app.tbPromocionesAnio WHERE Ani_Id = @A30 AND Pra_Confirmada = 1) <> 7
    INSERT @Fallas VALUES ('confirmar: las 7 decisiones quedan confirmadas');
IF (SELECT COUNT(*) FROM app.tbMatriculaAnio WHERE Ani_Id = @A31 AND Mta_EsEliminado = 0) <> 4
    INSERT @Fallas VALUES ('confirmar: 2 promovidos y 2 repitentes inscritos en 2031 (los graduados no)');
IF (SELECT COUNT(*) FROM app.tbMatriculaAnio m JOIN app.tbSeccionesAnio s ON s.Sea_Id = m.Sea_Id
    WHERE m.Ani_Id = @A31 AND m.Mta_EsEliminado = 0 AND ((m.Alu_Id IN (96, 97) AND s.Cun_Id = 3) OR (m.Alu_Id IN (98, 99) AND s.Cun_Id = 2))) <> 4
    INSERT @Fallas VALUES ('2031: promovidos en noveno y repitentes en octavo');
IF (SELECT COUNT(*) FROM app.tbMatriculaAnio WHERE Ani_Id = @A30 AND Mta_Estado = 5) <> 3
    INSERT @Fallas VALUES ('matrícula 2030: 3 graduados');
IF (SELECT COUNT(*) FROM app.vCandidatosGraduacion WHERE Alu_Id IN (189, 190, 191) AND NotasOk = 1) <> 3
    INSERT @Fallas VALUES ('graduación: la decisión confirmada deja las notas en regla');

/* ───────────── 5. Cerrar: solo lectura y el editor común no le cambia el estado ───────────── */
INSERT @Swallow (a, b, c, d) EXEC app.PR_CierreAnio_CambiarEstado @Ani_Id = @A30, @Accion = 'cerrar', @Usuario = @Dir, @PuedeCerrar = 1;
IF (SELECT Ani_Estado FROM app.tbAnioLectivo WHERE Ani_Id = @A30) <> 5 INSERT @Fallas VALUES ('cerrar: el año debe quedar Cerrado');
IF app.FN_AnioLectivo_SoloLectura(2030) <> 1 INSERT @Fallas VALUES ('solo lectura: 2030');
IF app.FN_AnioLectivo_SoloLectura(2031) <> 0 INSERT @Fallas VALUES ('solo lectura: 2031 sigue editable');
IF app.FN_Evaluacion_Cerrado(2030, 1, 1) <> 1 INSERT @Fallas VALUES ('cuaderno: el parcial de un año cerrado se ve cerrado');
IF NOT EXISTS (SELECT 1 FROM app.tbAnioLectivoHistorial WHERE Ani_Id = @A30 AND Alh_Accion = 'cerrar' AND Alh_Revision IS NOT NULL)
    INSERT @Fallas VALUES ('historial: el cierre guarda la revisión');
EXEC app.PR_tbAnioLectivo_Update @Ani_Id = @A30, @Ani_Anio = 2030, @Ani_Nombre = 'PRUEBA cierre 2030', @Ani_Estado = 3, @Ani_UsuarioModifica = @Dir;
IF (SELECT Ani_Estado FROM app.tbAnioLectivo WHERE Ani_Id = @A30) <> 5 INSERT @Fallas VALUES ('editar el año no lo reabre');

ROLLBACK TRANSACTION;

SELECT Caso AS FALLA FROM @Fallas;
DECLARE @Total int = (SELECT COUNT(*) FROM @Fallas);
PRINT CONCAT('090 prueba: ', @Total, ' fallas');
