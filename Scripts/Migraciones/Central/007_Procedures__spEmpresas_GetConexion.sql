USE SISGIPAT;
GO

/* ============================================================
   spEmpresas_GetConexion (PRODUCCIÓN)
   Devuelve los parámetros de conexión de la empresa (tenant) de forma segura.
   - Busca por @EmpresaId o (alternativamente) por @Codigo.
   - Solo empresas ACTIVO, no BLOQUEADAS ni dadas de BAJA.
   - Si Trusted=1 (Windows/SSPI), NO expone Password (devuelve NULL).
   - Lanza error claro si no se encuentra o no cumple condiciones.
   ============================================================ */
CREATE OR ALTER PROCEDURE dbo.spEmpresas_GetConexion
    @EmpresaId INT = NULL,           -- Identificador interno de la empresa (preferido)
    @Codigo    NVARCHAR(50) = NULL   -- Alternativa: código interno único de la empresa
AS
BEGIN
    SET NOCOUNT ON;

    /* 1) Selección robusta: toma a lo sumo 1 empresa válida y la guarda en @p */
    DECLARE @p TABLE
    (
        emp_id       INT,
        servidor     NVARCHAR(200),
        base_datos   SYSNAME,
        [usuario]    SYSNAME,
        [password]   NVARCHAR(256),
        trusted      BIT,
        [timeout]    INT,
        entorno      VARCHAR(10),
        tipo_entidad VARCHAR(10),
        naturaleza   VARCHAR(5),
        estado       VARCHAR(20)
    );

    INSERT INTO @p (emp_id, servidor, base_datos, [usuario], [password], trusted, [timeout],
                    entorno, tipo_entidad, naturaleza, estado)
    SELECT TOP (1)
        e.emp_id, e.servidor, e.base_datos, e.[usuario], e.[password], CAST(ISNULL(e.trusted,1) AS bit),
        ISNULL(e.[timeout],30), e.entorno, e.tipo_entidad, e.naturaleza, e.estado
    FROM dbo.emp AS e
    WHERE
        (
            (@EmpresaId IS NOT NULL AND e.emp_id = @EmpresaId)
         OR (@EmpresaId IS NULL AND @Codigo IS NOT NULL AND e.codigo = @Codigo)
        )
        AND e.estado    = 'ACTIVO'   -- solo activas
        AND e.bloqueado = 0          -- no bloqueadas
        AND e.baja      = 0          -- no dadas de baja
    ORDER BY e.emp_id;

    /* 2) Si no hubo coincidencias válidas, lanza un error claro */
    IF NOT EXISTS (SELECT 1 FROM @p)
    BEGIN
        ;THROW 50001, 'Empresa no encontrada o no está ACTIVA / está BLOQUEADA / dada de BAJA.', 1;
    END

    /* 3) Proyección segura:
          - Password solo si Trusted=0 (SQL Auth); en caso contrario NULL.
          - Se devuelven además entorno/tipeo para lógica de la app. */
    SELECT
        emp_id                       AS EmpresaId,
        servidor                     AS Servidor,
        base_datos                   AS BaseDatos,
        [usuario]                    AS Usuario,
        CASE WHEN trusted = 0 THEN [password] ELSE NULL END AS [Password], -- evita exponer clave si SSPI
        trusted                      AS Trusted,
        [timeout]                    AS [Timeout],
        entorno                      AS Entorno,
        tipo_entidad                 AS TipoEntidad,
        naturaleza                   AS Naturaleza,
        estado                       AS Estado
    FROM @p;
END
GO
