USE SISGIPAT;
GO
SET NOCOUNT ON;

/* ============================================================
   SISGIPAT – Post-Deploy Checks (escenario sin empresas aún)
   - Verifica objetos críticos y conteos mínimos.
   - No requiere ninguna empresa creada; si emp=0, solo avisa.
   ============================================================ */

PRINT '=== SISGIPAT Post-Deploy Checks ===';

-- 1) Objetos críticos esperados (tablas y SPs base)
SELECT name, type_desc
FROM sys.objects
WHERE name IN ('cat_tipo_doc','cen_usr','emp','spEmpresas_GetConexion','sp_cen_usr_upsert')
   AND type IN ('U','P')  -- Solo tablas (U) y procedimientos (P)
ORDER BY type_desc, name;

-- 2) Conteos básicos (solo informativo)
SELECT 'cat_tipo_doc' AS tabla, COUNT(*) AS filas FROM dbo.cat_tipo_doc
UNION ALL
SELECT 'cen_usr'      , COUNT(*)        FROM dbo.cen_usr
UNION ALL
SELECT 'emp'          , COUNT(*)        FROM dbo.emp;

-- 3) Mensajes guía según estado de 'emp'
DECLARE @n_emp INT = (SELECT COUNT(*) FROM dbo.emp);
IF @n_emp = 0
    PRINT 'WARN: Aún no hay empresas registradas. Es esperado en esta etapa; ' +
          'cuando definas la primera empresa, vuelve a ejecutar los checks.';
ELSE
    PRINT 'INFO: Hay empresas registradas; puedes probar spEmpresas_GetConexion si lo deseas.';

PRINT '=== Fin de Post-Deploy: ver resultados arriba. ===';
GO
