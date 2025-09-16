USE BD_SISGIPAT;
GO
IF OBJECT_ID('dbo.sp_empresa_upsert','P') IS NOT NULL DROP PROCEDURE dbo.sp_empresa_upsert;
GO
CREATE PROCEDURE dbo.sp_empresa_upsert
  @id_empresa BIGINT = NULL,
  @codigo_empresa VARCHAR(6),
  @ruc VARCHAR(11),
  @razon_social NVARCHAR(200),
  @nombre_comercial NVARCHAR(150)=NULL,
  @tipo_empresa VARCHAR(20)=NULL,
  @db_server NVARCHAR(128),
  @db_name   NVARCHAR(128),
  @activo BIT = 1
WITH ENCRYPTION
AS
BEGIN
  SET NOCOUNT ON;
  IF @id_empresa IS NULL
    INSERT INTO dbo.empresas(codigo_empresa,ruc,razon_social,nombre_comercial,tipo_empresa,db_server,db_name,activo)
    VALUES(@codigo_empresa,@ruc,@razon_social,@nombre_comercial,@tipo_empresa,@db_server,@db_name,@activo);
  ELSE
    UPDATE dbo.empresas SET
      codigo_empresa=@codigo_empresa,
      ruc=@ruc,
      razon_social=@razon_social,
      nombre_comercial=@nombre_comercial,
      tipo_empresa=@tipo_empresa,
      db_server=@db_server,
      db_name=@db_name,
      activo=@activo,
      actualizado_en=SYSDATETIME()
    WHERE id_empresa=@id_empresa;
END
GO
