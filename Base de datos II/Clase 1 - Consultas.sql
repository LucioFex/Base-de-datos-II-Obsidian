/* PASO 1 ------------- Informacion de Server -----------*/
SELECT @@servername /* variable global con nombre del server */

SELECT *
FROM master.dbo.sysservers   /* Consulta a tabla sysservers */


/* --------------- sp_helpserver -------------------------------
Presenta información acerca de un servidor remoto o de
duplicación concreto, o acerca de todos los servidores de los dos tipos.
----------------------------------------------------------------*/
sp_helpserver


/* ----------------------- sp_server_info    ------------------------------------------------
 Devuelve una lista de nombres de atributos y valores coincidentes para Microsoft® SQL Server™,
   la puerta de enlace de la base de datos o bien el origen de datos subyacente.
Sintaxis
-------
sp_server_info [[@attribute_id =] 'attribute_id']
--------------------------------------------------------------------------------------------*/

sp_server_info


/* PASO 2 ----- Informacion de Base de Datos del Server ------*/

/* -------------------------- sp_helpdb --------------------------------
Presenta información acerca de una base de datos especificada o de todas las bases de datos.

Sintaxis
sp_helpdb [ [ @dbname= ] 'name' ]
-----------------------------------------------------------------------*/
sp_helptext sp_helpdb
/******************************************************************************************
Descripción de Resultados
-------------------------

name    : Nombre de base de datos.
db_size : Tamaño total de la base de datos.
owner   : Propietario de la base de datos (como sa).
dbid    : Id. numérico de la base de datos.
created : Fecha de creación de la base de datos.
status  : Lista de valores separados por comas de las opciones actuales de la base de datos.
          Las opciones de valores Booleanos aparecen solamente si están habilitadas.
          Las opciones no Booleanas aparecen listadas con los valores correspondientes en la forma option_name=value.



name          db_size owner   dbid    created     status
------------- ------- ------- ------- ----------- ------------------------------------------
master        10.81 MB sa      1      Nov 13 1998 trunc. log on chkpt.
model         1.50 MB  sa      3      Oct  9 2003 SELECT into/bulkcopy, trunc. log on chkpt.
msdb          8.75 MB  sa      4      Oct  9 2003 SELECT into/bulkcopy, trunc. log on chkpt.
tempdb        8.50 MB  sa      2      Oct  9 2003 SELECT into/bulkcopy, trunc. log on chkpt.
Northwind     3.94 MB  sa      6      Oct  9 2003 SELECT into/bulkcopy, trunc. log on chkpt.
pubs          2.05 MB  sa      5      Oct  9 2003 SELECT into/bulkcopy, trunc. log on chkpt.

SELECT into/bulkcopy : Con el valor TRUE, se permiten la instrucción SELECT INTO y las copias masivas rápidas.

*******************************************************************************************/


SELECT ID = dbid, Name_DB = name,Fecha = crdate,Dispositivo = filename
FROM master.dbo.sysdatabases


/* PASO 2 ------------ Dispositivos --------*/

 /*------------------------- sp_helpdevice -----------------------------
 sp_helpdevice presenta información acerca del dispositivo de base de
 datos o de descarga especificado. Si no se especifica el argumento name,
 sp_helpdevice presenta información acerca de todos los dispositivos de
 base de datos y de descarga de master.dbo.sysdevices.
 ----------------------------------------------------------------------*/
sp_helpdevice

/*********************************************************************************************
RESULTADOS
device_name   : Nombre del dispositivo (o nombre del archivo).
physical_name : Nombre del archivo físico.
description   : Descripción del dispositivo
size          : Tamaño del dispositivo en páginas de 2 KB.

device_name  physical_name               description                     status  cntrltype size
------------ --------------------------- ------------------------------- ------- --------- ----
master       C:\MSSQL7\DATA\MASTER.MDF   special, physical disk, 4 MB    2       0         512
mastlog      C:\MSSQL7\DATA\MASTLOG.LDF  special, physical disk, 0.8 MB  2       0         96
modeldev     C:\MSSQL7\DATA\MODEL.MDF    special, physical disk, 0.6 MB  2       0         80
modellog     C:\MSSQL7\DATA\MODELLOG.LDF special, physical disk, 0.8 MB  2       0         96
tempdev      C:\MSSQL7\DATA\TEMPDB.MDF   special, physical disk, 2 MB    2       0         256
templog      C:\MSSQL7\DATA\TEMPLOG.LDF  special, physical disk, 0.5 MB  2       0         64
*********************************************************************************************/

