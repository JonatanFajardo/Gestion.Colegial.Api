/* =============================================================================
   Prueba del script 089 (notas ponderadas). Todo corre dentro de transacciones que terminan en
   ROLLBACK: no deja datos. Cada caso imprime OK o FALLA; al final, "089 prueba: N fallas".
   Usa el primer horario del año actual con 9 alumnos activos o más, un usuario admin y uno Docente.
   La salida "##JSON##..." es el cuaderno calculado que compara la prueba del JavaScript.

   Casos: tipo sin nada calificado (su peso se reparte), todo excusado (sin nota), NE = 0, "no cuenta",
   suma / promedio / mejor, redondeo en el límite (1/3 x 30 y 79,495), puntos mayores que el máximo,
   nota escrita en app.tbNotas en la misma transacción, recálculo al cambiar pesos sin tocar parciales
   cerrados ni notas de otros años, nota directa bloqueada, alcance del docente y parcial cerrado.
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET NOCOUNT ON;
GO

/* ───────────── 1. Cálculo, notas del parcial y recálculo por cambio de pesos ───────────── */
DECLARE @Fallas TABLE (Caso nvarchar(200));
DECLARE @Anio int = app.FN_Temario_AnioActual(), @Hor int, @Sem int, @Sec int, @Mat int, @Cur int, @Cun int, @Niv int;
SELECT TOP (1) @Hor = g.Hor_Id
FROM (SELECT MIN(h.Hor_Id) AS Hor_Id, h.Sec_Id, h.Cur_Id, h.Cun_Id
      FROM app.tbHorarios h WHERE h.Hor_Año = @Anio AND ISNULL(h.Hor_EsEliminado, 0) = 0
      GROUP BY h.Sem_Id, h.Sec_Id, h.Mat_Id, h.Cur_Id, h.Cun_Id) g
WHERE (SELECT COUNT(*) FROM app.FN_Evaluacion_Alumnos(@Anio, g.Sec_Id, g.Cur_Id, g.Cun_Id)) >= 9
ORDER BY g.Hor_Id;
SELECT @Sem = Sem_Id, @Sec = Sec_Id, @Mat = Mat_Id, @Cur = Cur_Id, @Cun = Cun_Id, @Niv = Niv_Id FROM app.FN_Evaluacion_Horario(@Hor);
DECLARE @Admin int = (SELECT TOP (1) u.Usu_Id FROM seguridad.tbUsuarios u JOIN seguridad.tbRoles r ON r.Rol_Id = u.Rol_Id
                      WHERE LOWER(LTRIM(RTRIM(r.Rol_Descripcion))) = 'admin' AND ISNULL(u.Usu_EsEliminado, 0) = 0 ORDER BY u.Usu_Id);
DECLARE @Pac int = 2, @PacCerrado int = 1;   -- parcial abierto y parcial que se cierra dentro de la prueba
PRINT CONCAT('Grupo: horario ', @Hor, ' (año ', @Anio, ', semestre ', @Sem, ', sección ', @Sec, ', materia ', @Mat, ')');

DECLARE @S TABLE (N int IDENTITY(1,1), Alu_Id int);
INSERT INTO @S (Alu_Id) SELECT TOP (9) Alu_Id FROM app.FN_Evaluacion_Alumnos(@Anio, @Sec, @Cur, @Cun) ORDER BY Alu_Id;
DECLARE @S1 int = (SELECT Alu_Id FROM @S WHERE N = 1), @S2 int = (SELECT Alu_Id FROM @S WHERE N = 2),
        @S3 int = (SELECT Alu_Id FROM @S WHERE N = 3), @S4 int = (SELECT Alu_Id FROM @S WHERE N = 4),
        @S5 int = (SELECT Alu_Id FROM @S WHERE N = 5), @S6 int = (SELECT Alu_Id FROM @S WHERE N = 6),
        @S7 int = (SELECT Alu_Id FROM @S WHERE N = 7), @S8 int = (SELECT Alu_Id FROM @S WHERE N = 8),
        @S9 int = (SELECT Alu_Id FROM @S WHERE N = 9);

DECLARE @R TABLE (Id int, Cev_Id int, Cantidad int, Omitidas int, NotasEscritas int);
DECLARE @RP TABLE (Id int, Version int, Sincronizados int, Conservados int, Cantidad int, Omitidas int, NotasEscritas int);
DECLARE @J TABLE (Json nvarchar(max));

BEGIN TRANSACTION;

