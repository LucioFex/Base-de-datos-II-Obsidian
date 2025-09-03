#clase_6 

# Contenido
```table-of-contents
```

# Repaso
![[Pasted image 20250902184057.png]]

## Repasamos UNION
![[Pasted image 20250902184615.png]]
![[Pasted image 20250902185248.png]]

# Miramos funciones varias (CHARINDEX, REPLACE, etc)

![[Pasted image 20250902185521.png]]

![[Pasted image 20250902185919.png]]

![[Pasted image 20250902190020.png]]

![[Pasted image 20250902191935.png]]

---


![[Pasted image 20250902191952.png]]

![[Pasted image 20250902192341.png]]

![[Pasted image 20250902193344.png]]

![[Pasted image 20250902194126.png]]

![[Pasted image 20250902194753.png]]

![[Pasted image 20250902200548.png]]

![[Pasted image 20250902200719.png]]

![[Pasted image 20250902202321.png]]

![[Pasted image 20250902212105.png]]

---

```sql
create view vw_domicilio_emp
as
Select 
      do.id_empresa,
      do.descripcion, do.codigo_postal, 
      l.descripcion as localidad,
	  par.descripcion as partido,
	  prov.descripcion as provincia
From dbo.t_domicilio do,
	dbo.t_localidad l,
	dbo.t_partido par,
	dbo.t_provincia prov
Where do.id_localidad = l.id_localidad
	and l.id_partido = par.id_partido
	and par.id_provincia = prov.id_provincia
```

---
# Tareas para la próxima clase:

![[Pasted image 20250902213704.png]]


Debemos arreglar la carga de la tabla t_domicilio
Tenemos que crear las FK de todas las tablas 

![[Pasted image 20250902213742.png]]


---

# Teoría

![[Pasted image 20250902214809.png]]

SP = Stored Procedure = Procedimiento almacenado

![[Pasted image 20250902214821.png]]

![[Pasted image 20250902215114.png]]

![[Pasted image 20250902215145.png]]

![[Pasted image 20250902215230.png]]

![[Pasted image 20250902215321.png]]

![[Pasted image 20250902215325.png]]

![[Pasted image 20250902215405.png]]

![[Pasted image 20250902215529.png]]

![[Pasted image 20250902215651.png]]

![[Pasted image 20250902215814.png]]

![[Pasted image 20250902220112.png]]

![[Pasted image 20250902220210.png]]

---

# SQL resultante de la clase

