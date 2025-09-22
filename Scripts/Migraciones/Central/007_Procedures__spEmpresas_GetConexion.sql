USE SISGIPAT;
GO
CREATE OR ALTER PROCEDURE dbo.spEmpresas_GetConexion
  @empKey NVARCHAR(200)  -- puede ser emp_id, BaseDatos o RUC
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @Base SYSNAME;
  SELECT TOP 1 @Base = BaseDatos
  FROM dbo.emp
  WHERE Estado='ACTIVO' AND (
        BaseDatos = @empKey OR
        RUC       = @empKey OR
        CAST(emp_id AS NVARCHAR(20)) = @empKey );

  SELECT BaseDatos=@Base;
END
GO
