#clase_7

![[Pasted image 20250909194526.png]]


```sql
USE [practica_clase]
GO
/****** Object:  Table [dbo].[empresas]    Script Date: 9/9/2025 18:44:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[empresas](
[nro_serie] [int] NOT NULL,
[tipo_entidad] [int] NULL,
[cod_prov] [smallint] NOT NULL,
[razon_soc] [varchar](200) NULL,
[provincia] [varchar](19) NOT NULL,
[cod_local] [int] NULL,
[cod_partido] [int] NULL,
[partido] [varchar](30) NULL,
[localidad] [varchar](35) NULL,
[fecha_cie] [varchar](20) NULL,
[fecha_ins] [varchar](20) NULL,
[enfalta] [char](6) NULL,
[estado] [smallint] NOT NULL,
[domicilio] [varchar](87) NULL,
[codpostal] [varchar](12) NOT NULL,
[otro_codprov] [smallint] NULL,
[cuit] [varchar](13) NULL,
[mail] [varchar](50) NULL,
[telefono] [varchar](25) NULL
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[empresas](
	[nro_serie] [int] NOT NULL,
	[tipo_entidad] [int] NULL,
	[cod_prov] [smallint] NOT NULL,
	[razon_soc] [varchar](200) NULL,
	[provincia] [varchar](19) NOT NULL,
	[cod_local] [int] NULL,
	[cod_partido] [int] NULL,
	[partido] [varchar](30) NULL,
	[localidad] [varchar](35) NULL,
	[fecha_cie] [varchar](20) NULL,
	[fecha_ins] [varchar](20) NULL,
	[enfalta] [char](6) NULL,
	[estado] [smallint] NOT NULL,
	[domicilio] [varchar](87) NULL,
	[codpostal] [varchar](12) NOT NULL,
	[otro_codprov] [smallint] NULL,
	[cuit] [varchar](13) NULL,
	[mail] [varchar](50) NULL,
	[telefono] [varchar](25) NULL
)
```

```sql
insert into dbo.empresas( nro_serie,tipo_entidad
      ,[cod_prov] ,[razon_soc]  ,[provincia]  ,[cod_local]  ,[cod_partido]
      ,[partido] ,[localidad] ,[fecha_cie] ,[fecha_ins]  ,[enfalta]
      ,[estado]  ,[domicilio]  ,[codpostal]  ,[otro_codprov],[cuit]
      ,[mail]  ,[telefono])
SELECT [nro_serie]     ,[tipo_entidad]  ,[cod_prov] ,[razon_soc] ,[provincia]
      ,[cod_local] ,[cod_partido] ,[partido],[localidad]  ,[fecha_cie]   ,[fecha_ins]
      ,[enfalta]  ,[estado]  ,[domicilio] ,[codpostal] ,[otro_codprov]
      ,[cuit]  ,[mail]  ,[telefono]
  FROM practica_clase.dbo.empresas
```

# Ejercicios doc
![[Pasted image 20250909192013.png]]

![[ejercicios2050909.pdf]]

# Respuestas

## Ejercicio 1 - Visto en clase

![[Pasted image 20250909192020.png]]

![[Pasted image 20250909192004.png]]
![[Pasted image 20250909192225.png]]

```sql
Select razon_social, cuit ,replace(ltrim(razon_social),'"',''),  replace(razon_social, '"', ''), ltrim(razon_social)
From dbo.t_empresa
order by razon_social 
-- 1er update 
update dbo.t_empresa
set razon_social = replace(razon_social, '"', '')
-- 2do update
update dbo.t_empresa
set razon_social =  ltrim(razon_social)
-- dos pasos en uno
update dbo.t_empresa
set razon_social =  replace(ltrim(razon_social),'"','')
-- 3r update 
update dbo.t_empresa
set razon_social = replace(razon_social, '<', '')
update dbo.t_empresa
set razon_social = replace(razon_social, '>', '')
```
![[Pasted image 20250909193204.png]]
![[Pasted image 20250909193811.png]]

---

![[Pasted image 20250909194449.png]]


![[Pasted image 20250909201205.png]]

---
```sql
drop procedure sp_listar_empresa
create procedure sp_listar_empresa
@par_codigo_entidad int null,
@debug varchar(1)
as
/*declaracion de variables*/
Declare @status int
select @status = 0
/* controlar el codigo de parametro codigo entidad */
declare @var_cod_entidad_rowcount int
select @var_cod_entidad_rowcount = count(*)
from dbo.t_tipo_entidad
Where codigo_entidad = @par_codigo_entidad
If @var_cod_entidad_rowcount <> 1 
Begin
	if @debug = 'S' 
	   print 'no existe codigo entidad'
	Raiserror('No existe codigo Entidad. Revisar codigo antes de ejecutar', 14,1)
	select @status = -1
	Return @status
End
else
   if @debug = 'S' 
      print 'no existe codigo entidad'
/*ejecucion de query final*/
Select razon_social, cuit 
From dbo.t_empresa emp, dbo.t_tipo_entidad te
Where emp.id_tipo_entidad = te.id_tipo_entidad
	and te.codigo_entidad = @par_codigo_entidad
order by razon_social 
Return @status
```