```sql
INSERT INTO dbo.t_empresa(razon_social,cuit,fecha_cierre,fecha_inscripcion,enfalta,
                          nro_serie,id_tipo_entidad,id_provincia,id_estado, 
						  tipo_cod_entidad, cod_prov)
-- empresas con estado no activo
SELECT 
       -- empresas
      SUBSTRING(razon_soc,
	            CHARINDEX(') ',razon_soc) + 2,
				LEN(razon_soc) - CHARINDEX(') ',razon_soc) + 2) 
      ,dbo.empresas.cuit -- empresas
      ,dbo.empresas.fecha_cie -- empresas
      ,dbo.empresas.fecha_ins -- empresas

      , CASE 
	      When dbo.empresas.enfalta = 'true' Then 1
		  else 0
	   end as enfalta

	  ,dbo.empresas.nro_serie  -- empresas
	  ,dbo.t_tipo_entidad.id_tipo_entidad -- DER
	  ,dbo.t_provincia.id_provincia  -- DER 
      ,dbo.t_estado.id_estado -- DER
	  ,dbo.empresas.tipo_entidad
	  ,dbo.empresas.cod_prov
FROM dbo.empresas,
     dbo.t_tipo_entidad,
	 dbo.t_provincia,
	 dbo.t_estado
Where 
    -- join empresas y tipo entidad
	dbo.empresas.tipo_entidad = dbo.t_tipo_entidad.codigo_entidad
	-- join entre empresas y provincia
	and dbo.empresas.cod_prov = dbo.t_provincia.cod_prov
	-- join entre empresas y estado 
	and dbo.empresas.estado = dbo.t_estado.codigo_estado
	and dbo.empresas.razon_soc like '(%)%'

Union 
-- empresas con estado activo
SELECT 
       -- empresas
	  replace(razon_soc, '"','') as razon_soc
      ,dbo.empresas.cuit -- empresas
      ,dbo.empresas.fecha_cie -- empresas
      ,dbo.empresas.fecha_ins -- empresas

      , CASE 
	      When dbo.empresas.enfalta = 'true' Then 1
		  else 0
	   end as enfalta

	  ,dbo.empresas.nro_serie  -- empresas
	  ,dbo.t_tipo_entidad.id_tipo_entidad -- DER
	  ,dbo.t_provincia.id_provincia  -- DER 
      ,dbo.t_estado.id_estado -- DER
	  ,dbo.empresas.tipo_entidad
	  ,dbo.empresas.cod_prov
FROM dbo.empresas,
     dbo.t_tipo_entidad,
	 dbo.t_provincia,
	 dbo.t_estado
Where 
    -- join empresas y tipo entidad
	dbo.empresas.tipo_entidad = dbo.t_tipo_entidad.codigo_entidad
	-- join entre empresas y provincia
	and dbo.empresas.cod_prov = dbo.t_provincia.cod_prov
	-- join entre empresas y estado 
	and dbo.empresas.estado = dbo.t_estado.codigo_estado
	and dbo.empresas.razon_soc not like '(%)%'


CREATE TABLE [t_domicilio]
(
 [id_domicilio] Int IDENTITY NOT NULL,
 [descripcion] Varchar(250) NOT NULL,
 [codigo_postal] Varchar(15) NULL,
 [id_empresa] Int not NULL,
 [id_localidad] Int not NULL
)

INSERT INTO dbo.t_domicilio(descripcion, codigo_postal, id_empresa, id_localidad)
select isnull(dbo.empresas.domicilio,'Sin Calle'), 
       dbo.empresas.codpostal, 
	   dbo.t_empresa.id_empresa,
	   dbo.t_localidad.id_localidad
from dbo.empresas, 
     dbo.t_empresa,
	 dbo.t_localidad
where dbo.empresas.nro_serie = dbo.t_empresa.nro_serie
	and dbo.empresas.tipo_entidad = dbo.t_empresa.tipo_cod_entidad
	and dbo.empresas.cod_prov = dbo.t_empresa.cod_prov
	and dbo.empresas.cod_local = dbo.t_localidad.cod_local
	



CREATE TABLE dbo.t_contacto
(
 [id_contacto] Int IDENTITY NOT NULL,
 [descripcion] Varchar(150) NOT NULL,
 [tipo] Char(1) NOT NULL,
 [id_empresa] Int not NULL
)

--cargo los telefonos
insert into dbo.t_contacto(descripcion, tipo, id_empresa)
select dbo.empresas.telefono, 'T' , dbo.t_empresa.id_empresa
from dbo.empresas,  dbo.t_empresa
Where telefono is not null
    and len(telefono) > 5	
	and dbo.empresas.nro_serie = dbo.t_empresa.nro_serie
	and dbo.empresas.cod_prov = dbo.t_empresa.cod_prov
	and dbo.empresas.tipo_entidad = dbo.t_empresa.tipo_cod_entidad

-- cargo los emails
insert into dbo.t_contacto(descripcion, tipo, id_empresa)
select dbo.empresas.mail, 'E' , dbo.t_empresa.id_empresa
from dbo.empresas,  dbo.t_empresa
Where mail is not null
    and len(mail) > 5	
	and dbo.empresas.nro_serie = dbo.t_empresa.nro_serie
	and dbo.empresas.cod_prov = dbo.t_empresa.cod_prov
	and dbo.empresas.tipo_entidad = dbo.t_empresa.tipo_cod_entidad
	

create view vw_empresa_detalle 
as
select
        te.id_empresa as id_empresa, 
        te.descripcion as tipo_entidad,
        e.nro_serie, prov.descripcion as provincia, 
        e.razon_social, e.cuit, e.fecha_cierre, e.fecha_inscripcion, e.enfalta,        
		es.descripcion as estado,
		do.descripcion as calle,
		do.codigo_postal 
FROM dbo.t_empresa e, 
     dbo.t_tipo_entidad te,
	 dbo.t_estado es,
	 dbo.t_domicilio do,
	 dbo.t_provincia prov
Where e.id_tipo_entidad = te.id_tipo_entidad
	and e.id_estado = es.id_estado
	and e.id_empresa = do.id_empresa
	and e.id_provincia = prov.id_provincia
order by 1,2,3


-- cantidad de empresa por tipo
select count(*), tipo_entidad
from vw_empresa_detalle
group by tipo_entidad
order by 1


-- cantidad de empresa por tipo y por provincia
select count(*), tipo_entidad, provincia
from vw_empresa_detalle
Where tipo_entidad in ('Cooperativa','Mutual')
group by tipo_entidad, provincia
order by 2,3





create view vw_domicilio_emp
as
Select 
      do.id_empresa,
      do.descripcion, do.codigo_postal, 
      l.descripcion as localidad,
	  par.descripcion as partido,
	  prov.descripcion as provincia
From dbo.t_domicilio do,
	dbo.t_localidad l,
	dbo.t_partido par,
	dbo.t_provincia prov
Where do.id_localidad = l.id_localidad
	and l.id_partido = par.id_partido
	and par.id_provincia = prov.id_provincia
	
	
select *
from vw_empresa_detalle emp,
     vw_domicilio_emp doc
Where emp.id_empresa = doc.id_empresa

-- debemos arreglar la carga de la tabla t_domicilio
--  tenemos que crear las FK de todas las tablas
```