-- Notas de antes (para ver qué no se tocó)
DECLARE @Antes TABLE (Alu_Id int, Pac_Id int, Nota int);
INSERT INTO @Antes SELECT s.Alu_Id, p.Pac_Id,
       (SELECT TOP (1) n.Not_Nota FROM app.tbNotas n WHERE n.Alu_Id = s.Alu_Id AND n.Sec_Id = @Sec AND n.Mat_Id = @Mat AND n.Pac_Id = p.Pac_Id
          AND n.Sem_Id = @Sem AND YEAR(n.Not_Año) = @Anio AND n.Not_EsEliminado = 0 ORDER BY n.Not_Id DESC)
FROM @S s CROSS JOIN (VALUES (@Pac), (@PacCerrado)) p (Pac_Id);
-- Nota del año anterior del mismo alumno, materia y parcial: no se debe tocar
INSERT INTO app.tbNotas (Alu_Id, Aul_Id, Sec_Id, Mat_Id, Sem_Id, Pac_Id, Not_Nota, Not_Año, Not_EsActivo, Not_EsEliminado, Not_UsuarioRegistra, Not_FechaRegistra)
VALUES (@S1, NULL, @Sec, @Mat, @Sem, @Pac, 55, DATEFROMPARTS(@Anio - 1, 1, 1), 1, 0, @Admin, GETDATE());
DECLARE @NotaOtroAnio int = SCOPE_IDENTITY();
-- Parciales abiertos al empezar
UPDATE app.tbCierresParcial SET Cpa_Estado = 'abierto' WHERE Cpa_Anio = @Anio AND Sem_Id = @Sem AND Pac_Id IN (@Pac, @PacCerrado);

-- Plantilla de la materia y el nivel del grupo (gana a la del año): suma 60, promedio 30, mejor 10
INSERT INTO @RP EXEC app.PR_Evaluacion_GuardarPlantilla @Ple_Id = NULL, @Anio = @Anio, @Niv_Id = @Niv, @Mat_Id = @Mat,
     @Nombre = N'Prueba 089', @Descripcion = NULL,
     @Tipos = N'[{"id":0,"n":"Acumulativo","p":60,"c":"suma"},{"id":0,"n":"Tareas","p":30,"c":"promedio"},{"id":0,"n":"Examen","p":10,"c":"mejor"}]',
     @Version = NULL, @Usuario = @Admin;
DECLARE @Ple int = (SELECT Id FROM @RP);
DECLARE @P1 int = (SELECT Plt_Id FROM app.tbPlantillasEvaluacionTipos WHERE Ple_Id = @Ple AND Plt_Nombre = N'Acumulativo');
IF app.FN_Evaluacion_PlantillaDe(@Anio, @Niv, @Mat) <> @Ple INSERT INTO @Fallas VALUES (N'La plantilla de materia y nivel no es la que se aplica');

-- Actividades (la primera crea el cuaderno con los tipos de la plantilla)
INSERT INTO @R EXEC app.PR_Evaluacion_GuardarActividad @Hor_Id = @Hor, @Pac_Id = @Pac, @Plt_Id = @P1, @Nombre = N'Trabajo 1', @PuntosMax = 60, @Usuario = @Admin;
DECLARE @Cev int = (SELECT TOP (1) Cev_Id FROM @R), @A1 int = (SELECT TOP (1) Id FROM @R);
DECLARE @T1 int = (SELECT Cet_Id FROM app.tbCuadernosEvaluacionTipos WHERE Cev_Id = @Cev AND Cet_Nombre = N'Acumulativo'),
        @T2 int = (SELECT Cet_Id FROM app.tbCuadernosEvaluacionTipos WHERE Cev_Id = @Cev AND Cet_Nombre = N'Tareas'),
        @T3 int = (SELECT Cet_Id FROM app.tbCuadernosEvaluacionTipos WHERE Cev_Id = @Cev AND Cet_Nombre = N'Examen');
