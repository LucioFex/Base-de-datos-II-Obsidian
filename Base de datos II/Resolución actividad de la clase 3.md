#clase_3 


```sql
USE lesteban25;

/* 0. TABLAS ORIGINALES (clase 3)  */

CREATE TABLE dbo.cge_tipo_producto (
    id INT IDENTITY(1,1),
    descripcion VARCHAR(50) NOT NULL,
    CONSTRAINT pk_cge_tipo_producto PRIMARY KEY (id)
);

CREATE TABLE dbo.cge_marca (
    id INT IDENTITY(1,1),
    descripcion VARCHAR(50) NOT NULL,
    CONSTRAINT pk_cge_marca PRIMARY KEY (id)
);

CREATE TABLE dbo.cge_producto (
    id_producto INT IDENTITY(1,1),
    descripcion VARCHAR(25) NOT NULL,
    precio NUMERIC(15, 2) NULL,
    id_tipo_producto INT NOT NULL,
    marca_id INT NOT NULL,
    CONSTRAINT pk_cge_producto PRIMARY KEY (id_producto),
    CONSTRAINT fk_cge_producto_cge_tipo_producto FOREIGN KEY (id_tipo_producto) REFERENCES dbo.cge_tipo_producto(id),
    CONSTRAINT fk_cge_producto_cge_marca FOREIGN KEY (marca_id) REFERENCES dbo.cge_marca(id)
);

/* 1. TABLAS DE INFRAESTRUCTURA Y UBICACIÓN GEOGRÁFICA  */

-- Tabla para almacenar las subestaciones eléctricas.
CREATE TABLE dbo.cge_subestacion (
    id INT IDENTITY(1,1),
    codigo_subestacion VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    ubicacion_geografica VARCHAR(255) NULL,
    capacidad_mva DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_cge_subestacion PRIMARY KEY (id)
);

-- Tabla para los alimentadores (líneas principales) que salen de cada subestación.
CREATE TABLE dbo.cge_alimentador (
    id INT IDENTITY(1,1),
    codigo_alimentador VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    id_subestacion INT NOT NULL,
    voltaje_kv DECIMAL(6, 2) NOT NULL,
    CONSTRAINT pk_cge_alimentador PRIMARY KEY (id),
    CONSTRAINT fk_cge_alimentador_cge_subestacion FOREIGN KEY (id_subestacion) REFERENCES dbo.cge_subestacion(id)
);

-- Tabla para los postes o estructuras que soportan las líneas.
CREATE TABLE dbo.cge_poste (
    id INT IDENTITY(1,1),
    numero_identificacion VARCHAR(30) NOT NULL UNIQUE,
    id_alimentador INT NOT NULL,
    material VARCHAR(50) CHECK (material IN ('Madera', 'Concreto', 'Metálico')),
    altura_m DECIMAL(5, 2) NULL,
    coordenadas_gps VARCHAR(100) NULL,
    fecha_instalacion DATE NULL,
    CONSTRAINT pk_cge_poste PRIMARY KEY (id),
    CONSTRAINT fk_cge_poste_cge_alimentador FOREIGN KEY (id_alimentador) REFERENCES dbo.cge_alimentador(id)
);

-- Tabla que representa un transformador específico (un producto) instalado en un poste.
CREATE TABLE dbo.cge_transformador_instalado (
    id INT IDENTITY(1,1),
    numero_serie VARCHAR(50) NOT NULL UNIQUE,
    id_producto INT NOT NULL,
    id_poste INT NOT NULL,
    potencia_kva INT NOT NULL,
    fase VARCHAR(20) CHECK (fase IN ('Monofásico', 'Trifásico')),
    fecha_instalacion DATE NOT NULL,
    CONSTRAINT pk_cge_transformador_instalado PRIMARY KEY (id),
    CONSTRAINT fk_cge_transformador_instalado_cge_producto FOREIGN KEY (id_producto) REFERENCES dbo.cge_producto(id_producto),
    CONSTRAINT fk_cge_transformador_instalado_cge_poste FOREIGN KEY (id_poste) REFERENCES dbo.cge_poste(id)
);

/* 2. TABLA CLAVE: SISTEMA DE CABLES POR PROGRESIVA  */

-- Modela los tramos de cable a lo largo de un alimentador usando 'progresivas'.
CREATE TABLE dbo.cge_tramo_cable_progresiva (
    id INT IDENTITY(1,1),
    id_alimentador INT NOT NULL,
    id_producto_cable INT NOT NULL,
    progresiva_inicio_m INT NOT NULL,
    progresiva_fin_m INT NOT NULL,
    id_poste_origen INT NOT NULL,
    id_poste_destino INT NOT NULL,
    fecha_tendido DATE NOT NULL,
    CONSTRAINT pk_cge_tramo_cable_progresiva PRIMARY KEY (id),
    CONSTRAINT fk_cge_tramo_cable_progresiva_cge_alimentador FOREIGN KEY (id_alimentador) REFERENCES dbo.cge_alimentador(id),
    CONSTRAINT fk_cge_tramo_cable_progresiva_cge_producto FOREIGN KEY (id_producto_cable) REFERENCES dbo.cge_producto(id_producto),
    CONSTRAINT fk_cge_tramo_cable_progresiva_cge_poste_origen FOREIGN KEY (id_poste_origen) REFERENCES dbo.cge_poste(id),
    CONSTRAINT fk_cge_tramo_cable_progresiva_cge_poste_destino FOREIGN KEY (id_poste_destino) REFERENCES dbo.cge_poste(id),
    CONSTRAINT CHK_progresiva CHECK (progresiva_fin_m > progresiva_inicio_m)
);

/* 3. TABLAS DE CLIENTES Y SUMINISTRO  */

-- Tabla para almacenar la información de los clientes.
CREATE TABLE dbo.cge_cliente (
    id INT IDENTITY(1,1),
    rut VARCHAR(12) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    direccion_facturacion VARCHAR(255) NOT NULL,
    email VARCHAR(100) NULL,
    telefono VARCHAR(20) NULL,
    CONSTRAINT pk_cge_cliente PRIMARY KEY (id)
);

-- Tabla para los puntos de suministro (medidores).
CREATE TABLE dbo.cge_punto_suministro (
    id INT IDENTITY(1,1),
    numero_cliente VARCHAR(20) NOT NULL UNIQUE,
    id_cliente INT NOT NULL,
    id_transformador_instalado INT NOT NULL,
    direccion_suministro VARCHAR(255) NOT NULL,
    tarifa VARCHAR(50) NOT NULL,
    fecha_conexion DATE NOT NULL,
    CONSTRAINT pk_cge_punto_suministro PRIMARY KEY (id),
    CONSTRAINT fk_cge_punto_suministro_cge_cliente FOREIGN KEY (id_cliente) REFERENCES dbo.cge_cliente(id),
    CONSTRAINT fk_cge_punto_suministro_cge_transformador_instalado FOREIGN KEY (id_transformador_instalado) REFERENCES dbo.cge_transformador_instalado(id)
);

/* 4. TABLAS DE GESTIÓN DE TRABAJOS (ÓRDENES DE TRABAJO)  */

-- Tabla para las cuadrillas o equipos de trabajo en terreno.
CREATE TABLE dbo.cge_cuadrilla (
    id INT IDENTITY(1,1),
    nombre_cuadrilla VARCHAR(100) NOT NULL UNIQUE,
    especialidad VARCHAR(100) NULL,
    CONSTRAINT pk_cge_cuadrilla PRIMARY KEY (id)
);

-- Tabla para los empleados que pertenecen a las cuadrillas.
CREATE TABLE dbo.cge_empleado (
    id INT IDENTITY(1,1),
    rut VARCHAR(12) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    cargo VARCHAR(80) NOT NULL,
    id_cuadrilla INT NULL,
    CONSTRAINT pk_cge_empleado PRIMARY KEY (id),
    CONSTRAINT fk_cge_empleado_cge_cuadrilla FOREIGN KEY (id_cuadrilla) REFERENCES dbo.cge_cuadrilla(id)
);

-- Tabla para gestionar las órdenes de trabajo.
CREATE TABLE dbo.cge_orden_trabajo (
    id INT IDENTITY(1,1),
    descripcion_trabajo VARCHAR(500) NOT NULL,
    tipo_trabajo VARCHAR(50) NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('Pendiente', 'En Progreso', 'Completada', 'Cancelada')),
    fecha_creacion DATETIME DEFAULT GETDATE(),
    fecha_cierre DATETIME NULL,
    id_punto_suministro INT NULL,
    id_poste INT NULL,
    id_cuadrilla_asignada INT NULL,
    CONSTRAINT pk_cge_orden_trabajo PRIMARY KEY (id),
    CONSTRAINT fk_cge_orden_trabajo_cge_punto_suministro FOREIGN KEY (id_punto_suministro) REFERENCES dbo.cge_punto_suministro(id),
    CONSTRAINT fk_cge_orden_trabajo_cge_poste FOREIGN KEY (id_poste) REFERENCES dbo.cge_poste(id),
    CONSTRAINT fk_cge_orden_trabajo_cge_cuadrilla FOREIGN KEY (id_cuadrilla_asignada) REFERENCES dbo.cge_cuadrilla(id)
);

/* 5. CREACIÓN DE ÍNDICES PARA MEJORAR EL RENDIMIENTO  */

-- Índices para tablas originales
CREATE NONCLUSTERED INDEX idx_cge_producto_id_tipo_producto ON dbo.cge_producto(id_tipo_producto);
CREATE NONCLUSTERED INDEX idx_cge_producto_marca_id ON dbo.cge_producto(marca_id);

-- Índices para tablas de infraestructura
CREATE NONCLUSTERED INDEX idx_cge_alimentador_id_subestacion ON dbo.cge_alimentador(id_subestacion);
CREATE NONCLUSTERED INDEX idx_cge_poste_id_alimentador ON dbo.cge_poste(id_alimentador);
CREATE NONCLUSTERED INDEX idx_cge_transformador_instalado_id_producto ON dbo.cge_transformador_instalado(id_producto);
CREATE NONCLUSTERED INDEX idx_cge_transformador_instalado_id_poste ON dbo.cge_transformador_instalado(id_poste);

-- Índices para la tabla de tramos de cable
CREATE NONCLUSTERED INDEX idx_cge_tramo_cable_progresiva_id_alimentador ON dbo.cge_tramo_cable_progresiva(id_alimentador);
CREATE NONCLUSTERED INDEX idx_cge_tramo_cable_progresiva_id_producto_cable ON dbo.cge_tramo_cable_progresiva(id_producto_cable);

-- Índices para tablas de clientes y suministro
CREATE NONCLUSTERED INDEX idx_cge_punto_suministro_id_cliente ON dbo.cge_punto_suministro(id_cliente);
CREATE NONCLUSTERED INDEX idx_cge_punto_suministro_id_transformador_instalado ON dbo.cge_punto_suministro(id_transformador_instalado);

-- Índices para tablas de gestión
CREATE NONCLUSTERED INDEX idx_cge_empleado_id_cuadrilla ON dbo.cge_empleado(id_cuadrilla);
CREATE NONCLUSTERED INDEX idx_cge_orden_trabajo_id_punto_suministro ON dbo.cge_orden_trabajo(id_punto_suministro);
CREATE NONCLUSTERED INDEX idx_cge_orden_trabajo_id_cuadrilla_asignada ON dbo.cge_orden_trabajo(id_cuadrilla_asignada);


/* 6. REINICIO DE SECUENCIAS DE IDENTIDAD (OPCIONAL, PERO RECOMENDADO)  */

-- Se eliminan los datos existentes para evitar duplicados y conflictos de PK.
-- NOTA: El orden de eliminación es el inverso al de creación para respetar las FK.
DELETE FROM dbo.cge_orden_trabajo;
DELETE FROM dbo.cge_empleado;
DELETE FROM dbo.cge_cuadrilla;
DELETE FROM dbo.cge_punto_suministro;
DELETE FROM dbo.cge_cliente;
DELETE FROM dbo.cge_tramo_cable_progresiva;
DELETE FROM dbo.cge_transformador_instalado;
DELETE FROM dbo.cge_poste;
DELETE FROM dbo.cge_alimentador;
DELETE FROM dbo.cge_subestacion;
DELETE FROM dbo.cge_producto;
DELETE FROM dbo.cge_tipo_producto;
DELETE FROM dbo.cge_marca;

-- Reseteamos los contadores a 0. La próxima inserción comenzará en 1.
DBCC CHECKIDENT ('dbo.cge_orden_trabajo', RESEED, 0);
DBCC CHECKIDENT ('dbo.cge_empleado', RESEED, 0);
DBCC CHECKIDENT ('dbo.cge_cuadrilla', RESEED, 0);
DBCC CHECKIDENT ('dbo.cge_punto_suministro', RESEED, 0);
DBCC CHECKIDENT ('dbo.cge_cliente', RESEED, 0);
DBCC CHECKIDENT ('dbo.cge_tramo_cable_progresiva', RESEED, 0);
DBCC CHECKIDENT ('dbo.cge_transformador_instalado', RESEED, 0);
DBCC CHECKIDENT ('dbo.cge_poste', RESEED, 0);
DBCC CHECKIDENT ('dbo.cge_alimentador', RESEED, 0);
DBCC CHECKIDENT ('dbo.cge_subestacion', RESEED, 0);
DBCC CHECKIDENT ('dbo.cge_producto', RESEED, 0);
DBCC CHECKIDENT ('dbo.cge_tipo_producto', RESEED, 0);
DBCC CHECKIDENT ('dbo.cge_marca', RESEED, 0);


/* 7. INSERCIÓN DE DATOS EN TABLAS MAESTRAS (SIN DEPENDENCIAS)  */

-- Tipos de Producto
INSERT INTO dbo.cge_tipo_producto (descripcion) VALUES
('Cable Eléctrico'),
('Transformador'),
('Medidor'),
('Aislador'),
('Poste');

-- Marcas
INSERT INTO dbo.cge_marca (descripcion) VALUES
('Prysmian Group'),
('Nexans'),
('ABB'),
('Siemens'),
('Schneider Electric'),
('Landis+Gyr'),
('3M'),
('Eaton'),
('Legrand'),
('General Cable'),
('Hubbell');

-- Productos (Combinación de tipos y marcas)
INSERT INTO dbo.cge_producto (descripcion, precio, id_tipo_producto, marca_id) VALUES
-- Productos requeridos por FK en el script
('Cable Cu 1/0 AWG', 15000.00, 1, 1), -- ID 1 para tramo_cable
('Cable Al 3/0 AWG', 12500.50, 1, 2), -- ID 2 para tramo_cable
('Transformador 75kVA', 2500000.00, 2, 3), -- ID 3 para transformador_instalado
('Transformador 50kVA', 1800000.00, 2, 4), -- ID 4 para transformador_instalado
-- Productos adicionales para llegar a 100
('Medidor Monofásico Dig.', 25000.00, 3, 6),
('Medidor Trifásico Digital', 75000.00, 3, 5),
('Aislador Polim. 15kV', 8000.00, 4, 3),
('Poste Concreto 12m', 350000.00, 5, 2),
('Cable Cu 4/0 AWG', 22000.00, 1, 1),
('Transformador 25kVA', 1200000.00, 2, 4),
('Aislador Vidrio 23kV', 9500.00, 4, 5),
('Poste Madera 11m', 280000.00, 5, 1),
('Medidor Smart Trifásico', 95000.00, 3, 6),
('Cinta Aislante Goma', 3500.00, 4, 7),
('Interruptor Termo.', 15000.00, 3, 8),
('Canaleta PVC 20x10', 2500.00, 5, 9),
('Cable UTP Cat 6', 800.00, 1, 10),
('Conector Perno Partido', 4500.00, 4, 11),
('Transformador 100kVA', 3500000.00, 2, 3),
('Medidor Smart Mono.', 65000.00, 3, 6),
('Aislador Loza 15kV', 6000.00, 4, 9),
('Poste Metálico 10m', 450000.00, 5, 8),
('Cable Al 2/0 AWG', 9800.00, 1, 2),
('Transformador 15kVA', 950000.00, 2, 4),
('Caja Empalme BT', 12000.00, 5, 5),
('Fusible NH-00 100A', 7800.00, 4, 8),
('Cable Cu 2 AWG', 9500.00, 1, 1),
('Transformador Seco 150kVA', 5000000.00, 2, 3),
('Medidor Prepago Digital', 85000.00, 3, 6),
('Amarracable Plástica', 100.00, 4, 7),
('Poste Fibra Vidrio 9m', 600000.00, 5, 11),
('Cable Alumocobre 6mm2', 1200.00, 1, 10),
('Seccionador fusible 15kV', 150000.00, 4, 8),
('Transformador 37.5kVA', 1500000.00, 2, 4),
('Medidor Horario', 120000.00, 3, 5),
('Aislador Suspensión', 11000.00, 4, 11),
('Cruceta Metálica 1.5m', 25000.00, 5, 9),
('Cable THHN 12 AWG', 600.00, 1, 2),
('Transformador Pedestal', 4000000.00, 2, 3),
('Terminal Ojo Cobre', 1500.00, 4, 7),
('Poste Concreto 9m', 300000.00, 5, 2),
('Cable RV-K 3x1.5mm2', 900.00, 1, 1),
('Reconectador 23kV', 8000000.00, 2, 8),
('Medidor Bidireccional', 150000.00, 3, 6),
('Pararrayos Polimérico', 90000.00, 4, 11),
('Cable Cu Desnudo 8 AWG', 1300.00, 1, 10),
('Transformador Rural 10kVA', 850000.00, 2, 4),
('Gabinete Medidor', 35000.00, 5, 9),
('Conector Cuña', 3000.00, 4, 7),
('Cable EVA 1.5mm2', 750.00, 1, 1),
('Poste Madera 9m', 250000.00, 5, 1),
('Aislador Espiga', 5500.00, 4, 3),
('Medidor Monofásico Elect.', 18000.00, 3, 5),
('Transformador 150kVA', 4500000.00, 2, 3),
('Cable Al Preensamblado', 3500.00, 1, 2),
('Portafusible Cutout', 45000.00, 4, 8),
('Poste Concreto 10.5m', 320000.00, 5, 2),
('Medidor Trifásico Elect.', 60000.00, 3, 5),
('Transformador 250kVA', 6000000.00, 2, 4),
('Cable XTU 12kV', 25000.00, 1, 1),
('Aislador Carretel', 1200.00, 4, 9),
('Poste Madera 13m', 350000.00, 5, 1),
('Medidor Smart Plus', 110000.00, 3, 6),
('Transformador 300kVA', 7500000.00, 2, 3),
('Cable NYY 3x4mm2', 1800.00, 1, 2),
('Aislador Line Post', 25000.00, 4, 11),
('Poste Metálico 12m', 500000.00, 5, 8),
('Medidor Tarifa Simple', 22000.00, 3, 5),
('Transformador 500kVA', 12000000.00, 2, 4),
('Cable ACSR 2/0', 8500.00, 1, 10),
('Aislador Shackle', 1500.00, 4, 9),
('Poste Madera Tratada 12m', 310000.00, 5, 1),
('Medidor con Modem GPRS', 180000.00, 3, 6),
('Transformador 750kVA', 18000000.00, 2, 3),
('Cable Superastic Flex', 1100.00, 1, 1),
('Aislador Pin Polimérico', 18000.00, 4, 11),
('Poste Concreto 13.5m', 400000.00, 5, 2),
('Medidor Doble Tarifa', 88000.00, 3, 5),
('Transformador 1000kVA', 25000000.00, 2, 4),
('Cable TTU 2kV', 19000.00, 1, 10),
('Aislador Anclaje', 7000.00, 4, 9),
('Poste Metálico Galvaniz.', 550000.00, 5, 8),
('Medidor Telegestionado', 250000.00, 3, 6),
('Transformador 1.5MVA', 35000000.00, 2, 3),
('Cable FPLR Incendio', 1500.00, 1, 10),
('Aislador Suspensión Pol.', 22000.00, 4, 11),
('Poste Ornamental', 700000.00, 5, 9),
('Medidor Concentrador', 500000.00, 3, 6),
('Transformador 2MVA', 50000000.00, 2, 4),
('Cable N2XSY 18/30kV', 35000.00, 1, 1),
('Aislador Estación', 150000.00, 4, 3),
('Poste Tubular Acero', 650000.00, 5, 8),
('Medidor Calidad Energía', 1200000.00, 3, 5);

-- Subestaciones
INSERT INTO dbo.cge_subestacion (codigo_subestacion, nombre, ubicacion_geografica, capacidad_mva) VALUES
('SE-VAL-01', 'Subestación Valdivia Centro', 'Av. Alemania 650, Valdivia', 50.00),
('SE-OSO-01', 'Subestación Osorno Rahue', 'Ruta U-40, Osorno', 75.50),
('SE-PMO-01', 'Subestación Puerto Montt El Tepual', 'Camino al Aeropuerto, Puerto Montt', 100.00),
('SE-TEM-01', 'Subestación Temuco Norte', 'Av. Rudecindo Ortega, Temuco', 80.00),
('SE-PVA-01', 'Subestación Puerto Varas', 'Ruta 5 Sur, Puerto Varas', 60.00),
('SE-LNC-01', 'Subestación Loncoche', 'Panamericana Sur Km 750, Loncoche', 40.00),
('SE-ANC-01', 'Subestación Ancud', 'Cruce a Chacao, Ancud', 55.00);

-- Clientes
INSERT INTO dbo.cge_cliente (rut, nombre, apellido, direccion_facturacion, email, telefono) VALUES
('15.123.456-7', 'Juan', 'Pérez González', 'Arturo Prat 555, Valdivia', 'juan.perez@email.com', '+56911112222'),
('18.987.654-3', 'María', 'Soto Rodriguez', 'Eleuterio Ramírez 1020, Osorno', 'maria.soto@email.com', '+56933334444'),
('12.345.678-9', 'Carlos', 'Muñoz Flores', 'Av. Presidente Ibáñez 850, Puerto Montt', 'carlos.munoz@email.com', '+56955556666'),
('14.888.999-0', 'Laura', 'García López', 'San Martín 234, Temuco', 'laura.garcia@email.com', '+56977778888'),
('17.555.444-K', 'Roberto', 'Fernández Soto', 'Del Salvador 72, Puerto Varas', 'roberto.f@email.com', '+56999990000'),
('10.111.222-3', 'Patricia', 'Martinez Rojas', 'Los Robles 11, Isla Teja, Valdivia', 'patricia.m@email.com', '+56912123434'),
('20.432.123-4', 'Javier', 'Silva Acosta', 'Guillermo Bühler 1800, Osorno', 'javier.silva@email.com', '+56956567878'),
('13.678.901-2', 'Daniela', 'Castro Vega', 'Caupolicán 120, Temuco', 'daniela.castro@email.com', '+56934345656'),
('16.777.888-9', 'Andrés', 'Rojas Morales', 'Arturo Prat 321, Loncoche', 'andres.rojas@email.com', '+56987654321'),
('19.123.456-K', 'Valentina', 'Gómez Soto', 'Pudeto 567, Ancud', 'valentina.gomez@email.com', '+56911223344'),
('11.222.333-4', 'Ricardo', 'Núñez Pérez', 'Pedro Montt 987, Puerto Montt', 'ricardo.nunez@email.com', '+56955667788'),
('15.444.555-6', 'Carolina', 'Vidal Flores', 'General Mackenna 432, Temuco', 'carolina.vidal@email.com', '+56999887766');

-- Cuadrillas
INSERT INTO dbo.cge_cuadrilla (nombre_cuadrilla, especialidad) VALUES
('Móvil Valdivia-01', 'Mantenimiento Media Tensión'),
('Móvil Osorno-01', 'Nuevas Conexiones'),
('Móvil PMO-Emergencia', 'Atención de Emergencias'),
('Móvil Temuco-01', 'Mantenimiento Subterráneo'),
('Móvil P. Varas-01', 'Inspección Aérea'),
('Contratista-TEC', 'Obras Civiles'),
('Móvil Valdivia-02', 'Poda y Despeje'),
('Móvil Loncoche-01', 'Mantenimiento Rural'),
('Móvil Ancud-01', 'Mantenimiento General'),
('Móvil Osorno-02', 'Mantenimiento BT');


/* 8. INSERCIÓN DE DATOS EN TABLAS DEPENDIENTES (NIVEL 1)  */

-- Alimentadores (Dependen de Subestación)
INSERT INTO dbo.cge_alimentador (codigo_alimentador, nombre, id_subestacion, voltaje_kv) VALUES
('ALM-VAL-CENTRO-01', 'Alimentador Centro', 1, 13.8),
('ALM-OSO-RAHUE-01', 'Alimentador Rahue Alto', 2, 23.0),
('ALM-PMO-TEPUAL-01', 'Alimentador Industrial', 3, 23.0),
('ALM-TEM-NORTE-01', 'Alimentador Las Encinas', 4, 13.8),
('ALM-PVA-LAGO-01', 'Alimentador Costanera', 5, 23.0),
('ALM-VAL-COSTA-01', 'Alimentador Niebla', 1, 13.8),
('ALM-LNC-RURAL-01', 'Alimentador Afquintúe', 6, 23.0),
('ALM-ANC-ISLA-01', 'Alimentador Lechagua', 7, 23.0),
('ALM-OSO-CENTRO-01', 'Alimentador Mackenna', 2, 13.8);

-- Empleados (Dependen de Cuadrilla)
INSERT INTO dbo.cge_empleado (rut, nombre, apellido, cargo, id_cuadrilla) VALUES
('16.222.333-4', 'Pedro', 'Aravena', 'Jefe de Cuadrilla', 1),
('17.333.444-5', 'Luis', 'Contreras', 'Liniero Eléctrico', 1),
('19.444.555-6', 'Ana', 'Gutierrez', 'Técnico Conexiones', 2),
('20.555.666-7', 'Sofia', 'Vergara', 'Prevencionista de Riesgos', 3),
('15.987.123-K', 'Diego', 'Reyes', 'Técnico Subterráneo', 4),
('18.123.987-6', 'Camila', 'Morales', 'Operador de Dron', 5),
('12.987.321-5', 'Miguel', 'Herrera', 'Maestro de Obras', 6),
('17.890.123-4', 'Valeria', 'Jiménez', 'Técnico Forestal', 7),
('21.111.222-K', 'Felipe', 'Navarro', 'Liniero Eléctrico', 2),
('14.321.654-9', 'Jorge', 'Bravo', 'Liniero Rural', 8),
('18.765.432-1', 'Fernanda', 'Díaz', 'Técnico General', 9),
('19.876.543-2', 'Matías', 'Cisterna', 'Técnico BT', 10);


/* 9. INSERCIÓN DE DATOS EN TABLAS DEPENDIENTES (NIVEL 2)  */

-- Postes (Dependen de Alimentador)
INSERT INTO dbo.cge_poste (numero_identificacion, id_alimentador, material, altura_m, coordenadas_gps, fecha_instalacion) VALUES
('P-VAL01-001', 1, 'Concreto', 12.0, '-39.8142, -73.2459', '2020-01-15'),
('P-VAL01-002', 1, 'Concreto', 12.0, '-39.8145, -73.2455', '2020-01-16'),
('P-VAL01-003', 1, 'Madera', 11.5, '-39.8148, -73.2451', '2019-11-20'),
('P-OSO01-001', 2, 'Concreto', 13.0, '-40.5717, -73.1352', '2021-05-10'),
('P-OSO01-002', 2, 'Concreto', 13.0, '-40.5720, -73.1348', '2021-05-11'),
('P-TEM01-001', 4, 'Concreto', 12.0, '-38.7359, -72.5904', '2022-02-20'),
('P-TEM01-002', 4, 'Concreto', 12.0, '-38.7355, -72.5900', '2022-02-21'),
('P-PVA01-001', 5, 'Metálico', 12.0, '-41.3205, -72.9845', '2023-01-30'),
('P-PVA01-002', 5, 'Metálico', 12.0, '-41.3209, -72.9840', '2023-01-31'),
('P-VAL02-001', 6, 'Madera', 11.5, '-39.8190, -73.3855', '2018-07-15'),
('P-VAL02-002', 6, 'Madera', 11.5, '-39.8195, -73.3860', '2018-07-16'),
('P-LNC01-001', 7, 'Madera', 11.5, '-39.3550, -72.6330', '2017-05-10'),
('P-LNC01-002', 7, 'Madera', 11.5, '-39.3555, -72.6335', '2017-05-11'),
('P-ANC01-001', 8, 'Concreto', 12.0, '-41.8670, -73.8200', '2020-09-01'),
('P-ANC01-002', 8, 'Concreto', 12.0, '-41.8675, -73.8205', '2020-09-02'),
('P-OSO02-001', 9, 'Concreto', 12.0, '-40.5730, -73.1500', '2021-11-20');

-- Transformadores Instalados (Dependen de Producto y Poste)
INSERT INTO dbo.cge_transformador_instalado (numero_serie, id_producto, id_poste, potencia_kva, fase, fecha_instalacion) VALUES
('ABB-T75-1001', 3, 2, 75, 'Trifásico', '2022-03-01'), -- Trafo de 75kVA en poste 2
('SIEM-T50-2002', 4, 5, 50, 'Trifásico', '2021-08-15'), -- Trafo de 50kVA en poste 5
('SIEM-T25-3001', 10, 7, 25, 'Trifásico', '2022-04-01'),
('ABB-T100-4001', 19, 9, 100, 'Trifásico', '2023-03-10'),
('SIEM-T15-5001', 24, 11, 15, 'Monofásico', '2019-01-20'),
('EATON-T37.5-6001', 32, 13, 37.5, 'Trifásico', '2018-01-15'),
('SCHN-T50-7001', 4, 15, 50, 'Trifásico', '2021-02-20'),
('ABB-T75-8001', 3, 16, 75, 'Trifásico', '2022-01-10');


/* 10. INSERCIÓN DE DATOS EN TABLAS DEPENDIENTES (NIVEL 3)  */

-- Tramos de Cable por Progresiva (Dependen de Alimentador, Producto y Postes)
INSERT INTO dbo.cge_tramo_cable_progresiva (id_alimentador, id_producto_cable, progresiva_inicio_m, progresiva_fin_m, id_poste_origen, id_poste_destino, fecha_tendido) VALUES
(1, 1, 0, 80, 1, 2, '2020-02-10'), -- Tramo 1 del Alimentador 1, entre poste 1 y 2
(1, 1, 80, 155, 2, 3, '2020-02-11'), -- Tramo 2 del Alimentador 1, entre poste 2 y 3
(2, 2, 0, 75, 4, 5, '2021-06-01'), -- Tramo 1 del Alimentador 2, entre poste 4 y 5
(4, 9, 0, 90, 6, 7, '2022-03-15'),
(5, 1, 0, 110, 8, 9, '2023-02-20'),
(6, 2, 0, 150, 10, 11, '2018-08-01'),
(7, 2, 0, 120, 12, 13, '2017-06-01'),
(8, 1, 0, 100, 14, 15, '2020-10-01'),
(9, 9, 0, 85, 5, 16, '2021-12-01');

-- Puntos de Suministro (Dependen de Cliente y Transformador Instalado)
INSERT INTO dbo.cge_punto_suministro (numero_cliente, id_cliente, id_transformador_instalado, direccion_suministro, tarifa, fecha_conexion) VALUES
('NC-10001', 1, 1, 'Arturo Prat 555, Valdivia', 'BT1', '2022-03-05'),
('NC-20001', 2, 2, 'Eleuterio Ramírez 1020, Osorno', 'BT1', '2021-09-01'),
('NC-30001', 3, 2, 'Av. Presidente Ibáñez 850, Puerto Montt', 'BT4.3', '2021-09-02'),
('NC-40001', 4, 3, 'San Martín 234, Temuco', 'BT1', '2022-04-10'),
('NC-50001', 5, 4, 'Del Salvador 72, Puerto Varas', 'BT1', '2023-03-15'),
('NC-10002', 6, 5, 'Los Robles 11, Isla Teja, Valdivia', 'BT1', '2019-02-01'),
('NC-20002', 7, 2, 'Guillermo Bühler 1800, Osorno', 'BT2', '2022-01-15'),
('NC-40002', 8, 3, 'Caupolicán 120, Temuco', 'BT1', '2022-05-20'),
('NC-60001', 9, 6, 'Arturo Prat 321, Loncoche', 'BT1', '2018-02-01'),
('NC-70001', 10, 7, 'Pudeto 567, Ancud', 'BT1', '2021-03-01'),
('NC-30002', 11, 8, 'Pedro Montt 987, Puerto Montt', 'BT1', '2022-02-01'),
('NC-40003', 12, 3, 'General Mackenna 432, Temuco', 'BT1', '2022-06-01');


/* 11. INSERCIÓN DE DATOS EN TABLA DE TRANSACCIONES (ÓRDENES DE TRABAJO)  */

-- Órdenes de Trabajo (Dependen de Punto Suministro, Poste y Cuadrilla)
INSERT INTO dbo.cge_orden_trabajo (descripcion_trabajo, tipo_trabajo, estado, fecha_creacion, fecha_cierre, id_punto_suministro, id_poste, id_cuadrilla_asignada) VALUES
('Revisión de medidor por alto consumo reportado por cliente.', 'Mantenimiento Preventivo', 'Completada', '2024-05-10 09:00:00', '2024-05-10 14:30:00', 1, NULL, 1),
('Instalación de nuevo empalme para cliente.', 'Nueva Conexión', 'En Progreso', '2024-08-18 11:00:00', NULL, 2, 5, 2),
('Poste chocado por vehículo en Av. Rahue.', 'Reparación', 'Pendiente', GETDATE(), NULL, NULL, 4, 3),
('Falla en cámara subterránea por inundación.', 'Reparación', 'En Progreso', '2025-07-20 08:00:00', NULL, NULL, 6, 4),
('Inspección termográfica de línea aérea en costanera.', 'Mantenimiento Predictivo', 'Pendiente', '2025-09-01 09:00:00', NULL, NULL, 8, 5),
('Construcción de base para nuevo transformador.', 'Obras Civiles', 'Completada', '2023-02-15 08:00:00', '2023-02-18 17:00:00', NULL, 9, 6),
('Despeje de ramas cercanas a línea de media tensión.', 'Poda y Despeje', 'Completada', '2024-11-05 09:00:00', '2024-11-05 16:00:00', NULL, 10, 7),
('Cambio de medidor a Smart Meter a petición de cliente.', 'Cambio de Equipo', 'Pendiente', '2025-08-25 10:00:00', NULL, 5, NULL, 2),
('Reparación de línea cortada por caída de árbol.', 'Reparación', 'Completada', '2024-06-15 14:00:00', '2024-06-15 19:00:00', NULL, 12, 8),
('Revisión de empalme en mal estado en Ancud.', 'Mantenimiento Correctivo', 'En Progreso', '2025-08-19 10:00:00', NULL, 10, NULL, 9),
('Normalización de red de baja tensión en Osorno.', 'Mejoramiento', 'Pendiente', '2025-10-01 09:00:00', NULL, NULL, 16, 10);


/* 12. QUERIES  */

-- Query 1: Inventario de Transformadores por Subestación y Alimentador.
-- Objetivo: Obtener un resumen de la cantidad de transformadores y la potencia total instalada (kVA)
-- para cada alimentador, agrupado por subestación. Es útil para la planificación y gestión de carga.
SELECT
    se.nombre AS Subestacion,
    alm.nombre AS Alimentador,
    COUNT(ti.id) AS Cantidad_Transformadores,
    SUM(ti.potencia_kva) AS Potencia_Total_Instalada_kVA
FROM
    dbo.cge_subestacion se
INNER JOIN
    dbo.cge_alimentador alm ON se.id = alm.id_subestacion
INNER JOIN
    dbo.cge_poste po ON alm.id = po.id_alimentador
INNER JOIN
    dbo.cge_transformador_instalado ti ON po.id = ti.id_poste
GROUP BY
    se.nombre,
    alm.nombre
ORDER BY
    Subestacion,
    Alimentador;

-- Query 2: Órdenes de Trabajo Pendientes con Detalle de Cuadrilla y Cliente.
-- Objetivo: Listar todas las órdenes de trabajo que no están completadas, mostrando
-- información del cliente afectado (si aplica) y el jefe de la cuadrilla asignada.
-- Utiliza un CTE (Common Table Expression) para identificar al jefe de cada cuadrilla.
WITH JefesDeCuadrilla AS (
    SELECT
        id_cuadrilla,
        nombre + ' ' + apellido AS NombreJefe
    FROM
        dbo.cge_empleado
    WHERE
        cargo = 'Jefe de Cuadrilla'
)
SELECT
    ot.id AS OT_ID,
    ot.descripcion_trabajo,
    ot.tipo_trabajo,
    ot.estado,
    ot.fecha_creacion,
    cua.nombre_cuadrilla,
    jdc.NombreJefe,
    cli.nombre + ' ' + cli.apellido AS Cliente_Afectado,
    ps.direccion_suministro
FROM
    dbo.cge_orden_trabajo ot
LEFT JOIN
    dbo.cge_cuadrilla cua ON ot.id_cuadrilla_asignada = cua.id
LEFT JOIN
    JefesDeCuadrilla jdc ON cua.id = jdc.id_cuadrilla
LEFT JOIN
    dbo.cge_punto_suministro ps ON ot.id_punto_suministro = ps.id
LEFT JOIN
    dbo.cge_cliente cli ON ps.id_cliente = cli.id
WHERE
    ot.estado IN ('Pendiente', 'En Progreso')
ORDER BY
    ot.fecha_creacion;

-- Query 3: Análisis de Tramos de Cable por Progresiva y Material.
-- Objetivo: Calcular la longitud total de cable (en metros) para un alimentador específico,
-- desglosado por tipo de cable y marca. Esencial para la gestión de activos y mantenimiento.
-- La subconsulta filtra el alimentador de interés.
SELECT
    p.descripcion AS Tipo_Cable,
    m.descripcion AS Marca_Cable,
    SUM(tc.progresiva_fin_m - tc.progresiva_inicio_m) AS Longitud_Total_Metros
FROM
    dbo.cge_tramo_cable_progresiva tc
INNER JOIN
    dbo.cge_producto p ON tc.id_producto_cable = p.id_producto
INNER JOIN
    dbo.cge_marca m ON p.marca_id = m.id
WHERE
    tc.id_alimentador = (SELECT id FROM dbo.cge_alimentador WHERE codigo_alimentador = 'ALM-VAL-CENTRO-01')
GROUP BY
    p.descripcion,
    m.descripcion
ORDER BY
    Longitud_Total_Metros DESC;

-- Query 4: Clientes por Transformador y Carga.
-- Objetivo: Identificar cuántos clientes están conectados a cada transformador y mostrar
-- la potencia del transformador para evaluar si podría estar sobrecargado.
SELECT
    ti.numero_serie AS Serie_Transformador,
    p.descripcion AS Producto_Transformador,
    ti.potencia_kva,
    COUNT(ps.id) AS Numero_Clientes_Conectados
FROM
    dbo.cge_transformador_instalado ti
INNER JOIN
    dbo.cge_producto p ON ti.id_producto = p.id_producto
INNER JOIN
    dbo.cge_punto_suministro ps ON ti.id = ps.id_transformador_instalado
GROUP BY
    ti.numero_serie,
    p.descripcion,
    ti.potencia_kva
ORDER BY
    Numero_Clientes_Conectados DESC;

-- Query 5: Historial de Mantenimiento por Poste.
-- Objetivo: Para un poste específico, mostrar todas las órdenes de trabajo que se le han
-- asociado a lo largo del tiempo, indicando el tipo de trabajo y la cuadrilla que lo realizó.
-- Útil para auditorías y seguimiento de la vida útil de los activos.
SELECT
    po.numero_identificacion AS Poste,
    po.material,
    po.fecha_instalacion,
    ot.id AS OT_ID,
    ot.tipo_trabajo,
    ot.descripcion_trabajo,
    ot.estado,
    ot.fecha_creacion,
    ot.fecha_cierre,
    cua.nombre_cuadrilla
FROM
    dbo.cge_poste po
LEFT JOIN
    dbo.cge_orden_trabajo ot ON po.id = ot.id_poste
LEFT JOIN
    dbo.cge_cuadrilla cua ON ot.id_cuadrilla_asignada = cua.id
WHERE
    po.numero_identificacion = 'P-OSO01-001'
ORDER BY
    ot.fecha_creacion DESC;
```