![[Pasted image 20250909201626.png]]

```sql

CREATE TABLE [dbo].[empresas](
	[nro_serie] [int] NOT NULL,
	[tipo_entidad] [int] NULL,
	[cod_prov] [smallint] NOT NULL,
	[razon_soc] [varchar](200) NULL,
	[provincia] [varchar](19) NOT NULL,
	[cod_local] [int] NULL,
	[cod_partido] [int] NULL,
	[partido] [varchar](30) NULL,
	[localidad] [varchar](35) NULL,
	[fecha_cie] [varchar](20) NULL,
	[fecha_ins] [varchar](20) NULL,
	[enfalta] [char](6) NULL,
	[estado] [smallint] NOT NULL,
	[domicilio] [varchar](87) NULL,
	[codpostal] [varchar](12) NOT NULL,
	[otro_codprov] [smallint] NULL,
	[cuit] [varchar](13) NULL,
	[mail] [varchar](50) NULL,
	[telefono] [varchar](25) NULL
)



insert into dbo.empresas( nro_serie,tipo_entidad
      ,[cod_prov] ,[razon_soc]  ,[provincia]  ,[cod_local]  ,[cod_partido]
      ,[partido] ,[localidad] ,[fecha_cie] ,[fecha_ins]  ,[enfalta]
      ,[estado]  ,[domicilio]  ,[codpostal]  ,[otro_codprov],[cuit]
      ,[mail]  ,[telefono])

SELECT [nro_serie]     ,[tipo_entidad]  ,[cod_prov] ,[razon_soc] ,[provincia]
      ,[cod_local] ,[cod_partido] ,[partido],[localidad]  ,[fecha_cie]   ,[fecha_ins]
      ,[enfalta]  ,[estado]  ,[domicilio] ,[codpostal] ,[otro_codprov]
      ,[cuit]  ,[mail]  ,[telefono]
  FROM practica_clase.dbo.empresas
  
  
  

Select razon_social, cuit ,replace(ltrim(razon_social),'"',''),  replace(razon_social, '"', ''), ltrim(razon_social)
From dbo.t_empresa
order by razon_social 

-- 1er update 
update dbo.t_empresa
set razon_social = replace(razon_social, '"', '')

-- 2do update
update dbo.t_empresa
set razon_social =  ltrim(razon_social)

-- dos pasos en uno
update dbo.t_empresa
set razon_social =  replace(ltrim(razon_social),'"','')

-- 3r update 
update dbo.t_empresa
set razon_social = replace(razon_social, '<', '')

update dbo.t_empresa
set razon_social = replace(razon_social, '>', '')


drop procedure sp_listar_empresa

create procedure sp_listar_empresa
@par_codigo_entidad int null,
@debug varchar(1)
as
/*declaracion de variables*/
Declare @status int
select @status = 0

/* controlar el codigo de parametro codigo entidad */
declare @var_cod_entidad_rowcount int

select @var_cod_entidad_rowcount = count(*)
from dbo.t_tipo_entidad
Where codigo_entidad = @par_codigo_entidad

If @var_cod_entidad_rowcount <> 1 
Begin
	if @debug = 'S' 
	   print 'no existe codigo entidad'

	Raiserror('No existe codigo Entidad. Revisar codigo antes de ejecutar', 14,1)
	select @status = -1
	Return @status
End
else
   if @debug = 'S' 
      print 'no existe codigo entidad'

/*ejecucion de query final*/
Select razon_social, cuit 
From dbo.t_empresa emp, dbo.t_tipo_entidad te
Where emp.id_tipo_entidad = te.id_tipo_entidad
	and te.codigo_entidad = @par_codigo_entidad
order by razon_social 

Return @status 


/********************************************************************
Nombre      : sdn_sp_listar_empresa
Autor       : [Tu Nombre]
Fecha       : 2025-09-09
Descripción : Lista las empresas filtradas por código de entidad
Parámetros  : @par_codigo_entidad, @debug, @status
Retorno     : 0 = Éxito, -1 = Error
*********************************************************************/
CREATE OR ALTER PROCEDURE sdn_sp_listar_empresa_v02
    @par_codigo_entidad INT = NULL,
    @debug CHAR(1) = 'N',
    @status INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @var_cod_entidad_rowcount INT,
            @error_message NVARCHAR(4000)

    -- Inicializar estado
    SET @status = 0

    IF @debug = 'S'
        PRINT 'Iniciando sdn_sp_listar_empresa...'

    BEGIN TRY
        /* Validación: existe el código entidad */
        SELECT @var_cod_entidad_rowcount = COUNT(*)
        FROM dbo.t_tipo_entidad
        WHERE codigo_entidad = @par_codigo_entidad

        IF @var_cod_entidad_rowcount <> 1 
        BEGIN
            IF @debug = 'S'
                PRINT 'No existe el código entidad proporcionado.'

            SET @status = -1
            RAISERROR('No existe código Entidad. Revisar código antes de ejecutar.', 14, 1)
            RETURN @status
        END
        ELSE
        BEGIN
            IF @debug = 'S'
                PRINT 'Código entidad válido. Ejecutando query final...'
        END

        /* Ejecución de consulta principal */
        SELECT 
            emp.razon_social, 
            emp.cuit
        FROM dbo.t_empresa emp
        INNER JOIN dbo.t_tipo_entidad te 
            ON emp.id_tipo_entidad = te.id_tipo_entidad
        WHERE te.codigo_entidad = @par_codigo_entidad
        ORDER BY emp.razon_social

        -- Éxito
        SET @status = 0
    END TRY
    BEGIN CATCH
        SET @status = ERROR_NUMBER()
        SET @error_message = ERROR_MESSAGE()

        IF @debug = 'S'
            PRINT 'Error capturado en TRY...CATCH'

        RAISERROR(@error_message, 16, 1)
    END CATCH
END

DECLARE @RC int
DECLARE @par_codigo_entidad int
DECLARE @debug char(1)
DECLARE @status int

select @par_codigo_entidad = 21, @debug = 'S',  @status = 0

-- TODO: Set parameter values here.
EXECUTE @RC = [dbo].[sdn_sp_listar_empresa_v02] 
   @par_codigo_entidad
  ,@debug
  ,@status OUTPUT
```