DELETE FROM @R;
INSERT INTO @R EXEC app.PR_Evaluacion_GuardarActividad @Hor_Id = @Hor, @Pac_Id = @Pac, @Cet_Id = @T1, @Nombre = N'Proyecto', @PuntosMax = 200, @Usuario = @Admin;
DECLARE @A2 int = (SELECT Id FROM @R); DELETE FROM @R;
INSERT INTO @R EXEC app.PR_Evaluacion_GuardarActividad @Hor_Id = @Hor, @Pac_Id = @Pac, @Cet_Id = @T1, @Nombre = N'Práctica libre', @PuntosMax = 100, @NoCuenta = 1, @Usuario = @Admin;
DECLARE @A5 int = (SELECT Id FROM @R); DELETE FROM @R;
INSERT INTO @R EXEC app.PR_Evaluacion_GuardarActividad @Hor_Id = @Hor, @Pac_Id = @Pac, @Cet_Id = @T2, @Nombre = N'Tarea 1', @PuntosMax = 10, @Usuario = @Admin;
DECLARE @A3a int = (SELECT Id FROM @R); DELETE FROM @R;
INSERT INTO @R EXEC app.PR_Evaluacion_GuardarActividad @Hor_Id = @Hor, @Pac_Id = @Pac, @Cet_Id = @T2, @Nombre = N'Tarea 2', @PuntosMax = 10, @Usuario = @Admin;
DECLARE @A3b int = (SELECT Id FROM @R); DELETE FROM @R;
INSERT INTO @R EXEC app.PR_Evaluacion_GuardarActividad @Hor_Id = @Hor, @Pac_Id = @Pac, @Cet_Id = @T2, @Nombre = N'Tarea 3', @PuntosMax = 10, @Usuario = @Admin;
DECLARE @A3c int = (SELECT Id FROM @R); DELETE FROM @R;
INSERT INTO @R EXEC app.PR_Evaluacion_GuardarActividad @Hor_Id = @Hor, @Pac_Id = @Pac, @Cet_Id = @T3, @Nombre = N'Examen', @PuntosMax = 20, @Usuario = @Admin;
DECLARE @A4a int = (SELECT Id FROM @R); DELETE FROM @R;
INSERT INTO @R EXEC app.PR_Evaluacion_GuardarActividad @Hor_Id = @Hor, @Pac_Id = @Pac, @Cet_Id = @T3, @Nombre = N'Recuperación', @PuntosMax = 20, @Usuario = @Admin;
DECLARE @A4b int = (SELECT Id FROM @R); DELETE FROM @R;

-- Con actividades la nota directa queda bloqueada (para insertar y para editar)
DECLARE @U TABLE (UsaActividades bit);
INSERT INTO @U EXEC app.PR_Evaluacion_UsaActividades @Hor, @Pac;
IF ISNULL((SELECT UsaActividades FROM @U), 0) = 0 INSERT INTO @Fallas VALUES (N'UsaActividades no marca el parcial');
DELETE FROM @U;
DECLARE @NotaDirecta int = (SELECT TOP (1) n.Not_Id FROM app.tbNotas n WHERE n.Alu_Id = @S3 AND n.Sec_Id = @Sec AND n.Mat_Id = @Mat
                            AND n.Pac_Id = @Pac AND n.Sem_Id = @Sem AND YEAR(n.Not_Año) = @Anio AND n.Not_EsEliminado = 0);
IF @NotaDirecta IS NOT NULL
BEGIN
    INSERT INTO @U EXEC app.PR_Evaluacion_UsaActividadesNota @NotaDirecta;
    IF ISNULL((SELECT UsaActividades FROM @U), 0) = 0 INSERT INTO @Fallas VALUES (N'UsaActividadesNota no marca la nota del parcial');
END

-- Puntos: [actividad, alumno, estado, puntos]
DECLARE @Celdas TABLE (a int, u int, e varchar(12), p decimal(9,2));
INSERT INTO @Celdas VALUES
 -- S1: todo calificado (suma, promedio y mejor) + "no cuenta" con 100
 (@A1, @S1, 'calificado', 48), (@A2, @S1, 'calificado', 150), (@A3a, @S1, 'calificado', 8), (@A3b, @S1, 'calificado', 9),
 (@A3c, @S1, 'calificado', 10), (@A4a, @S1, 'calificado', 12), (@A4b, @S1, 'calificado', 18), (@A5, @S1, 'calificado', 100),
 -- S2: examen sin calificar -> su 10 % se reparte entre los otros dos
 (@A1, @S2, 'calificado', 30), (@A3a, @S2, 'calificado', 10), (@A3b, @S2, 'calificado', 10), (@A3c, @S2, 'calificado', 10),
 -- S3: todo excusado -> sin nota
 (@A1, @S3, 'excusado', NULL), (@A2, @S3, 'excusado', NULL), (@A3a, @S3, 'excusado', NULL), (@A4a, @S3, 'excusado', NULL),
 -- S4: NE cuenta 0
 (@A1, @S4, 'no_entrego', NULL), (@A2, @S4, 'calificado', 100), (@A3a, @S4, 'no_entrego', NULL), (@A3b, @S4, 'calificado', 5),
 (@A3c, @S4, 'calificado', 10), (@A4a, @S4, 'no_entrego', NULL),
 -- S5: solo una actividad que no cuenta + excusado -> sin nota
 (@A5, @S5, 'calificado', 100), (@A1, @S5, 'excusado', NULL),
 -- S6: límite con 1/3: (30,95 + 1/3 x 30) / 90 x 100 = 45,5 exacto -> 46
 (@A1, @S6, 'calificado', 30.95), (@A3a, @S6, 'calificado', 10), (@A3b, @S6, 'calificado', 0), (@A3c, @S6, 'calificado', 0),
 -- S7: 158,99 / 200 = 79,495 -> 79,50 -> 80
 (@A2, @S7, 'calificado', 158.99),
 -- S8: la mejor de examen y recuperación
 (@A4a, @S8, 'calificado', 10), (@A4b, @S8, 'calificado', 18),
 -- S9: excusado y vacío en el mismo tipo no cuentan
 (@A3a, @S9, 'excusado', NULL), (@A3b, @S9, 'calificado', 6);
