USE SISGIPAT;
GO
PRINT '=== SISGIPAT Post-Deploy Checks ===';

SELECT name,type_desc
FROM sys.objects
WHERE (name IN ('cat_tipo_doc','cen_usr','emp','spEmpresas_GetConexion','sp_cen_usr_upsert','sp_cen_login')
       AND type IN ('U','P'))
ORDER BY type_desc,name;

SELECT 'cat_tipo_doc' AS tabla, COUNT(*) AS filas FROM dbo.cat_tipo_doc
UNION ALL SELECT 'cen_usr', COUNT(*) FROM dbo.cen_usr
UNION ALL SELECT 'emp', COUNT(*) FROM dbo.emp;
GO