```sql
create procedure sp_listar_xxxx
@par_xxxx int null,
@debug varchar(1)
as
/*declaracion de variables*/
Declare @status int
select @status = 0
/* controlar el codigo de parametro codigo entidad */
If @par_xxxx <> 1 
/*ejecucion de query final*/
Select razon_social, cuit 
From dbo.t_empresa emp, dbo.t_tipo_entidad te
Where emp.id_tipo_entidad = te.id_tipo_entidad
	and te.codigo_entidad = @par_codigo_entidad
order by razon_social 
Return @status
```

---
## Ejercicios

![[Pasted image 20250909202801.png]]
![[Pasted image 20250909202857.png]]
![[Pasted image 20250909202951.png]]

## Ejercicio 4 (asignado)
Ejercicio: Crear un stored procedure que devuelva los contactos registrados para una empresa determinada (por ID), ordenados por tipo.
![[Pasted image 20250909194526.png]]
![[Pasted image 20250909202957.png]]

```sql
USE lesteban25;

-- DROP PROCEDURE dbo.jv_sp_listar_contactos_por_empresa;

CREATE OR ALTER PROCEDURE dbo.jv_sp_listar_contactos_por_empresa
    @par_id_empresa INT = NULL,
    @debug          CHAR(1) = 'N',
    @status         INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @status = 0;

    BEGIN TRY
        IF
			@par_id_empresa IS NULL
			OR NOT EXISTS (
				SELECT 1 FROM dbo.t_empresa WHERE id_empresa = @par_id_empresa
			)
        BEGIN
            SET @status = -1;
            RAISERROR('Empresa no encontrada.', 14, 1);
            RETURN;
        END;

        SELECT 
            c.descripcion AS Contacto,
            c.tipo AS Tipo
        FROM dbo.t_contacto c
        WHERE c.id_empresa = @par_id_empresa
        ORDER BY c.tipo, c.descripcion;
    END TRY
    BEGIN CATCH
        SET @status = ERROR_NUMBER();
        THROW;
    END CATCH
END


DECLARE @rc     INT,
		@status INT
;
EXEC @rc = dbo.jv_sp_listar_contactos_por_empresa
     @par_id_empresa = 42,   -- acá pones el ID de la empresa que quieras consultar
     @debug = 'S',           -- 'S' para ver mensajes de debug, 'N' para silencioso
     @status = @status OUTPUT
;

SELECT
	rc = @rc,
    status = @status
;
```

## Ejercicio 8 (Ejemplo de Mario)
![[Pasted image 20250909204422.png]]
