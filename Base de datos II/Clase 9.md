#clase_9

![[Pasted image 20250916192957.png]]

---

```sql


Drop PROCEDURE dbo.sp_insert_empresa

CREATE PROCEDURE dbo.sp_insert_empresa
    @par_razon_social         VARCHAR(250),
    @par_cuit                 BIGINT,
    @par_fecha_cierre         VARCHAR(5),
    @par_id_tipo_entidad      INT,
    @par_id_provincia         INT,
    @debug                CHAR(1) = 'N' -- Mensaje de depuración (S/N)
as
/*-------- defecto -------------------
id_estado = 1 .. Activa
enfalta = 0 (no esta en falta)
tipo_cod_entidad = al valor ingresado en id_tipo_entidad

--------------------------------------*/
/*
razon social = no caracteres especiales y minimo 3 caracteres
cuit = 11 digitos y tiene que empezar si o si con 30 o 33 o 34
           no exista un cuit ya dado de alta

Fecha Cierre = fijo de 5 caracteres con el formato  DD/MM  - x eje 1 de Enero es 01/01
fecha_inscripcion    = es el dia del alta de la empresa
nro de serie = se calcula con el ultimo nro de serie + 1 entregado x tipo entidad y provincia

*/
BEGIN
    SET NOCOUNT ON;
    DECLARE @status INT = 0;

	/* validaciones de tipo de parametros ingresados */
	-- @par_razon_social   minimo 3 caracteres 
  	Declare @len_empresa int
	Select @len_empresa = len(@par_razon_social)
	IF @len_empresa < 3
		Begin
			IF @debug = 'S'
			BEGIN
				PRINT 'Error EL Nombre o razon social debe contener al menos 3 caracteres';
			END
			select @status = -1
			Return @status
		End

    -- @par_cuit  valido que cuit no exista 
	IF EXISTS (
				Select 1
				From dbo.t_empresa
				Where cuit = @par_cuit
			  )
	Begin
		IF @debug = 'S'
		BEGIN
			PRINT 'Ya existe una empresa con ese CUIT';
		END	
		select @status = -2
		Return @status
	End

	--Select @par_cuit = 20502123211
	IF (@par_cuit > 29999999999 and @par_cuit <31000000000) 
		or (@par_cuit > 32999999999 and @par_cuit <35000000000)
	Begin
		IF @debug = 'S'
		BEGIN
			PRINT 'tiene 11 digitos y es 30 , 33, 34';
		END	
	End
	else
	Begin
		IF @debug = 'S'
		BEGIN
			PRINT 'CUIT: no cumple con el formato correcto';
		END	
		select @status = -2
		Return @status
	End

	/* calculo de fecha cierre correcta */
	Declare @anio varchar(4)
	Select @anio = convert(varchar(4), year(getdate()))

	Declare @fecha_cierre_completa varchar(10)
	Select @fecha_cierre_completa = @par_fecha_cierre + '/' + @anio
	-- Intento de conversión a tipo DATE con validación

	declare @fecha_final date
	BEGIN TRY
		SET @fecha_final = CONVERT(DATE, @fecha_cierre_completa, 103); -- 103 = formato dd/MM/yyyy
	END TRY
	BEGIN CATCH
		PRINT 'Fecha inválida: ' + @fecha_cierre_completa
		select @status = -2
		Return @status
	END CATCH
	/*-----------------------------------*/

	Declare @proximo_nro_serie int
	-- entrega de proximo nro serie de empresa para ese tipo de entidad (1) y esa provincia (1)
	Select @proximo_nro_serie = max(nro_serie) + 1 
	From dbo.t_empresa
	Where id_tipo_entidad = @par_id_tipo_entidad
		and id_provincia = @par_id_provincia

	If @proximo_nro_serie is null or @proximo_nro_serie = 0 
	Begin
		IF @debug = 'S'
		BEGIN
			PRINT 'Error en el calculo del proximo nro de serie';
		END	
		select @status = -3
		Return @status
	End

	-- poner por defecto el valor de la fecha del dia de hoy
	Declare @fecha_incripcion datetime
	Select @fecha_incripcion = getdate()

	declare @cod_prov int 
	declare @tipo_cod_entidad int

	-- recupero cod_prov de la tabla provincia
	select @cod_prov = cod_prov
	From dbo.t_provincia
	Where id_provincia = @par_id_provincia

	-- recupero codigo de entidad de la tabla entidad
	select @tipo_cod_entidad = codigo_entidad
	From dbo.t_tipo_entidad
	Where id_tipo_entidad = @par_id_tipo_entidad


	/*insert */
        -- Inserción de nueva empresa
        INSERT INTO dbo.t_empresa (razon_social,cuit,fecha_cierre,fecha_inscripcion,enfalta,nro_serie,id_tipo_entidad,id_provincia,id_estado,cod_prov,tipo_cod_entidad )
        VALUES (@par_razon_social, @par_cuit,@par_fecha_cierre,@fecha_incripcion,0,@proximo_nro_serie,@par_id_tipo_entidad,@par_id_provincia,1,
		@cod_prov, @tipo_cod_entidad);

	IF @debug = 'S'
	BEGIN
		PRINT 'se dio de alta correctamente la entidad';
	END	

	Select @proximo_nro_serie, @par_razon_social, @par_cuit,@par_fecha_cierre,@fecha_incripcion
	/*control del insert catch */

    RETURN @status;
END


DECLARE @RC int
DECLARE @par_razon_social varchar(250)
DECLARE @par_cuit bigint
DECLARE @par_fecha_cierre varchar(5)
DECLARE @par_fecha_inscripcion datetime
DECLARE @par_id_tipo_entidad int
DECLARE @par_id_provincia int
DECLARE @debug char(1)

-- TODO: Set parameter values here.
Select @par_razon_social = 'Empresa de TV'
Select @par_cuit = 33502123211
Select @par_fecha_cierre = '01/06'
Select @par_id_tipo_entidad = 1   /* cooperativa */
Select @par_id_provincia = 2       /* Buenos Aires  */
Select @debug = 'S'

EXECUTE @RC = [dbo].[sp_insert_empresa] 
   @par_razon_social
  ,@par_cuit
  ,@par_fecha_cierre
  ,@par_id_tipo_entidad
  ,@par_id_provincia
  ,@debug 

-- recupero @status
select @RC
```