DECLARE @Json nvarchar(max) = (SELECT a, u, e, p, 0 AS v FROM @Celdas FOR JSON PATH, INCLUDE_NULL_VALUES);
INSERT INTO @R EXEC app.PR_Evaluacion_GuardarPuntos @Cev_Id = @Cev, @Puntos = @Json, @Usuario = @Admin;
IF (SELECT Cantidad FROM @R) <> (SELECT COUNT(*) FROM @Celdas) INSERT INTO @Fallas VALUES (N'GuardarPuntos no guardó todas las celdas');
DELETE FROM @R;

-- Esperado
DECLARE @E TABLE (Caso nvarchar(60), Alu_Id int, Nota decimal(6,2), Entera int);
INSERT INTO @E VALUES
 (N'S1 suma, promedio, mejor y no cuenta', @S1, 81.69, 82), (N'S2 tipo sin calificar se reparte', @S2, 66.67, 67),
 (N'S3 todo excusado', @S3, NULL, NULL), (N'S4 NE = 0', @S4, 38.08, 38), (N'S5 solo no cuenta', @S5, NULL, NULL),
 (N'S6 límite 1/3 (45,5)', @S6, 45.50, 46), (N'S7 límite 79,495', @S7, 79.50, 80), (N'S8 mejor', @S8, 90.00, 90),
 (N'S9 excusado y vacío', @S9, 60.00, 60);
INSERT INTO @Fallas
SELECT CONCAT(N'Cálculo ', e.Caso, N': esperaba ', ISNULL(CAST(e.Nota AS nvarchar(10)), N'sin nota'), N'/', e.Entera,
              N' y salió ', ISNULL(CAST(k.Nota AS nvarchar(10)), N'sin nota'), N'/', k.Entera)
FROM @E e LEFT JOIN app.FN_Evaluacion_Calculo(@Cev) k ON k.Alu_Id = e.Alu_Id
WHERE ISNULL(k.Nota, -1) <> ISNULL(e.Nota, -1) OR ISNULL(k.Entera, -1) <> ISNULL(e.Entera, -1);

-- La nota entera quedó en app.tbNotas (misma transacción); sin nota calculada no se toca la que había
INSERT INTO @Fallas
SELECT CONCAT(N'tbNotas ', e.Caso, N': esperaba ', ISNULL(CAST(ISNULL(e.Entera, a.Nota) AS nvarchar(10)), N'sin nota'), N' y hay ', ISNULL(CAST(n.Not_Nota AS nvarchar(10)), N'sin nota'))
FROM @E e
JOIN @Antes a ON a.Alu_Id = e.Alu_Id AND a.Pac_Id = @Pac
OUTER APPLY (SELECT TOP (1) x.Not_Nota FROM app.tbNotas x WHERE x.Alu_Id = e.Alu_Id AND x.Sec_Id = @Sec AND x.Mat_Id = @Mat AND x.Pac_Id = @Pac
             AND x.Sem_Id = @Sem AND YEAR(x.Not_Año) = @Anio AND x.Not_EsEliminado = 0 ORDER BY x.Not_Id DESC) n
WHERE ISNULL(n.Not_Nota, -1) <> ISNULL(ISNULL(e.Entera, a.Nota), -1);
IF EXISTS (SELECT 1 FROM app.tbNotas x JOIN @E e ON e.Alu_Id = x.Alu_Id
           WHERE x.Sec_Id = @Sec AND x.Mat_Id = @Mat AND x.Pac_Id = @Pac AND x.Sem_Id = @Sem AND YEAR(x.Not_Año) = @Anio
             AND x.Not_EsEliminado = 0 AND e.Entera IS NOT NULL AND x.Not_Nota <> e.Entera)
    INSERT INTO @Fallas VALUES (N'Una fila repetida de nota quedó con otro valor');

-- Cuaderno para la prueba del JavaScript
INSERT INTO @J EXEC app.PR_Evaluacion_Cuaderno @Hor, @Pac, @Admin;
SELECT CONCAT(N'##JSON##', Json) FROM @J;

