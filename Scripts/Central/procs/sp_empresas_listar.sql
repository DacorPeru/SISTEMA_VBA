USE BD_SISGIPAT;
GO
IF OBJECT_ID('dbo.sp_empresas_listar','P') IS NOT NULL DROP PROCEDURE dbo.sp_empresas_listar;
GO
CREATE PROCEDURE dbo.sp_empresas_listar
WITH ENCRYPTION
AS
BEGIN
  SET NOCOUNT ON;
  SELECT id_empresa, codigo_empresa, razon_social, ruc, db_server, db_name, activo
    FROM dbo.empresas
   ORDER BY razon_social;
END
GO
