/*USE SISGIPAT;
GO

/* Inserta empresa DEMO idempotente */
IF NOT EXISTS (SELECT 1 FROM dbo.emp WHERE codigo='DEMO')
BEGIN
    INSERT dbo.emp(
        codigo, nombre, ruc, servidor, base_datos, usuario, [password], trusted,
        [timeout], entorno, bloqueado, baja, estado, email_contacto
    )
    VALUES(
        N'DEMO', N'Empresa Demo S.A.C.', '20123456789',
        N'(localdb)\\MSSQLLocalDB', N'SISGIPAT_EMP_DEMO', NULL, NULL, 1,
        30, 'DEMO', 0, 0, 'ACTIVO', N'contacto@demo.com'
    );
END*/
GO