-- Parcial que se cierra: cuaderno con 10/20 en examen para S1 (= 50), luego se cierra
INSERT INTO @R EXEC app.PR_Evaluacion_GuardarActividad @Hor_Id = @Hor, @Pac_Id = @PacCerrado, @Plt_Id = @P1, @Nombre = N'Examen B', @PuntosMax = 20, @Usuario = @Admin;
DECLARE @CevB int = (SELECT Cev_Id FROM @R), @AB int = (SELECT Id FROM @R); DELETE FROM @R;
SET @Json = CONCAT(N'[{"a":', @AB, N',"u":', @S1, N',"e":"calificado","p":10,"v":0}]');
INSERT INTO @R EXEC app.PR_Evaluacion_GuardarPuntos @Cev_Id = @CevB, @Puntos = @Json, @Usuario = @Admin;
DELETE FROM @R;
IF EXISTS (SELECT 1 FROM app.tbCierresParcial WHERE Cpa_Anio = @Anio AND Sem_Id = @Sem AND Pac_Id = @PacCerrado)
    UPDATE app.tbCierresParcial SET Cpa_Estado = 'cerrado' WHERE Cpa_Anio = @Anio AND Sem_Id = @Sem AND Pac_Id = @PacCerrado;
ELSE
    INSERT INTO app.tbCierresParcial (Cpa_Anio, Sem_Id, Pac_Id, Cpa_Estado, Cpa_Publicado, Cpa_UsuarioRegistra, Cpa_FechaRegistra)
    VALUES (@Anio, @Sem, @PacCerrado, 'cerrado', 0, @Admin, GETDATE());

-- Cambio de pesos: 50 / 40 / 10. El abierto se recalcula; el cerrado conserva pesos y notas.
DECLARE @Tipos nvarchar(max) = (SELECT t.Plt_Id AS id, t.Plt_Nombre AS n,
                                       CASE t.Plt_Nombre WHEN N'Acumulativo' THEN 50 WHEN N'Tareas' THEN 40 ELSE 10 END AS p, t.Plt_Combinacion AS c
                                FROM app.tbPlantillasEvaluacionTipos t WHERE t.Ple_Id = @Ple AND t.Plt_EsEliminado = 0 ORDER BY t.Plt_Orden FOR JSON PATH);
DECLARE @VerPle int = (SELECT Ple_Version FROM app.tbPlantillasEvaluacion WHERE Ple_Id = @Ple);
DELETE FROM @RP;
INSERT INTO @RP EXEC app.PR_Evaluacion_GuardarPlantilla @Ple_Id = @Ple, @Anio = @Anio, @Niv_Id = @Niv, @Mat_Id = @Mat, @Nombre = N'Prueba 089',
     @Tipos = @Tipos, @Version = @VerPle, @Usuario = @Admin;
IF (SELECT Sincronizados FROM @RP) <> 1 OR (SELECT Conservados FROM @RP) <> 1
    INSERT INTO @Fallas VALUES (N'Recálculo: esperaba 1 cuaderno actualizado y 1 conservado (cerrado)');
IF (SELECT Cet_Peso FROM app.tbCuadernosEvaluacionTipos WHERE Cev_Id = @Cev AND Cet_Id = @T1) <> 50
    INSERT INTO @Fallas VALUES (N'Recálculo: el cuaderno abierto no tomó el peso nuevo');
IF EXISTS (SELECT 1 FROM app.tbCuadernosEvaluacionTipos WHERE Cev_Id = @CevB AND Cet_Nombre = N'Acumulativo' AND Cet_Peso <> 60)
    INSERT INTO @Fallas VALUES (N'Recálculo: el cuaderno del parcial cerrado cambió de pesos');
DELETE FROM @E;
INSERT INTO @E VALUES (N'S1 con 50/40/10', @S1, 83.08, 83), (N'S2 con 50/40/10', @S2, 72.22, 72), (N'S6 con 50/40/10', @S6, 43.47, 43),
                      (N'S7 con 50/40/10', @S7, 79.50, 80);
INSERT INTO @Fallas
SELECT CONCAT(N'Recálculo ', e.Caso, N': esperaba ', e.Entera, N' en tbNotas y hay ', ISNULL(CAST(n.Not_Nota AS nvarchar(10)), N'sin nota'),
              N' (calculada ', k.Nota, N')')
FROM @E e
LEFT JOIN app.FN_Evaluacion_Calculo(@Cev) k ON k.Alu_Id = e.Alu_Id
OUTER APPLY (SELECT TOP (1) x.Not_Nota FROM app.tbNotas x WHERE x.Alu_Id = e.Alu_Id AND x.Sec_Id = @Sec AND x.Mat_Id = @Mat AND x.Pac_Id = @Pac
             AND x.Sem_Id = @Sem AND YEAR(x.Not_Año) = @Anio AND x.Not_EsEliminado = 0 ORDER BY x.Not_Id DESC) n
