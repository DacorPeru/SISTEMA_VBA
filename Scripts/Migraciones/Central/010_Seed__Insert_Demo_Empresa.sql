USE SISGIPAT;
GO
IF OBJECT_ID('dbo.emp','U') IS NULL
  THROW 51030, 'Falta dbo.emp. Ejecuta 005_Tables__Create_emp.sql.', 1;

IF NOT EXISTS (SELECT 1 FROM dbo.emp WHERE BaseDatos='SISGIPAT')
  INSERT dbo.emp(RUC,RazonSocial,BaseDatos,Estado) VALUES('00000000000',N'Empresa Demo','SISGIPAT','ACTIVO');
GO
