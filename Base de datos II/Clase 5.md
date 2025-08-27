#clase_5


Arranca con el DER

![[Pasted image 20250826190126.png]]

Parcial:
- Tabla desnormalizada
- Armarmos DER normalizado
- Poblar datos normalizados


![[Pasted image 20250826190541.png]]

![[Pasted image 20250826190545.png]]

---



Dos tablas nuevas
- Sala 1:
	- Tabla de domicilio
	- Consideración: Una empresa puede tener varios domicilios


![[Pasted image 20250826194738.png]]
![[Pasted image 20250826194741.png]]
![[Pasted image 20250826195154.png]]



---

```sql
INSERT INTO dbo.t_localidad(descripcion,id_partido,cod_local)
select distinct localidad, dbo.t_partido.id_partido, cod_local  
From dbo.empresas,
	dbo.t_partido
Where 
	dbo.empresas.cod_partido = dbo.t_partido.codigo_partido
	and dbo.empresas.cod_local is not null 
	and dbo.empresas.localidad is not null
```


![[Pasted image 20250826201214.png]]
![[Pasted image 20250826202242.png]]
![[Pasted image 20250826203801.png]]
![[Pasted image 20250826221205.png]]
![[Pasted image 20250826222210.png]]