WHERE ISNULL(n.Not_Nota, -1) <> e.Entera OR ISNULL(k.Nota, -1) <> e.Nota;
IF ISNULL((SELECT TOP (1) x.Not_Nota FROM app.tbNotas x WHERE x.Alu_Id = @S1 AND x.Sec_Id = @Sec AND x.Mat_Id = @Mat AND x.Pac_Id = @PacCerrado
           AND x.Sem_Id = @Sem AND YEAR(x.Not_Año) = @Anio AND x.Not_EsEliminado = 0 ORDER BY x.Not_Id DESC), -1) <> 50
    INSERT INTO @Fallas VALUES (N'Recálculo: cambió la nota de un parcial cerrado');
IF (SELECT Not_Nota FROM app.tbNotas WHERE Not_Id = @NotaOtroAnio) <> 55
    INSERT INTO @Fallas VALUES (N'Recálculo: cambió una nota de otro año');

-- Alguien cambia la nota por otro camino: "Actualizar notas del parcial" la devuelve al cálculo
UPDATE app.tbNotas SET Not_Nota = 1
WHERE Alu_Id = @S1 AND Sec_Id = @Sec AND Mat_Id = @Mat AND Pac_Id = @Pac AND Sem_Id = @Sem AND YEAR(Not_Año) = @Anio AND Not_EsEliminado = 0;
INSERT INTO @R EXEC app.PR_Evaluacion_ActualizarNotas @Cev, @Admin;
IF (SELECT NotasEscritas FROM @R) <> 1 INSERT INTO @Fallas VALUES (N'ActualizarNotas: esperaba 1 nota escrita');
DELETE FROM @R;

-- Alcance del docente: no puede leer el cuaderno de un grupo que no es de su horario
DECLARE @Docente int, @EmpDoc int;
SELECT TOP (1) @Docente = u.Usu_Id, @EmpDoc = u.Emp_Id FROM seguridad.tbUsuarios u JOIN seguridad.tbRoles r ON r.Rol_Id = u.Rol_Id
WHERE LOWER(LTRIM(RTRIM(r.Rol_Descripcion))) = 'docente' AND u.Emp_Id IS NOT NULL AND ISNULL(u.Usu_EsEliminado, 0) = 0
  AND ISNULL(u.Usu_EsActivo, 1) = 1 AND ISNULL(u.Usu_Suspendido, 0) = 0 ORDER BY u.Usu_Id;
DECLARE @HorAjeno int = (SELECT MIN(Hor_Id) FROM app.tbHorarios WHERE Hor_Año = @Anio AND ISNULL(Hor_EsEliminado, 0) = 0 AND Emp_Id <> @EmpDoc);
BEGIN TRY
    DELETE FROM @J;
    INSERT INTO @J EXEC app.PR_Evaluacion_Cuaderno @HorAjeno, @Pac, @Docente;
    INSERT INTO @Fallas VALUES (N'Alcance: el docente leyó el cuaderno de un grupo ajeno');
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 50072 INSERT INTO @Fallas VALUES (CONCAT(N'Alcance (lectura): error inesperado ', ERROR_NUMBER(), N' ', ERROR_MESSAGE()));
END CATCH

-- Último (deja la transacción sin vuelta): puntos mayores que el máximo
BEGIN TRY
    SET @Json = CONCAT(N'[{"a":', @A1, N',"u":', @S2, N',"e":"calificado","p":61,"v":1}]');
    INSERT INTO @R EXEC app.PR_Evaluacion_GuardarPuntos @Cev_Id = @Cev, @Puntos = @Json, @Usuario = @Admin;
    INSERT INTO @Fallas VALUES (N'Se guardaron puntos mayores que el máximo');
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 50092 INSERT INTO @Fallas VALUES (CONCAT(N'Puntos > máximo: error inesperado ', ERROR_NUMBER(), N' ', ERROR_MESSAGE()));
END CATCH

IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
SELECT CONCAT(N'FALLA: ', Caso) AS Resultado FROM @Fallas;
DECLARE @NF int = (SELECT COUNT(*) FROM @Fallas);
PRINT CONCAT(N'089 prueba (cálculo, notas y recálculo): ', @NF, N' fallas');
GO

/* ───────────── 2. Parcial cerrado = no se escriben puntos ───────────── */
DECLARE @Fallas TABLE (Caso nvarchar(200));
DECLARE @Anio int = app.FN_Temario_AnioActual();
DECLARE @Hor int = (SELECT MIN(Hor_Id) FROM app.tbHorarios WHERE Hor_Año = @Anio AND ISNULL(Hor_EsEliminado, 0) = 0
                    AND EXISTS (SELECT 1 FROM app.FN_Evaluacion_Alumnos(@Anio, Sec_Id, Cur_Id, Cun_Id)));
