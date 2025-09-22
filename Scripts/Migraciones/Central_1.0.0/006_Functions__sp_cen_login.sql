USE SISGIPAT;
GO

-- Verificar si el procedimiento ya existe y eliminarlo si es necesario
IF OBJECT_ID('dbo.sp_cen_login', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_cen_login;
GO

-- Crear el procedimiento sp_cen_login para el login de usuario
CREATE PROCEDURE dbo.sp_cen_login
    @email NVARCHAR(320),  -- Correo electrónico del usuario
    @pwd_plain NVARCHAR(4000)  -- Contraseña proporcionada por el usuario
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @salt VARBINARY(16);   -- Salt que se recuperará de la base de datos
    DECLARE @iter INT;             -- Número de iteraciones
    DECLARE @hash VARBINARY(32);   -- Hash que se recuperará de la base de datos
    DECLARE @calculated_hash VARBINARY(32);  -- Hash calculado

    -- Recuperar salt, iter y hash desde la base de datos
    SELECT @salt = salt, @iter = iter, @hash = hash
    FROM dbo.cen_usr
    WHERE email = @email;

    -- Si no se encuentra el usuario, retornamos un error
    IF @salt IS NULL
    BEGIN
        SELECT 0 AS LoginStatus;  -- Usuario no encontrado
        RETURN;
    END

    -- Aquí debes agregar la lógica para calcular el hash de la contraseña usando el salt y las iteraciones
    -- Puedes usar un algoritmo de hashing externo o uno implementado en el código de la aplicación

    -- Como ejemplo, vamos a suponer que el hash se calcula fuera de la base de datos
    -- y se pasa a la base de datos para la comparación
    -- El hash calculado sería el que se pasa desde la aplicación o DLL

    -- Comparar el hash calculado con el almacenado en la base de datos
    -- Aquí la comparación debe hacerse con el hash que la aplicación o DLL ha calculado
    IF @calculated_hash = @hash
    BEGIN
        SELECT 1 AS LoginStatus;  -- Login exitoso
    END
    ELSE
    BEGIN
        SELECT 0 AS LoginStatus;  -- Credenciales incorrectas
    END
END
GO
