# SISGIPAT SQL (Clean, sin PBKDF2)

Este paquete contiene los scripts listos para ejecutar **sin** la función `fn_pbkdf2_sha256`. 
El hash de contraseñas se realiza **inline** usando un algoritmo de *stretching* con SHA2-256 (llamado `TSQL_STRETCH`), coherente en los SPs de *upsert*, *login* y *verify*.

## Orden sugerido
1. `002_Create_Database_SISGIPAT.sql`
2. `003_Catalogs__Create_cat_tipo_doc.sql`
3. `004_Tables__Create_cen_usr.sql`
4. `005_Tables__Create_emp.sql`
5. `007_Procedures__spEmpresas_GetConexion.sql`
6. `008_Procedures__sp_cen_usr_upsert.sql`
7. `006_Functions__sp_cen_login.sql`
8. `012_Procedures__sp_cen_usr_verify_server.sql`
9. `009_Seed__Insert_Default_User.sql`
10. `010_Seed__Insert_Demo_Empresa.sql`
11. `011_PostDeploy__Sanity_Checks.sql`

> **Nota**: Este esquema es válido para **DEV**. Para producción, migra a tu DLL/KDF y cambia `kdf_alg` y el cálculo del hash dentro de los SPs.