SELECT *
FROM master.dbo.Sysdevices



/* PASO 3 --- CONSULTA SOBRE TABLAS sysobjects , suscolumns , systype --------*/


SELECT id, name                /* Recupero Datos id, name */
FROM sysobjects o              /* de tabla de usuario     */
WHERE o.name = 'Employees'     /* Employees               */

SELECT id, name, xtype         /* Recupero Datos id, name  de tabla del sistema   */
FROM syscolumns                /* sobre estructura de columnas de tabla Employees */
WHERE id = 117575457           /* utilizando id recuperado de consulta anterior   */

SELECT name                    /* Recupero Datos xtype de tabla del sistema   */
FROM systypes                  /* sobre tipo de datos que contiene una columna */
WHERE xtype = 56               /* de la tabla Employees                        */



SELECT 	O.name, c.name,t.name,c.prec,c.scale,c.isnullable
FROM	sysobjects o,
	syscolumns c,
	systypes t
WHERE	o.id =  object_id('CustOrdersOrders') AND
	o.id = c.id AND
	c.xtype = t.xtype



SELECT *             
FROM systypes           
WHERE xtype = 56        


 /*-------------------------------------------------------------------------
 Consulta sobre las tres tablas del sistema para recuperar datos de la tabla
 del usuario Employees
 -------------------------------------------------------------------------*/
Select *
from sysobjects
Where 


SELECT 	O.name, c.name,t.name,c.prec,c.scale,c.isnullable
FROM	sysobjects o,
	syscolumns c,
	systypes t
WHERE	o.name = 'Employees' AND
	o.id = c.id AND
	c.xtype = t.xtype

/* Devuelve la lista de los objetos que se pueden consultar en el entorno actual */
sp_tables Employees        /* Informacion de tabla Employees */

/* Presenta información acerca de un objeto de la base de datos (cualquier objeto de la tabla sysobjects) */
sp_help Employees          /* Informacion General de Tabla Employees */

/* Devuelve información acerca de los índices de una tabla o vista */
sp_helpindex Employees     /* Informacion sobre indices de Tabla Employees */


/* Muestra el número de filas, el espacio de disco reservado y el espacio de disco que utiliza
 una tabla de la base de datos actual o bien muestra el espacio de disco reservado y
  el que utiliza la base de datos completa.*/
sp_help sp_spaceused Employees     /* Informacion de Espacio Usado en Tabla Categories */



SELECT *                   /* Informacion que contiene Tabla Categories */
FROM Categories 


/* PASO 4------- Texto de Procedimientos Almacenados -----------*/
/* Listado de Procedimientos */
SELECT name, crdate, id
FROM sysobjects
Where type = 'U'
Order By name

/* Texto del Procedimiento */
SELECT text
FROM syscomments
Where id = object_id('CustOrdersOrders')



/* ----------------------------- sp_helptext -------------------------------------------
 Imprime el texto de una regla, un valor predeterminado o un procedimiento almacenado,
 función definida por el usuario, desencadenador o vista no cifrados.
 -------------------------------------------------------------------------------------*/
sp_helptext CustOrdersOrders

select convert(VARCHAR(256), text) text
from sysobjects s, syscomments t
where s.id = t.id
and s.name = 'CustOrdersOrders'
and s.type = 'P'

/*------------- sp_depends --------------------
Muestra información acerca de las
dependencias de los objetos de la base de datos

Sintaxis : sp_depends [ @objname = ] 'object'
--------------------------------------------*/
sp_helptext sp_depends 
sp_depends CustOrdersOrders
sp_depends Products

/* solo para procedimientos */
	select		 'name' = substring((s6.name+ '.' + o1.name), 1, 40),
			 type = substring(v2.name, 5, 16),
			 updated = substring(u4.name, 1, 7),
			 selected = substring(w5.name, 1, 8),
             'column' = col_name(d3.depid, d3.depnumber)
		from	 sysobjects		o1
			,master.dbo.spt_values	v2
			,sysdepends		d3
			,master.dbo.spt_values	u4
			,master.dbo.spt_values	w5 --11667
			,sysusers		s6
		where	 o1.id = d3.depid
		and	 o1.xtype = substring(v2.name,1,2) and v2.type = 'O9T'
		and	 u4.type = 'B' and u4.number = d3.resultobj
		and	 w5.type = 'B' and w5.number = d3.readobj|d3.selall
		and	 d3.id = object_id('CustOrdersOrders')
		and	 o1.uid = s6.uid



/* solo  tablas */
/* Dependencias de Objetos */
SELECT 	distinct 'name' = substring((s.name + '.' + o.name), 1, 40),
	type = substring(v.name, 5, 16)
