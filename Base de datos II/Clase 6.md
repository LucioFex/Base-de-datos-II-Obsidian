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

