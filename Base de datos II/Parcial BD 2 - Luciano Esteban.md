#parcial_1


Normalización


Poblarla


Nombres tablas
Nombre índices
Ver PKs



Armar consultas sobre tablas de BDs y de las tablas normalizadas



---

![[Pasted image 20250930184125.png]]




Hasta las 20:30, 20:45


Trampa en las fechas

---

Enviar solo:
- script_apellido.sql


---



1- Conectarse a sus base de datos

181.209.84.39:41433

2- bajar csv de acuerdo a su tema.

3- deben crear las tablas normalizadas y popularla

4- La cantidad minima de tablas a crear deben ser 4. 

5- todas los objetos de base de datos deben estar creados segun estandares 

6- Crear un o varios consultas o join entre 3 o mas tablas. Estas consultas deberan ser subidas en un archivo script_apellido.sql 



---


# Comienzo

```sql
SELECT TOP (1000) [persona]
      ,[apellido]
      ,[nombres]
      ,[apellido_nombres]
      ,[apellido_elegido]
      ,[nombres_elegido]
      ,[apellido_nombres_elegido]
      ,[sexo]
      ,[nacionalidad]
      ,[usuario]
      ,[documento]
      ,[nro_documento]
      ,[tipo_documento]
      ,[desc_tipo_documento]
      ,[tipo_nro_documento]
      ,[id_imagen]
  FROM [practica_clase].[dbo].[parcial_personas]
```


![[Pasted image 20250930192810.png]]


