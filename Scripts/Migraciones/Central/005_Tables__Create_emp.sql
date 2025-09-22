USE SISGIPAT;
GO

IF OBJECT_ID('dbo.emp','U') IS NULL
BEGIN
  CREATE TABLE dbo.emp(
    emp_id     INT IDENTITY(1,1) PRIMARY KEY,
    RUC        VARCHAR(11)  NULL,
    RazonSocial NVARCHAR(200) NULL,
    BaseDatos  SYSNAME      NOT NULL,
    Estado     VARCHAR(20)  NOT NULL CONSTRAINT DF_emp_estado DEFAULT('ACTIVO'),
    f_cre      DATETIME2(7) NOT NULL CONSTRAINT DF_emp_fcre DEFAULT(SYSDATETIME())
  );
  CREATE UNIQUE INDEX UQ_emp_BaseDatos ON dbo.emp(BaseDatos);
END
GO