DECLARE @Sem int, @Sec int, @Cur int, @Cun int;
SELECT @Sem = Sem_Id, @Sec = Sec_Id, @Cur = Cur_Id, @Cun = Cun_Id FROM app.FN_Evaluacion_Horario(@Hor);
DECLARE @Admin int = (SELECT TOP (1) u.Usu_Id FROM seguridad.tbUsuarios u JOIN seguridad.tbRoles r ON r.Rol_Id = u.Rol_Id
                      WHERE LOWER(LTRIM(RTRIM(r.Rol_Descripcion))) = 'admin' AND ISNULL(u.Usu_EsEliminado, 0) = 0 ORDER BY u.Usu_Id);
DECLARE @Alu int = (SELECT TOP (1) Alu_Id FROM app.FN_Evaluacion_Alumnos(@Anio, @Sec, @Cur, @Cun) ORDER BY Alu_Id);
DECLARE @R TABLE (Id int, Cev_Id int, Cantidad int, Omitidas int, NotasEscritas int);
DECLARE @Plt int = (SELECT TOP (1) t.Plt_Id FROM app.tbPlantillasEvaluacionTipos t
                    WHERE t.Ple_Id = app.FN_Evaluacion_PlantillaDe(@Anio, (SELECT Niv_Id FROM app.FN_Evaluacion_Horario(@Hor)),
                                                                     (SELECT Mat_Id FROM app.FN_Evaluacion_Horario(@Hor)))
                      AND t.Plt_EsEliminado = 0);
BEGIN TRANSACTION;
IF @Plt IS NULL
    INSERT INTO @Fallas VALUES (N'Parcial cerrado: no hay plantilla del año para probar');
ELSE
BEGIN
    UPDATE app.tbCierresParcial SET Cpa_Estado = 'abierto' WHERE Cpa_Anio = @Anio AND Sem_Id = @Sem AND Pac_Id = 1;
    INSERT INTO @R EXEC app.PR_Evaluacion_GuardarActividad @Hor_Id = @Hor, @Pac_Id = 1, @Plt_Id = @Plt, @Nombre = N'Prueba cerrado', @PuntosMax = 10, @Usuario = @Admin;
    DECLARE @Cev int = (SELECT Cev_Id FROM @R), @Act int = (SELECT Id FROM @R);
    IF EXISTS (SELECT 1 FROM app.tbCierresParcial WHERE Cpa_Anio = @Anio AND Sem_Id = @Sem AND Pac_Id = 1)
        UPDATE app.tbCierresParcial SET Cpa_Estado = 'cerrado' WHERE Cpa_Anio = @Anio AND Sem_Id = @Sem AND Pac_Id = 1;
    ELSE
        INSERT INTO app.tbCierresParcial (Cpa_Anio, Sem_Id, Pac_Id, Cpa_Estado, Cpa_Publicado, Cpa_UsuarioRegistra, Cpa_FechaRegistra)
        VALUES (@Anio, @Sem, 1, 'cerrado', 0, @Admin, GETDATE());
    BEGIN TRY
        DECLARE @Json nvarchar(max) = CONCAT(N'[{"a":', @Act, N',"u":', @Alu, N',"e":"calificado","p":5,"v":0}]');
        DELETE FROM @R;
        INSERT INTO @R EXEC app.PR_Evaluacion_GuardarPuntos @Cev_Id = @Cev, @Puntos = @Json, @Usuario = @Admin;
        INSERT INTO @Fallas VALUES (N'Parcial cerrado: se guardaron puntos');
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() <> 50070 INSERT INTO @Fallas VALUES (CONCAT(N'Parcial cerrado: error inesperado ', ERROR_NUMBER(), N' ', ERROR_MESSAGE()));
    END CATCH
END
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
SELECT CONCAT(N'FALLA: ', Caso) AS Resultado FROM @Fallas;
DECLARE @NF int = (SELECT COUNT(*) FROM @Fallas);
PRINT CONCAT(N'089 prueba (parcial cerrado): ', @NF, N' fallas');
GO

/* ───────────── 3. Un docente no escribe puntos en un grupo ajeno ───────────── */
DECLARE @Fallas TABLE (Caso nvarchar(200));
DECLARE @Anio int = app.FN_Temario_AnioActual();
DECLARE @Admin int = (SELECT TOP (1) u.Usu_Id FROM seguridad.tbUsuarios u JOIN seguridad.tbRoles r ON r.Rol_Id = u.Rol_Id
                      WHERE LOWER(LTRIM(RTRIM(r.Rol_Descripcion))) = 'admin' AND ISNULL(u.Usu_EsEliminado, 0) = 0 ORDER BY u.Usu_Id);
