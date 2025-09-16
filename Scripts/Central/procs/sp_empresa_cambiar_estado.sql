USE BD_SISGIPAT;
GO
IF OBJECT_ID('dbo.sp_empresa_cambiar_estado','P') IS NOT NULL DROP PROCEDURE dbo.sp_empresa_cambiar_estado;
GO
CREATE PROCEDURE dbo.sp_empresa_cambiar_estado
  @id_empresa BIGINT,
  @activo BIT
WITH ENCRYPTION
AS
BEGIN
  UPDATE dbo.empresas
     SET activo=@activo, actualizado_en=SYSDATETIME()
   WHERE id_empresa=@id_empresa;
END
GO