FROM 	sysobjects o, master.dbo.spt_values v, sysdepends d,
	sysusers s
WHERE 	o.id = d.id
	AND o.xtype = substring(v.name,1,2) and v.type = 'O9T'
	AND d.depid = object_id('Products')
	AND o.uid = s.uid
ORDER BY type



/* PASO 5 ---------- logines: informacion sobre logines --------------*/

SELECT suid,createdate,name,dbname,language,loginname
FROM master.dbo.Syslogins

SELECT *
FROM master.dbo.Sysusers


SELECT *
FROM	master.dbo.Sysusers u,
	master.dbo.Syslogins l
WHERE u.suid = l.suid


sp_helplogins
/*************************************************************************************
Proporciona información acerca de inicios de sesión y sus usuarios asociados en cada base de datos. 

suid   createdate                  name     dbname      password   language   loginname 
------ --------------------------- -------- ----------- ---------- ---------- ---------- 
1      1998-11-13 02:58:28.780     sa       master      NULL       Español    sa
6      2003-10-10 01:00:37.663     usuario  Northwind   ????????   Español    usuario
***************************************************************************************/


/* PASO 5 ------------ Informacion de los mensajes de usuario --------------*/
SELECT *
FROM sysmessages
where error = 108


/* PASO 6 ------------ Informacion de Grupos -----------------*/
sp_helpgroup
sp_helpntgroup



/* PASO 7 ------------------------ sp_who ----------------------------------
Proporciona información acerca de los procesos y usuarios actuales de SQLServer.
La información obtenida puede filtrarse para devolver únicamente los procesos que no estén inactivos.
----------------------------------------------------------------------------*/
sp_who

/*
spid   status                         loginame                                                                                                                         hostname                                                                                                                         blk   dbname                                                                                                                           cmd              
------ ------------------------------ -------------------------------------------------------------------------------------------------------------------------------- -------------------------------------------------------------------------------------------------------------------------------- ----- -------------------------------------------------------------------------------------------------------------------------------- ---------------- 
1      sleeping                       sa                                                                                                                                                                                                                                                                0     master                                                                                                                           SIGNAL HANDLER  
2      background                     sa                                                                                                                                                                                                                                                                0     Northwind                                                                                                                        LOCK MONITOR    
3      background                     sa                                                                                                                                                                                                                                                                0     Northwind                                                                                                                        LAZY WRITER     
4      sleeping                       sa                                                                                                                                                                                                                                                                0     Northwind                                                                                                                        LOG WRITER      
5      sleeping                       sa                                                                                                                                                                                                                                                                0     Northwind                                                                                                                        CHECKPOINT SLEEP
6      background                     sa                                                                                                                                                                                                                                                                0     Northwind                                                                                                                        AWAITING COMMAND
7      runnable                       sa                                                                                                                               C_WALTER                                                                                                                         0     Northwind                                                                                                                        SELECT
8      sleeping                       sa                                                                                                                               C_WALTER                                                                                                                         0     master                                                                                                                           AWAITING COMMAND
*/

/* PASO 5 ------------  Informacion de login conectados a Server -------------*/
sp_who2
/*
SPID  Status                         Login HostName                       BlkBy DBName    Command          CPUTime DiskIO LastBatch      ProgramName                    SPID  
----- ------------------------------ ----- ------------------------------ ----- --------- ---------------- ------- ------ -------------- ------------------------------ ----- 
1     sleeping                       sa      .                              .   master    SIGNAL HANDLER   0       0      10/09 23:07:19                                1
2     BACKGROUND                     sa      .                              .   Northwind LOCK MONITOR     0       0      10/09 23:07:19                                2    
3     BACKGROUND                     sa      .                              .   Northwind LAZY WRITER      0       0      10/09 23:07:19                                3    
4     sleeping                       sa      .                              .   Northwind LOG WRITER       0       0      10/09 23:07:19                                4    
5     sleeping                       sa      .                              .   Northwind CHECKPOINT SLEEP 0       0      10/09 23:07:19                                5    
6     BACKGROUND                     sa      .                              .   Northwind AWAITING COMMAND 0       177    10/09 23:07:19                                6    
7     RUNNABLE                       sa    C_WALTER                         .   Northwind SELECT INTO      0       1573   10/10 01:37:43 MS SQL Query Analyzer          7    
8     sleeping                       sa    C_WALTER                         .   master    AWAITING COMMAND 0       233    10/10 01:00:40 MS SQLEM                       8    
*/