DECLARE @Docente int, @EmpDoc int;
SELECT TOP (1) @Docente = u.Usu_Id, @EmpDoc = u.Emp_Id FROM seguridad.tbUsuarios u JOIN seguridad.tbRoles r ON r.Rol_Id = u.Rol_Id
WHERE LOWER(LTRIM(RTRIM(r.Rol_Descripcion))) = 'docente' AND u.Emp_Id IS NOT NULL AND ISNULL(u.Usu_EsEliminado, 0) = 0
  AND ISNULL(u.Usu_EsActivo, 1) = 1 AND ISNULL(u.Usu_Suspendido, 0) = 0 ORDER BY u.Usu_Id;
DECLARE @Hor int = (SELECT MIN(h.Hor_Id) FROM app.tbHorarios h WHERE h.Hor_Año = @Anio AND ISNULL(h.Hor_EsEliminado, 0) = 0 AND h.Emp_Id <> @EmpDoc
                    AND EXISTS (SELECT 1 FROM app.FN_Evaluacion_Alumnos(@Anio, h.Sec_Id, h.Cur_Id, h.Cun_Id))
                    AND NOT EXISTS (SELECT 1 FROM app.tbHorarios d WHERE d.Hor_Año = h.Hor_Año AND d.Sem_Id = h.Sem_Id AND d.Sec_Id = h.Sec_Id
                                    AND d.Mat_Id = h.Mat_Id AND d.Cur_Id = h.Cur_Id AND d.Cun_Id = h.Cun_Id AND d.Emp_Id = @EmpDoc));
DECLARE @Sem int, @Sec int, @Cur int, @Cun int;
SELECT @Sem = Sem_Id, @Sec = Sec_Id, @Cur = Cur_Id, @Cun = Cun_Id FROM app.FN_Evaluacion_Horario(@Hor);
DECLARE @Alu int = (SELECT TOP (1) Alu_Id FROM app.FN_Evaluacion_Alumnos(@Anio, @Sec, @Cur, @Cun) ORDER BY Alu_Id);
DECLARE @Plt int = (SELECT TOP (1) t.Plt_Id FROM app.tbPlantillasEvaluacionTipos t
                    WHERE t.Ple_Id = app.FN_Evaluacion_PlantillaDe(@Anio, (SELECT Niv_Id FROM app.FN_Evaluacion_Horario(@Hor)),
                                                                     (SELECT Mat_Id FROM app.FN_Evaluacion_Horario(@Hor)))
                      AND t.Plt_EsEliminado = 0);
DECLARE @R TABLE (Id int, Cev_Id int, Cantidad int, Omitidas int, NotasEscritas int);
BEGIN TRANSACTION;
IF @Plt IS NULL OR @Docente IS NULL
    INSERT INTO @Fallas VALUES (N'Alcance: falta plantilla del año o usuario docente para probar');
ELSE
BEGIN
    UPDATE app.tbCierresParcial SET Cpa_Estado = 'abierto' WHERE Cpa_Anio = @Anio AND Sem_Id = @Sem AND Pac_Id = 1;
    INSERT INTO @R EXEC app.PR_Evaluacion_GuardarActividad @Hor_Id = @Hor, @Pac_Id = 1, @Plt_Id = @Plt, @Nombre = N'Prueba ajeno', @PuntosMax = 10, @Usuario = @Admin;
    DECLARE @Cev int = (SELECT Cev_Id FROM @R), @Act int = (SELECT Id FROM @R);
    BEGIN TRY
        DECLARE @Json nvarchar(max) = CONCAT(N'[{"a":', @Act, N',"u":', @Alu, N',"e":"calificado","p":5,"v":0}]');
        DELETE FROM @R;
        INSERT INTO @R EXEC app.PR_Evaluacion_GuardarPuntos @Cev_Id = @Cev, @Puntos = @Json, @Usuario = @Docente;
        INSERT INTO @Fallas VALUES (N'Alcance: el docente escribió puntos en un grupo ajeno');
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() <> 50072 INSERT INTO @Fallas VALUES (CONCAT(N'Alcance (escritura): error inesperado ', ERROR_NUMBER(), N' ', ERROR_MESSAGE()));
    END CATCH
END
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
SELECT CONCAT(N'FALLA: ', Caso) AS Resultado FROM @Fallas;
DECLARE @NF int = (SELECT COUNT(*) FROM @Fallas);
PRINT CONCAT(N'089 prueba (alcance del docente): ', @NF, N' fallas');
GO
