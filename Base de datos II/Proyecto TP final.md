#proyecto

![[Pasted image 20251021200946.png]]

https://console.neon.tech/app/projects/lucky-surf-72935361/branches/br-cold-shape-ac8vtnsq?branchId=br-cold-shape-ac8vtnsq&database=sistema_gas

![[Pasted image 20251021200248.png]]

Sin pooling

```bash
psql 'postgresql://neondb_owner:npg_yuS1G4YJnsrb@ep-misty-cherry-acuelwjl.sa-east-1.aws.neon.tech/sistema_gas?sslmode=require&channel_binding=require'

psql -h pg.neon.tech

Password: npg_yuS1G4YJnsrb
```

- **Host URL:** `ep-misty-cherry-acuelwjl.sa-east-1.aws.neon.tech`
- **Database:** `sistema_gas`
- **Username:** `neondb_owner`
- **Password:** la de Neon
- **TLS/SSL Mode:** `require`
- **Port:** `5432`
- **PostgreSQL Version:** `15`


---


# Diagrama
## DER
![[Pasted image 20251021215830.png]]

## DBDiagram.io
```sql
Project sistema_gas {
  database_type: "PostgreSQL"
  note: 'Versión actualizada con prefijos sdg_ y buenas prácticas de nomenclatura (Postgres 15 → DBML).'
}

//// =========================
//// SEGURIDAD
//// =========================
Table sdg_usuario {
  id uuid [pk, default: `uuid_generate_v4()`]
  username citext [not null, unique]
  nombre text [not null]
  email citext [not null, unique]
  activo boolean [not null, default: true]
  creado_en timestamptz [not null, default: `now()`]
}

Table sdg_rol {
  id uuid [pk, default: `uuid_generate_v4()`]
  nombre text [not null, unique]
  descripcion text
}

Table sdg_usuario_rol {
  usuario_id uuid [not null, ref: > sdg_usuario.id]
  rol_id uuid [not null, ref: > sdg_rol.id]
  asignado_en timestamptz [not null, default: `now()`]
  Indexes {
    (usuario_id, rol_id) [pk]
  }
}

//// =========================
//// CATÁLOGO
//// =========================
Table sdg_material_tuberia {
  id smallint [pk]
  nombre text [not null, unique]
}

Table sdg_tipo_tramo {
  id smallint [pk]
  nombre text [not null, unique]
}

Table sdg_estado_inspeccion {
  id smallint [pk]
  nombre text [not null, unique]
  es_final boolean [not null, default: false]
}

Table sdg_tipo_hallazgo {
  id smallint [pk]
  nombre text [not null, unique]
}

Table sdg_severidad {
  id smallint [pk]
  nombre text [not null, unique]
  orden_visual smallint [not null]
}

Table sdg_tipo_intervencion {
  id smallint [pk]
  nombre text [not null, unique]
}

Table sdg_motivo_reasignacion {
  id smallint [pk]
  nombre text [not null, unique]
}

//// =========================
//// GEO
//// =========================
Table sdg_tramo {
  id uuid [pk, default: `uuid_generate_v4()`]
  codigo text [not null, unique]
  tipo_id smallint [not null, ref: > sdg_tipo_tramo.id]
  material_id smallint [not null, ref: > sdg_material_tuberia.id]
  diametro_mm int
  presion_oper_kpa numeric(10,2)
  instalado_en date
  geom geometry_linestring_4326 [not null]
  activo boolean [not null, default: true]
  creado_por uuid [ref: > sdg_usuario.id]
  creado_en timestamptz [not null, default: `now()`]
}

Table sdg_punto_control {
  id uuid [pk, default: `uuid_generate_v4()`]
  codigo text [not null, unique]
  descripcion text
  geom geometry_point_4326 [not null]
  creado_en timestamptz [not null, default: `now()`]
}

//// =========================
//// OPERACIÓN
//// =========================
Table sdg_tecnico {
  id uuid [pk, default: `uuid_generate_v4()`]
  usuario_id uuid [not null, unique, ref: > sdg_usuario.id]
  legajo text [not null, unique]
  habilitado boolean [not null, default: true]
  creado_en timestamptz [not null, default: `now()`]
}

Table sdg_inspeccion {
  id uuid [pk, default: `uuid_generate_v4()`]
  codigo text [not null, unique]
  descripcion text
  estado_id smallint [not null, ref: > sdg_estado_inspeccion.id]
  planificada_desde timestamptz [not null]
  planificada_hasta timestamptz [not null]
  prioridad smallint [not null, default: 3]
  creado_por uuid [ref: > sdg_usuario.id]
  creado_en timestamptz [not null, default: `now()`]
}

Table sdg_inspeccion_tramo {
  id uuid [pk, default: `uuid_generate_v4()`]
  inspeccion_id uuid [not null, ref: > sdg_inspeccion.id]
  tramo_id uuid [not null, ref: > sdg_tramo.id]
  orden int [not null, default: 1]
  Indexes {
    (inspeccion_id, tramo_id) [unique]
    (inspeccion_id, orden) [unique]
  }
}

Table sdg_asignacion {
  id uuid [pk, default: `uuid_generate_v4()`]
  inspeccion_id uuid [not null, ref: > sdg_inspeccion.id]
  tecnico_id uuid [not null, ref: > sdg_tecnico.id]
  periodo tstzrange [not null]
  asignado_por uuid [ref: > sdg_usuario.id]
  motivo_id smallint [ref: > sdg_motivo_reasignacion.id]
  creado_en timestamptz [not null, default: `now()`]
}

Table sdg_tracking_posicion {
  id bigserial [pk]
  inspeccion_id uuid [not null, ref: > sdg_inspeccion.id]
  tecnico_id uuid [not null, ref: > sdg_tecnico.id]
  tomado_en timestamptz [not null]
  punto geometry_point_4326 [not null]
  precision_m numeric(6,2)
  fuente text
  Indexes {
    (inspeccion_id, tecnico_id, tomado_en) [unique]
  }
}

Table sdg_trayecto {
  inspeccion_id uuid [pk, ref: > sdg_inspeccion.id]
  linea geometry_linestring_4326 [not null]
  calculado_en timestamptz [not null, default: `now()`]
}

Table sdg_hallazgo {
  id uuid [pk, default: `uuid_generate_v4()`]
  inspeccion_tramo_id uuid [not null, ref: > sdg_inspeccion_tramo.id]
  tipo_id smallint [not null, ref: > sdg_tipo_hallazgo.id]
  severidad_id smallint [not null, ref: > sdg_severidad.id]
  descripcion text
  ubicacion geometry_point_4326
  detectado_en timestamptz [not null, default: `now()`]
  detectado_por uuid [ref: > sdg_tecnico.id]
}

Table sdg_intervencion {
  id uuid [pk, default: `uuid_generate_v4()`]
  hallazgo_id uuid [not null, ref: > sdg_hallazgo.id]
  tipo_id smallint [not null, ref: > sdg_tipo_intervencion.id]
  descripcion text
  realizado_por uuid [ref: > sdg_tecnico.id]
  realizado_en timestamptz [not null, default: `now()`]
}

Table sdg_adjunto {
  id uuid [pk, default: `uuid_generate_v4()`]
  entidad text [not null]
  entidad_id uuid [not null]
  nombre_archivo text [not null]
  mime_type text [not null]
  url text [not null]
  subido_por uuid [ref: > sdg_usuario.id]
  subido_en timestamptz [not null, default: `now()`]
}

//// =========================
//// AUDITORÍA
//// =========================
Enum auditoria_accion_auditoria {
  INSERT
  UPDATE
  DELETE
  STATE_CHANGE
  ASSIGNMENT
  REALLOCATION
}

Table sdg_evento {
  id bigserial [pk]
  ocurrido_en timestamptz [not null, default: `now()`]
  actor_usuario uuid [ref: > sdg_usuario.id]
  actor_tecnico uuid [ref: > sdg_tecnico.id]
  entidad text [not null]
  entidad_id uuid
  accion auditoria_accion_auditoria [not null]
  detalle jsonb
  origen_ip inet
  origen_app text
  Indexes {
    (entidad, entidad_id, ocurrido_en)
  }
}

Table sdg_inspeccion_estado_historial {
  id bigserial [pk]
  inspeccion_id uuid [not null, ref: > sdg_inspeccion.id]
  estado_id smallint [not null, ref: > sdg_estado_inspeccion.id]
  cambiado_por uuid [ref: > sdg_usuario.id]
  cambiado_en timestamptz [not null, default: `now()`]
}

Table sdg_reasignacion_historial {
  id bigserial [pk]
  inspeccion_id uuid [not null, ref: > sdg_inspeccion.id]
  desde_tecnico uuid [ref: > sdg_tecnico.id]
  hacia_tecnico uuid [ref: > sdg_tecnico.id]
  motivo_id smallint [ref: > sdg_motivo_reasignacion.id]
  reasignado_por uuid [ref: > sdg_usuario.id]
  reasignado_en timestamptz [not null, default: `now()`]
}

Table sdg_tramo_version {
  id bigserial [pk]
  tramo_id uuid [not null, ref: > sdg_tramo.id]
  vigente tsrange [not null]
  material_id smallint [not null, ref: > sdg_material_tuberia.id]
  diametro_mm int [not null]
  presion_oper_kpa numeric(10,2) [not null]
  activo boolean [not null]
  versionado_por uuid [ref: > sdg_usuario.id]
  versionado_en timestamptz [not null, default: `now()`]
}

//// =========================
//// VISTAS (solo para documentación visual)
//// =========================
Table sdg_vw_inspeccion_estado_actual {
  id uuid
  codigo text
  descripcion text
  estado_id smallint
  estado_nombre text
  planificada_desde timestamptz
  planificada_hasta timestamptz
  prioridad smallint
  creado_en timestamptz
  Note: 'Vista base para monitoreo (Grafana).'
}

Table sdg_vw_inspeccion_ultimo_estado {
  inspeccion_id uuid
  estado_id smallint
  cambiado_en timestamptz
  cambiado_por uuid
  Note: 'Vista simplificada de último estado por inspección.'
}
```

# SQL - Postgres 15

```sql
-- =========================================================
-- Base de datos y extensiones
-- =========================================================
CREATE DATABASE sistema_gas
  WITH ENCODING 'UTF8' TEMPLATE template0;

-- Conéctate a la BD antes de seguir:
-- \c sistema_gas

-- Extensiones requeridas
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS btree_gist; -- para constraints de no solapamiento con ranges
CREATE EXTENSION IF NOT EXISTS citext;

-- =========================================================
-- Esquemas
-- =========================================================
CREATE SCHEMA seguridad;
CREATE SCHEMA catalogo;
CREATE SCHEMA geo;
CREATE SCHEMA operacion;
CREATE SCHEMA auditoria;

-- =========================================================
-- SEGURIDAD (usuarios/roles)
-- =========================================================
CREATE TABLE seguridad.usuario (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username        CITEXT UNIQUE NOT NULL,
  nombre          TEXT NOT NULL,
  email           CITEXT UNIQUE NOT NULL,
  activo          BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE seguridad.rol (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre          TEXT UNIQUE NOT NULL,       -- p.ej.: admin, planificador, tecnico, auditor
  descripcion     TEXT
);

CREATE TABLE seguridad.usuario_rol (
  usuario_id      UUID NOT NULL REFERENCES seguridad.usuario(id) ON DELETE CASCADE,
  rol_id          UUID NOT NULL REFERENCES seguridad.rol(id) ON DELETE RESTRICT,
  asignado_en     TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (usuario_id, rol_id)
);

-- =========================================================
-- CATÁLOGOS (dominios controlados)
-- =========================================================
CREATE TABLE catalogo.material_tuberia (
  id              SMALLINT PRIMARY KEY,
  nombre          TEXT UNIQUE NOT NULL        -- acero, PEAD, fundición, etc.
);

CREATE TABLE catalogo.tipo_tramo (
  id              SMALLINT PRIMARY KEY,
  nombre          TEXT UNIQUE NOT NULL        -- distribución, transporte, ramal, etc.
);

CREATE TABLE catalogo.estado_inspeccion (
  id              SMALLINT PRIMARY KEY,
  nombre          TEXT UNIQUE NOT NULL,       -- planificada, asignada, en_proceso, pausada, cerrada, anulada
  es_final        BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE catalogo.tipo_hallazgo (
  id              SMALLINT PRIMARY KEY,
  nombre          TEXT UNIQUE NOT NULL        -- fuga, corrosión, válvula inoperable, daño mecánico, etc.
);

CREATE TABLE catalogo.severidad (
  id              SMALLINT PRIMARY KEY,
  nombre          TEXT UNIQUE NOT NULL,       -- baja, media, alta, crítica
  orden_visual    SMALLINT NOT NULL
);

CREATE TABLE catalogo.tipo_intervencion (
  id              SMALLINT PRIMARY KEY,
  nombre          TEXT UNIQUE NOT NULL        -- reparación, reemplazo, sellado, cierre preventivo, etc.
);

CREATE TABLE catalogo.motivo_reasignacion (
  id              SMALLINT PRIMARY KEY,
  nombre          TEXT UNIQUE NOT NULL        -- disponibilidad, conflicto de agenda, mayor prioridad, etc.
);

-- =========================================================
-- GEO (activos y geometrías)
-- =========================================================
-- Un "tramo" es un segmento de cañería identificable y versionable
CREATE TABLE geo.tramo (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  codigo            TEXT UNIQUE NOT NULL,  -- identificador de activo legible
  tipo_id           SMALLINT NOT NULL REFERENCES catalogo.tipo_tramo(id),
  material_id       SMALLINT NOT NULL REFERENCES catalogo.material_tuberia(id),
  diametro_mm       INTEGER CHECK (diametro_mm > 0),
  presion_oper_kpa  NUMERIC(10,2) CHECK (presion_oper_kpa >= 0),
  instalado_en      DATE,
  -- Geometría: línea con SRID 4326 (WGS84). Usa topología si luego lo necesitas.
  geom              geometry(LINESTRING, 4326) NOT NULL,
  activo            BOOLEAN NOT NULL DEFAULT TRUE,
  creado_por        UUID REFERENCES seguridad.usuario(id),
  creado_en         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX ON geo.tramo USING GIST (geom);

-- Puntos de control/valvulería de referencia (opcionales)
CREATE TABLE geo.punto_control (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  codigo      TEXT UNIQUE NOT NULL,
  descripcion TEXT,
  geom        geometry(POINT, 4326) NOT NULL,
  creado_en   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ON geo.punto_control USING GIST (geom);

-- =========================================================
-- OPERACIÓN (inspecciones, tracking y resultados)
-- =========================================================
-- Técnicos de campo (perfil operativo del usuario)
CREATE TABLE operacion.tecnico (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  usuario_id    UUID UNIQUE NOT NULL REFERENCES seguridad.usuario(id) ON DELETE CASCADE,
  legajo        TEXT UNIQUE NOT NULL,
  habilitado    BOOLEAN NOT NULL DEFAULT TRUE,
  creado_en     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Inspección “macro” (puede cubrir 1..N tramos)
CREATE TABLE operacion.inspeccion (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  codigo            TEXT UNIQUE NOT NULL,   -- código operativo de la inspección
  descripcion       TEXT,
  estado_id         SMALLINT NOT NULL REFERENCES catalogo.estado_inspeccion(id),
  planificada_desde TIMESTAMPTZ NOT NULL,
  planificada_hasta TIMESTAMPTZ NOT NULL,
  prioridad         SMALLINT NOT NULL DEFAULT 3 CHECK (prioridad BETWEEN 1 AND 5),
  creado_por        UUID REFERENCES seguridad.usuario(id),
  creado_en         TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (planificada_desde < planificada_hasta)
);

-- Inspección <> Tramo (permite múltiples tramos por inspección y viceversa si hiciera falta)
CREATE TABLE operacion.inspeccion_tramo (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  inspeccion_id   UUID NOT NULL REFERENCES operacion.inspeccion(id) ON DELETE CASCADE,
  tramo_id        UUID NOT NULL REFERENCES geo.tramo(id) ON DELETE RESTRICT,
  orden           INTEGER NOT NULL DEFAULT 1,
  UNIQUE (inspeccion_id, tramo_id),
  UNIQUE (inspeccion_id, orden)
);

-- Asignaciones de técnico a inspección, con control de solapamientos vía ranges
CREATE TABLE operacion.asignacion (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  inspeccion_id   UUID NOT NULL REFERENCES operacion.inspeccion(id) ON DELETE CASCADE,
  tecnico_id      UUID NOT NULL REFERENCES operacion.tecnico(id) ON DELETE RESTRICT,
  periodo         TSTZRANGE NOT NULL,
  asignado_por    UUID REFERENCES seguridad.usuario(id),
  motivo_id       SMALLINT REFERENCES catalogo.motivo_reasignacion(id),
  creado_en       TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (lower(periodo) < upper(periodo))
);

-- Evita que un mismo técnico tenga dos asignaciones superpuestas a la misma inspección
ALTER TABLE operacion.asignacion
  ADD CONSTRAINT asignacion_no_overlap
  EXCLUDE USING gist (
    inspeccion_id WITH =,
    tecnico_id    WITH =,
    periodo       WITH &&
  );

-- Tracking de posiciones del técnico durante una inspección (para trazabilidad)
CREATE TABLE operacion.tracking_posicion (
  id              BIGSERIAL PRIMARY KEY,
  inspeccion_id   UUID NOT NULL REFERENCES operacion.inspeccion(id) ON DELETE CASCADE,
  tecnico_id      UUID NOT NULL REFERENCES operacion.tecnico(id) ON DELETE RESTRICT,
  tomado_en       TIMESTAMPTZ NOT NULL,
  punto           geometry(POINT, 4326) NOT NULL,
  precision_m     NUMERIC(6,2) CHECK (precision_m >= 0),
  fuente          TEXT, -- gps, manual, corrección diferencial, etc.
  UNIQUE (inspeccion_id, tecnico_id, tomado_en)
);
CREATE INDEX ON operacion.tracking_posicion USING GIST (punto);
CREATE INDEX ON operacion.tracking_posicion (inspeccion_id, tomado_en);

-- Trayecto agregado (opcional): representación como línea de la ruta recorrida
-- Puede generarse por proceso; se guarda para consulta rápida/Grafana.
CREATE TABLE operacion.trayecto (
  inspeccion_id   UUID PRIMARY KEY REFERENCES operacion.inspeccion(id) ON DELETE CASCADE,
  linea           geometry(LINESTRING, 4326) NOT NULL,
  calculado_en    TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ON operacion.trayecto USING GIST (linea);

-- Hallazgos detectados en un tramo durante la inspección
CREATE TABLE operacion.hallazgo (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  inspeccion_tramo_id UUID NOT NULL REFERENCES operacion.inspeccion_tramo(id) ON DELETE CASCADE,
  tipo_id           SMALLINT NOT NULL REFERENCES catalogo.tipo_hallazgo(id),
  severidad_id      SMALLINT NOT NULL REFERENCES catalogo.severidad(id),
  descripcion       TEXT,
  ubicacion         geometry(POINT, 4326),  -- punto exacto sobre/near el tramo
  detectado_en      TIMESTAMPTZ NOT NULL DEFAULT now(),
  detectado_por     UUID REFERENCES operacion.tecnico(id)
);
CREATE INDEX ON operacion.hallazgo USING GIST (ubicacion);
CREATE INDEX ON operacion.hallazgo (inspeccion_tramo_id);

-- Intervenciones realizadas a partir de hallazgos
CREATE TABLE operacion.intervencion (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  hallazgo_id     UUID NOT NULL REFERENCES operacion.hallazgo(id) ON DELETE CASCADE,
  tipo_id         SMALLINT NOT NULL REFERENCES catalogo.tipo_intervencion(id),
  descripcion     TEXT,
  realizado_por   UUID REFERENCES operacion.tecnico(id),
  realizado_en    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Adjuntos (solo metadatos; los binarios vivirán en almacenamiento externo)
CREATE TABLE operacion.adjunto (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  entidad         TEXT NOT NULL CHECK (entidad IN ('inspeccion','hallazgo','intervencion','tramo')),
  entidad_id      UUID NOT NULL,
  nombre_archivo  TEXT NOT NULL,
  mime_type       TEXT NOT NULL,
  url             TEXT NOT NULL,  -- ubicación en objeto/FS
  subido_por      UUID REFERENCES seguridad.usuario(id),
  subido_en       TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- FK polimórfica vía trigger a implementar; por ahora: índice para consultas
CREATE INDEX ON operacion.adjunto (entidad, entidad_id);

-- =========================================================
-- AUDITORÍA (eventos y cambios)
-- =========================================================
-- Modelo de auditoría por evento (event sourcing simplificado)
CREATE TYPE auditoria.accion_auditoria AS ENUM (
  'INSERT', 'UPDATE', 'DELETE', 'STATE_CHANGE', 'ASSIGNMENT', 'REALLOCATION'
);

CREATE TABLE auditoria.evento (
  id              BIGSERIAL PRIMARY KEY,
  ocurrido_en     TIMESTAMPTZ NOT NULL DEFAULT now(),
  actor_usuario   UUID REFERENCES seguridad.usuario(id),
  actor_tecnico   UUID REFERENCES operacion.tecnico(id),
  entidad         TEXT NOT NULL,            -- nombre lógico: inspeccion, tramo, hallazgo, etc.
  entidad_id      UUID,
  accion          auditoria.accion_auditoria NOT NULL,
  detalle         JSONB,                    -- payload contextual (antes/después, diffs, etc.)
  origen_ip       INET,
  origen_app      TEXT                      -- móvil, web, integración
);
CREATE INDEX ON auditoria.evento (entidad, entidad_id, ocurrido_en DESC);

-- Historial explícito de estados de la inspección (para consultas rápidas/grafana)
CREATE TABLE auditoria.inspeccion_estado_historial (
  id              BIGSERIAL PRIMARY KEY,
  inspeccion_id   UUID NOT NULL REFERENCES operacion.inspeccion(id) ON DELETE CASCADE,
  estado_id       SMALLINT NOT NULL REFERENCES catalogo.estado_inspeccion(id),
  cambiado_por    UUID REFERENCES seguridad.usuario(id),
  cambiado_en     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ON auditoria.inspeccion_estado_historial (inspeccion_id, cambiado_en DESC);

-- Historial explícito de reasignaciones
CREATE TABLE auditoria.reasignacion_historial (
  id              BIGSERIAL PRIMARY KEY,
  inspeccion_id   UUID NOT NULL REFERENCES operacion.inspeccion(id) ON DELETE CASCADE,
  desde_tecnico   UUID REFERENCES operacion.tecnico(id),
  hacia_tecnico   UUID REFERENCES operacion.tecnico(id),
  motivo_id       SMALLINT REFERENCES catalogo.motivo_reasignacion(id),
  reasignado_por  UUID REFERENCES seguridad.usuario(id),
  reasignado_en   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ON auditoria.reasignacion_historial (inspeccion_id, reasignado_en DESC);

-- Versionado de atributos de tramo (SCD2 liviano) para trazabilidad de cambios “lentos”
CREATE TABLE auditoria.tramo_version (
  id                BIGSERIAL PRIMARY KEY,
  tramo_id          UUID NOT NULL REFERENCES geo.tramo(id) ON DELETE CASCADE,
  vigente           TSRANGE NOT NULL,    -- [desde, hasta)
  material_id       SMALLINT NOT NULL REFERENCES catalogo.material_tuberia(id),
  diametro_mm       INTEGER NOT NULL,
  presion_oper_kpa  NUMERIC(10,2) NOT NULL,
  activo            BOOLEAN NOT NULL,
  versionado_por    UUID REFERENCES seguridad.usuario(id),
  versionado_en     TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (lower(vigente) < upper(vigente))
);

ALTER TABLE auditoria.tramo_version
  ADD CONSTRAINT tramo_version_no_overlap
  EXCLUDE USING gist (
    tramo_id WITH =,
    vigente  WITH &&
  );

-- =========================================================
-- RELACIONES DERIVADAS Y VISTAS ÚTILES (solo estructura mínima)
-- =========================================================
-- Vista base para Grafana: estado actual por inspección (sin lógica procedural)
CREATE VIEW operacion.v_inspeccion_estado_actual AS
SELECT i.id,
       i.codigo,
       i.descripcion,
       i.estado_id,
       e.nombre AS estado_nombre,
       i.planificada_desde,
       i.planificada_hasta,
       i.prioridad,
       i.creado_en
FROM operacion.inspeccion i
JOIN catalogo.estado_inspeccion e ON e.id = i.estado_id;

-- Vista: últimos cambios de estado por inspección
CREATE VIEW auditoria.v_inspeccion_ultimo_estado AS
SELECT DISTINCT ON (h.inspeccion_id)
       h.inspeccion_id,
       h.estado_id,
       h.cambiado_en,
       h.cambiado_por
FROM auditoria.inspeccion_estado_historial h
ORDER BY h.inspeccion_id, h.cambiado_en DESC;

-- =========================================================
-- ÍNDICES extra y FK auxiliares
-- =========================================================
CREATE INDEX ON operacion.inspeccion (estado_id, planificada_desde, planificada_hasta);
CREATE INDEX ON operacion.hallazgo (tipo_id, severidad_id, detectado_en);
CREATE INDEX ON operacion.intervencion (tipo_id, realizado_en);

-- =========================================================
-- CHECKS y buenas prácticas adicionales
-- =========================================================
-- Garantiza que la ubicación de un hallazgo caiga razonablemente cerca del tramo (a implementar por trigger);
-- dejamos el CHECK semántico fuera por ser geoespacial complejo.
-- Igualmente, la FK polimórfica de adjuntos debe validarse por trigger/procedimiento.
```

# Datos

## (1) — Datos dummy iniciales

```sql
-- =========================================================
-- EXTENSIONES (por si falta algo)
-- =========================================================
CREATE EXTENSION IF NOT EXISTS citext;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- =========================================================
-- USUARIOS Y ROLES
-- =========================================================
INSERT INTO seguridad.rol (nombre, descripcion) VALUES
  ('admin', 'Administrador del sistema'),
  ('planificador', 'Planificador de inspecciones'),
  ('tecnico', 'Técnico de campo'),
  ('auditor', 'Auditor de operaciones');

INSERT INTO seguridad.usuario (username, nombre, email, activo)
VALUES
  ('jrojas', 'Juan Rojas', 'juan.rojas@example.com', TRUE),
  ('marias', 'María Suárez', 'maria.suarez@example.com', TRUE),
  ('lrodriguez', 'Luis Rodríguez', 'luis.rodriguez@example.com', TRUE),
  ('acastro', 'Ana Castro', 'ana.castro@example.com', TRUE),
  ('cmendez', 'Carlos Méndez', 'carlos.mendez@example.com', TRUE);

-- Asignación de roles
INSERT INTO seguridad.usuario_rol (usuario_id, rol_id)
SELECT u.id, r.id
FROM seguridad.usuario u
JOIN seguridad.rol r
  ON (u.username = 'jrojas' AND r.nombre = 'admin')
   OR (u.username = 'marias' AND r.nombre = 'planificador')
   OR (u.username = 'lrodriguez' AND r.nombre = 'tecnico')
   OR (u.username = 'acastro' AND r.nombre = 'tecnico')
   OR (u.username = 'cmendez' AND r.nombre = 'auditor');

-- =========================================================
-- CATÁLOGOS
-- =========================================================

-- Materiales de tubería
INSERT INTO catalogo.material_tuberia (id, nombre) VALUES
  (1, 'Acero'),
  (2, 'Polietileno (PEAD)'),
  (3, 'Fundición'),
  (4, 'PVC');

-- Tipos de tramo
INSERT INTO catalogo.tipo_tramo (id, nombre) VALUES
  (1, 'Distribución'),
  (2, 'Transporte'),
  (3, 'Ramal domiciliario');

-- Estados de inspección
INSERT INTO catalogo.estado_inspeccion (id, nombre, es_final) VALUES
  (1, 'Planificada', FALSE),
  (2, 'Asignada', FALSE),
  (3, 'En proceso', FALSE),
  (4, 'Pausada', FALSE),
  (5, 'Cerrada', TRUE),
  (6, 'Anulada', TRUE);

-- Tipos de hallazgo
INSERT INTO catalogo.tipo_hallazgo (id, nombre) VALUES
  (1, 'Fuga de gas'),
  (2, 'Corrosión'),
  (3, 'Válvula inoperable'),
  (4, 'Daño mecánico'),
  (5, 'Obstrucción');

-- Severidad
INSERT INTO catalogo.severidad (id, nombre, orden_visual) VALUES
  (1, 'Baja', 1),
  (2, 'Media', 2),
  (3, 'Alta', 3),
  (4, 'Crítica', 4);

-- Tipos de intervención
INSERT INTO catalogo.tipo_intervencion (id, nombre) VALUES
  (1, 'Reparación'),
  (2, 'Reemplazo'),
  (3, 'Sellado'),
  (4, 'Cierre preventivo');

-- Motivos de reasignación
INSERT INTO catalogo.motivo_reasignacion (id, nombre) VALUES
  (1, 'Disponibilidad del técnico'),
  (2, 'Repriorización'),
  (3, 'Conflicto de agenda'),
  (4, 'Urgencia operativa');
```

## (2) — Datos geoespaciales y técnicos

```sql
-- =========================================================
-- TÉCNICOS (usuarios de campo)
-- =========================================================
INSERT INTO operacion.tecnico (usuario_id, legajo, habilitado)
SELECT id, 'TEC-001', TRUE FROM seguridad.usuario WHERE username = 'lrodriguez';
INSERT INTO operacion.tecnico (usuario_id, legajo, habilitado)
SELECT id, 'TEC-002', TRUE FROM seguridad.usuario WHERE username = 'acastro';

-- =========================================================
-- TRAMOS DE CAÑERÍAS
-- =========================================================
-- Coordenadas aproximadas de ejemplo en La Plata, Argentina
INSERT INTO geo.tramo (codigo, tipo_id, material_id, diametro_mm, presion_oper_kpa, instalado_en, geom, creado_por)
SELECT
  'TR-001', 1, 1, 150, 300.00, '2005-04-10',
  ST_GeomFromText('LINESTRING(-57.956 -34.920, -57.950 -34.918)', 4326),
  u.id
FROM seguridad.usuario u WHERE username = 'marias';

INSERT INTO geo.tramo (codigo, tipo_id, material_id, diametro_mm, presion_oper_kpa, instalado_en, geom, creado_por)
SELECT
  'TR-002', 1, 2, 110, 200.00, '2010-07-23',
  ST_GeomFromText('LINESTRING(-57.950 -34.918, -57.946 -34.917)', 4326),
  u.id
FROM seguridad.usuario u WHERE username = 'marias';

INSERT INTO geo.tramo (codigo, tipo_id, material_id, diametro_mm, presion_oper_kpa, instalado_en, geom, creado_por)
SELECT
  'TR-003', 2, 1, 250, 450.00, '2001-03-15',
  ST_GeomFromText('LINESTRING(-57.946 -34.917, -57.940 -34.915)', 4326),
  u.id
FROM seguridad.usuario u WHERE username = 'marias';

INSERT INTO geo.tramo (codigo, tipo_id, material_id, diametro_mm, presion_oper_kpa, instalado_en, geom, creado_por)
SELECT
  'TR-004', 3, 4, 63, 150.00, '2016-11-05',
  ST_GeomFromText('LINESTRING(-57.960 -34.921, -57.956 -34.920)', 4326),
  u.id
FROM seguridad.usuario u WHERE username = 'marias';

-- =========================================================
-- PUNTOS DE CONTROL
-- =========================================================
INSERT INTO geo.punto_control (codigo, descripcion, geom)
VALUES
  ('PC-001', 'Válvula de corte principal', ST_GeomFromText('POINT(-57.956 -34.920)', 4326)),
  ('PC-002', 'Estación reductora secundaria', ST_GeomFromText('POINT(-57.950 -34.918)', 4326)),
  ('PC-003', 'Nodo de inspección norte', ST_GeomFromText('POINT(-57.946 -34.917)', 4326)),
  ('PC-004', 'Conexión ramal domiciliario', ST_GeomFromText('POINT(-57.960 -34.921)', 4326));

-- =========================================================
-- VERSIONES HISTÓRICAS DE TRAMOS (inicial)
-- =========================================================
-- SELECT codigo, ST_Length(geom::geography) AS longitud_metros FROM geo.tramo;

INSERT INTO auditoria.tramo_version
  (tramo_id, vigente, material_id, diametro_mm, presion_oper_kpa, activo, versionado_por)
SELECT
  t.id,
  tsrange(t.instalado_en::timestamp, NULL),  -- [desde, ∞) con límites [)
  t.material_id,
  t.diametro_mm,
  t.presion_oper_kpa,
  t.activo,
  t.creado_por
FROM geo.tramo t;
```

## INSERTs para: inspecciones, inspeccion_tramo, asignaciones y tracking de posiciones

```sql
-- =========================================================
-- INSPECCIONES
-- =========================================================
INSERT INTO operacion.inspeccion (
  codigo, descripcion, estado_id,
  planificada_desde, planificada_hasta, prioridad, creado_por
)
SELECT
  'INSP-2025-001', 'Inspección de tramos principales zona norte', 3, -- En proceso
  '2025-08-10 09:00-03', '2025-08-10 12:00-03', 2, u.id
FROM seguridad.usuario u WHERE u.username = 'marias';

INSERT INTO operacion.inspeccion (
  codigo, descripcion, estado_id,
  planificada_desde, planificada_hasta, prioridad, creado_por
)
SELECT
  'INSP-2025-002', 'Inspección de ramales y conexión domiciliaria', 1, -- Planificada
  '2025-08-11 09:30-03', '2025-08-11 13:00-03', 3, u.id
FROM seguridad.usuario u WHERE u.username = 'marias';

-- Historial de estados (para dashboards)
INSERT INTO auditoria.inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
SELECT i.id, 1, u.id, '2025-08-01 10:00-03' -- Planificada
FROM operacion.inspeccion i
JOIN seguridad.usuario u ON u.username = 'marias'
WHERE i.codigo = 'INSP-2025-001';

INSERT INTO auditoria.inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
SELECT i.id, 2, u.id, '2025-08-05 15:00-03' -- Asignada
FROM operacion.inspeccion i
JOIN seguridad.usuario u ON u.username = 'marias'
WHERE i.codigo = 'INSP-2025-001';

INSERT INTO auditoria.inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
SELECT i.id, 3, u.id, '2025-08-10 09:05-03' -- En proceso
FROM operacion.inspeccion i
JOIN seguridad.usuario u ON u.username = 'marias'
WHERE i.codigo = 'INSP-2025-001';

-- Para la segunda inspección, solo estado inicial
INSERT INTO auditoria.inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
SELECT i.id, 1, u.id, '2025-08-02 11:00-03'
FROM operacion.inspeccion i
JOIN seguridad.usuario u ON u.username = 'marias'
WHERE i.codigo = 'INSP-2025-002';

-- =========================================================
-- INSPECCION_TRAMO (qué tramos inspecciona cada inspección)
-- =========================================================
-- INSP-2025-001: TR-001 y TR-002
INSERT INTO operacion.inspeccion_tramo (inspeccion_id, tramo_id, orden)
SELECT i.id, t.id, 1
FROM operacion.inspeccion i
JOIN geo.tramo t ON t.codigo = 'TR-001'
WHERE i.codigo = 'INSP-2025-001';

INSERT INTO operacion.inspeccion_tramo (inspeccion_id, tramo_id, orden)
SELECT i.id, t.id, 2
FROM operacion.inspeccion i
JOIN geo.tramo t ON t.codigo = 'TR-002'
WHERE i.codigo = 'INSP-2025-001';

-- INSP-2025-002: TR-003 y TR-004
INSERT INTO operacion.inspeccion_tramo (inspeccion_id, tramo_id, orden)
SELECT i.id, t.id, 1
FROM operacion.inspeccion i
JOIN geo.tramo t ON t.codigo = 'TR-003'
WHERE i.codigo = 'INSP-2025-002';

INSERT INTO operacion.inspeccion_tramo (inspeccion_id, tramo_id, orden)
SELECT i.id, t.id, 2
FROM operacion.inspeccion i
JOIN geo.tramo t ON t.codigo = 'TR-004'
WHERE i.codigo = 'INSP-2025-002';

-- =========================================================
-- ASIGNACIONES (técnico -> inspección, con TSTZRANGE)
-- =========================================================
-- INSP-2025-001 asignada a TEC-001
INSERT INTO operacion.asignacion (inspeccion_id, tecnico_id, periodo, asignado_por, motivo_id)
SELECT i.id, tec.id, tstzrange('2025-08-10 08:30-03','2025-08-10 13:00-03','[)'),
       u.id, 1
FROM operacion.inspeccion i
JOIN operacion.tecnico tec ON tec.legajo = 'TEC-001'
JOIN seguridad.usuario u ON u.username = 'marias'
WHERE i.codigo = 'INSP-2025-001';

-- INSP-2025-002 asignada a TEC-002
INSERT INTO operacion.asignacion (inspeccion_id, tecnico_id, periodo, asignado_por, motivo_id)
SELECT i.id, tec.id, tstzrange('2025-08-11 09:00-03','2025-08-11 14:00-03','[)'),
       u.id, 2
FROM operacion.inspeccion i
JOIN operacion.tecnico tec ON tec.legajo = 'TEC-002'
JOIN seguridad.usuario u ON u.username = 'marias'
WHERE i.codigo = 'INSP-2025-002';

-- =========================================================
-- TRACKING DE POSICIONES (GPS) para INSP-2025-001 / TEC-001
-- Puntos aproximados recorriendo TR-001 y TR-002, cada ~5 minutos
-- =========================================================
INSERT INTO operacion.tracking_posicion (inspeccion_id, tecnico_id, tomado_en, punto, precision_m, fuente)
SELECT i.id, tec.id, '2025-08-10 09:00-03',
       ST_GeomFromText('POINT(-57.956 -34.920)', 4326), 4.5, 'gps'
FROM operacion.inspeccion i
JOIN operacion.tecnico tec ON tec.legajo = 'TEC-001'
WHERE i.codigo = 'INSP-2025-001';

INSERT INTO operacion.tracking_posicion (inspeccion_id, tecnico_id, tomado_en, punto, precision_m, fuente)
SELECT i.id, tec.id, '2025-08-10 09:05-03',
       ST_GeomFromText('POINT(-57.9545 -34.9195)', 4326), 4.2, 'gps'
FROM operacion.inspeccion i
JOIN operacion.tecnico tec ON tec.legajo = 'TEC-001'
WHERE i.codigo = 'INSP-2025-001';

INSERT INTO operacion.tracking_posicion (inspeccion_id, tecnico_id, tomado_en, punto, precision_m, fuente)
SELECT i.id, tec.id, '2025-08-10 09:10-03',
       ST_GeomFromText('POINT(-57.953 -34.919)', 4326), 4.0, 'gps'
FROM operacion.inspeccion i
JOIN operacion.tecnico tec ON tec.legajo = 'TEC-001'
WHERE i.codigo = 'INSP-2025-001';

INSERT INTO operacion.tracking_posicion (inspeccion_id, tecnico_id, tomado_en, punto, precision_m, fuente)
SELECT i.id, tec.id, '2025-08-10 09:15-03',
       ST_GeomFromText('POINT(-57.9515 -34.9185)', 4326), 3.8, 'gps'
FROM operacion.inspeccion i
JOIN operacion.tecnico tec ON tec.legajo = 'TEC-001'
WHERE i.codigo = 'INSP-2025-001';

-- Llegando al nodo que une TR-001 con TR-002
INSERT INTO operacion.tracking_posicion (inspeccion_id, tecnico_id, tomado_en, punto, precision_m, fuente)
SELECT i.id, tec.id, '2025-08-10 09:20-03',
       ST_GeomFromText('POINT(-57.950 -34.918)', 4326), 3.6, 'gps'
FROM operacion.inspeccion i
JOIN operacion.tecnico tec ON tec.legajo = 'TEC-001'
WHERE i.codigo = 'INSP-2025-001';

-- Avance sobre TR-002
INSERT INTO operacion.tracking_posicion (inspeccion_id, tecnico_id, tomado_en, punto, precision_m, fuente)
SELECT i.id, tec.id, '2025-08-10 09:25-03',
       ST_GeomFromText('POINT(-57.948 -34.9175)', 4326), 3.9, 'gps'
FROM operacion.inspeccion i
JOIN operacion.tecnico tec ON tec.legajo = 'TEC-001'
WHERE i.codigo = 'INSP-2025-001';

INSERT INTO operacion.tracking_posicion (inspeccion_id, tecnico_id, tomado_en, punto, precision_m, fuente)
SELECT i.id, tec.id, '2025-08-10 09:30-03',
       ST_GeomFromText('POINT(-57.9465 -34.9172)', 4326), 4.1, 'gps'
FROM operacion.inspeccion i
JOIN operacion.tecnico tec ON tec.legajo = 'TEC-001'
WHERE i.codigo = 'INSP-2025-001';

INSERT INTO operacion.tracking_posicion (inspeccion_id, tecnico_id, tomado_en, punto, precision_m, fuente)
SELECT i.id, tec.id, '2025-08-10 09:35-03',
       ST_GeomFromText('POINT(-57.946 -34.917)', 4326), 4.0, 'gps'
FROM operacion.inspeccion i
JOIN operacion.tecnico tec ON tec.legajo = 'TEC-001'
WHERE i.codigo = 'INSP-2025-001';

-- =========================================================
-- TRAYECTO (opcional): línea agregada de la ruta recorrida
-- Podrías generarlo por procedimiento; acá dejamos un ejemplo manual.
-- =========================================================
INSERT INTO operacion.trayecto (inspeccion_id, linea, calculado_en)
SELECT i.id,
       ST_GeomFromText(
         'LINESTRING(-57.956 -34.920, -57.9545 -34.9195, -57.953 -34.919, -57.9515 -34.9185, -57.950 -34.918, -57.948 -34.9175, -57.9465 -34.9172, -57.946 -34.917)',
         4326
       ),
       now()
FROM operacion.inspeccion i
WHERE i.codigo = 'INSP-2025-001';
```

## INSERTs para: hallazgos, intervenciones, adjuntos y auditoría

```sql
-- =========================================================
-- HALLAZGOS (INSP-2025-001 en TR-001 y TR-002)
-- =========================================================
-- H1: Fuga crítica cerca del nodo entre TR-001 y TR-002
INSERT INTO operacion.hallazgo (
  inspeccion_tramo_id, tipo_id, severidad_id, descripcion, ubicacion, detectado_en, detectado_por
)
SELECT it.id, 1, 4, 'Fuga detectada con medidor portátil. Concentración elevada.',
       ST_GeomFromText('POINT(-57.9495 -34.9181)', 4326), '2025-08-10 09:22-03', tec.id
FROM operacion.inspeccion i
JOIN operacion.inspeccion_tramo it ON it.inspeccion_id = i.id
JOIN geo.tramo t ON t.id = it.tramo_id AND t.codigo = 'TR-001'
JOIN operacion.tecnico tec ON tec.legajo = 'TEC-001'
WHERE i.codigo = 'INSP-2025-001';

-- H2: Corrosión con severidad media sobre TR-002
INSERT INTO operacion.hallazgo (
  inspeccion_tramo_id, tipo_id, severidad_id, descripcion, ubicacion, detectado_en, detectado_por
)
SELECT it.id, 2, 2, 'Corrosión externa moderada, requiere mantenimiento preventivo.',
       ST_GeomFromText('POINT(-57.9476 -34.9174)', 4326), '2025-08-10 09:33-03', tec.id
FROM operacion.inspeccion i
JOIN operacion.inspeccion_tramo it ON it.inspeccion_id = i.id
JOIN geo.tramo t ON t.id = it.tramo_id AND t.codigo = 'TR-002'
JOIN operacion.tecnico tec ON tec.legajo = 'TEC-001'
WHERE i.codigo = 'INSP-2025-001';

-- H3: Válvula inoperable (baja) en TR-004 durante INSP-2025-002
INSERT INTO operacion.hallazgo (
  inspeccion_tramo_id, tipo_id, severidad_id, descripcion, ubicacion, detectado_en, detectado_por
)
SELECT it.id, 3, 1, 'Válvula con accionamiento duro, operar con lubricación.',
       ST_GeomFromText('POINT(-57.9585 -34.9205)', 4326), '2025-08-11 10:05-03', tec.id
FROM operacion.inspeccion i
JOIN operacion.inspeccion_tramo it ON it.inspeccion_id = i.id
JOIN geo.tramo t ON t.id = it.tramo_id AND t.codigo = 'TR-004'
JOIN operacion.tecnico tec ON tec.legajo = 'TEC-002'
WHERE i.codigo = 'INSP-2025-002';

-- =========================================================
-- INTERVENCIONES (derivadas de hallazgos)
-- =========================================================
-- Para H1 (fuga crítica): Reparación realizada por TEC-001
INSERT INTO operacion.intervencion (hallazgo_id, tipo_id, descripcion, realizado_por, realizado_en)
SELECT h.id, 1, 'Sellado y prueba de estanqueidad. Sin olor residual.', tec.id, '2025-08-10 10:15-03'
FROM operacion.hallazgo h
JOIN operacion.inspeccion_tramo it ON it.id = h.inspeccion_tramo_id
JOIN operacion.inspeccion i ON i.id = it.inspeccion_id AND i.codigo = 'INSP-2025-001'
JOIN operacion.tecnico tec ON tec.legajo = 'TEC-001'
WHERE h.descripcion LIKE 'Fuga detectada%';

-- Para H2 (corrosión media): Sellado/protección temporal por TEC-001
INSERT INTO operacion.intervencion (hallazgo_id, tipo_id, descripcion, realizado_por, realizado_en)
SELECT h.id, 3, 'Aplicación de recubrimiento temporal anticorrosivo.', tec.id, '2025-08-10 10:40-03'
FROM operacion.hallazgo h
JOIN operacion.inspeccion_tramo it ON it.id = h.inspeccion_tramo_id
JOIN operacion.inspeccion i ON i.id = it.inspeccion_id AND i.codigo = 'INSP-2025-001'
JOIN operacion.tecnico tec ON tec.legajo = 'TEC-001'
WHERE h.descripcion LIKE 'Corrosión externa%';

-- Para H3 (válvula inoperable baja): Mantenimiento/lubricación por TEC-002
INSERT INTO operacion.intervencion (hallazgo_id, tipo_id, descripcion, realizado_por, realizado_en)
SELECT h.id, 1, 'Lubricación y verificación de operación. Válvula vuelve a operar dentro de parámetros.',
       tec.id, '2025-08-11 11:20-03'
FROM operacion.hallazgo h
JOIN operacion.inspeccion_tramo it ON it.id = h.inspeccion_tramo_id
JOIN operacion.inspeccion i ON i.id = it.inspeccion_id AND i.codigo = 'INSP-2025-002'
JOIN operacion.tecnico tec ON tec.legajo = 'TEC-002'
WHERE h.descripcion LIKE 'Válvula con accionamiento duro%';

-- =========================================================
-- ADJUNTOS (metadatos; FK polimórfica validada por trigger en tu TP)
-- =========================================================
-- Foto general de INSP-2025-001
INSERT INTO operacion.adjunto (entidad, entidad_id, nombre_archivo, mime_type, url, subido_por, subido_en)
SELECT 'inspeccion', i.id, 'foto_insp001_01.jpg', 'image/jpeg', 's3://bucket/foto_insp001_01.jpg', u.id, '2025-08-10 09:18-03'
FROM operacion.inspeccion i
JOIN seguridad.usuario u ON u.username = 'lrodriguez'
WHERE i.codigo = 'INSP-2025-001';

-- Evidencia de fuga (H1)
INSERT INTO operacion.adjunto (entidad, entidad_id, nombre_archivo, mime_type, url, subido_por, subido_en)
SELECT 'hallazgo', h.id, 'fuga_tr001_termografia.png', 'image/png', 's3://bucket/fuga_tr001_thermo.png', u.id, '2025-08-10 09:25-03'
FROM operacion.hallazgo h
JOIN operacion.inspeccion_tramo it ON it.id = h.inspeccion_tramo_id
JOIN operacion.inspeccion i ON i.id = it.inspeccion_id AND i.codigo = 'INSP-2025-001'
JOIN seguridad.usuario u ON u.username = 'lrodriguez'
WHERE h.descripcion LIKE 'Fuga detectada%';

-- Acta de intervención (H1)
INSERT INTO operacion.adjunto (entidad, entidad_id, nombre_archivo, mime_type, url, subido_por, subido_en)
SELECT 'intervencion', iv.id, 'acta_reparacion_h1.pdf', 'application/pdf', 's3://bucket/acta_reparacion_h1.pdf', u.id, '2025-08-10 10:25-03'
FROM operacion.intervencion iv
JOIN operacion.hallazgo h ON h.id = iv.hallazgo_id
JOIN seguridad.usuario u ON u.username = 'marias'
WHERE h.descripcion LIKE 'Fuga detectada%';

-- Plano del tramo TR-002
INSERT INTO operacion.adjunto (entidad, entidad_id, nombre_archivo, mime_type, url, subido_por, subido_en)
SELECT 'tramo', t.id, 'plano_tr002.dwg', 'application/acad', 's3://bucket/planos/plano_tr002.dwg', u.id, '2025-08-09 17:45-03'
FROM geo.tramo t
JOIN seguridad.usuario u ON u.username = 'marias'
WHERE t.codigo = 'TR-002';

-- =========================================================
-- AUDITORÍA: cambios de estado de inspección (línea de tiempo)
-- =========================================================
-- Cierre de INSP-2025-001
INSERT INTO auditoria.inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
SELECT i.id, 5, u.id, '2025-08-10 12:30-03'  -- Cerrada
FROM operacion.inspeccion i
JOIN seguridad.usuario u ON u.username = 'marias'
WHERE i.codigo = 'INSP-2025-001';

-- INSP-2025-002: Asignada y luego En proceso y Cerrada
INSERT INTO auditoria.inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
SELECT i.id, 2, u.id, '2025-08-10 17:00-03'  -- Asignada
FROM operacion.inspeccion i
JOIN seguridad.usuario u ON u.username = 'marias'
WHERE i.codigo = 'INSP-2025-002';

INSERT INTO auditoria.inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
SELECT i.id, 3, u.id, '2025-08-11 09:35-03'  -- En proceso
FROM operacion.inspeccion i
JOIN seguridad.usuario u ON u.username = 'marias'
WHERE i.codigo = 'INSP-2025-002';

INSERT INTO auditoria.inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
SELECT i.id, 5, u.id, '2025-08-11 12:45-03'  -- Cerrada
FROM operacion.inspeccion i
JOIN seguridad.usuario u ON u.username = 'marias'
WHERE i.codigo = 'INSP-2025-002';

-- =========================================================
-- AUDITORÍA: eventos (event sourcing ligero en JSONB)
-- =========================================================
-- Evento: creación de hallazgos H1, H2, H3
INSERT INTO auditoria.evento (actor_tecnico, entidad, entidad_id, accion, detalle, origen_app, ocurrido_en)
SELECT tec.id, 'hallazgo', h.id, 'INSERT',
       jsonb_build_object('tipo','Fuga/Corrosión/Válvula','severidad','según registro','nota','Carga inicial'),
       'movil', h.detectado_en
FROM operacion.hallazgo h
LEFT JOIN operacion.tecnico tec ON tec.id = h.detectado_por;

-- Evento: intervenciones registradas
INSERT INTO auditoria.evento (actor_tecnico, entidad, entidad_id, accion, detalle, origen_app, ocurrido_en)
SELECT iv.realizado_por, 'intervencion', iv.id, 'INSERT',
       jsonb_build_object('tipo','Intervencion','comentario',iv.descripcion),
       'movil', iv.realizado_en
FROM operacion.intervencion iv;

-- Evento: adjuntos subidos
INSERT INTO auditoria.evento (actor_usuario, entidad, entidad_id, accion, detalle, origen_app, ocurrido_en)
SELECT a.subido_por, a.entidad, a.id, 'INSERT',
       jsonb_build_object('archivo', a.nombre_archivo, 'mime', a.mime_type),
       'web', a.subido_en
FROM operacion.adjunto a;

-- Evento: cambios de estado (STATE_CHANGE)
INSERT INTO auditoria.evento (actor_usuario, entidad, entidad_id, accion, detalle, origen_app, ocurrido_en)
SELECT h.cambiado_por, 'inspeccion', h.inspeccion_id, 'STATE_CHANGE',
       jsonb_build_object('estado_id', h.estado_id),
       'web', h.cambiado_en
FROM auditoria.inspeccion_estado_historial h
WHERE h.cambiado_en >= '2025-08-10 12:30-03';
```

# Seguimiento de buenas prácticas

## Renombramiento de las tablas
```sql
-- Esquema seguridad
ALTER TABLE seguridad.usuario RENAME TO sdg_usuario;
ALTER TABLE seguridad.rol RENAME TO sdg_rol;
ALTER TABLE seguridad.usuario_rol RENAME TO sdg_usuario_rol;

-- Esquema catalogo
ALTER TABLE catalogo.material_tuberia RENAME TO sdg_material_tuberia;
ALTER TABLE catalogo.tipo_tramo RENAME TO sdg_tipo_tramo;
ALTER TABLE catalogo.estado_inspeccion RENAME TO sdg_estado_inspeccion;
ALTER TABLE catalogo.tipo_hallazgo RENAME TO sdg_tipo_hallazgo;
ALTER TABLE catalogo.severidad RENAME TO sdg_severidad;
ALTER TABLE catalogo.tipo_intervencion RENAME TO sdg_tipo_intervencion;
ALTER TABLE catalogo.motivo_reasignacion RENAME TO sdg_motivo_reasignacion;

-- Esquema geo
ALTER TABLE geo.tramo RENAME TO sdg_tramo;
ALTER TABLE geo.punto_control RENAME TO sdg_punto_control;

-- Esquema operacion
ALTER TABLE operacion.tecnico RENAME TO sdg_tecnico;
ALTER TABLE operacion.inspeccion RENAME TO sdg_inspeccion;
ALTER TABLE operacion.inspeccion_tramo RENAME TO sdg_inspeccion_tramo;
ALTER TABLE operacion.asignacion RENAME TO sdg_asignacion;
ALTER TABLE operacion.tracking_posicion RENAME TO sdg_tracking_posicion;
ALTER TABLE operacion.trayecto RENAME TO sdg_trayecto;
ALTER TABLE operacion.hallazgo RENAME TO sdg_hallazgo;
ALTER TABLE operacion.intervencion RENAME TO sdg_intervencion;
ALTER TABLE operacion.adjunto RENAME TO sdg_adjunto;

-- Esquema auditoria
ALTER TABLE auditoria.evento RENAME TO sdg_evento;
ALTER TABLE auditoria.inspeccion_estado_historial RENAME TO sdg_inspeccion_estado_historial;
ALTER TABLE auditoria.reasignacion_historial RENAME TO sdg_reasignacion_historial;
ALTER TABLE auditoria.tramo_version RENAME TO sdg_tramo_version;
```
## Renombramiento de vistas
```sql
ALTER VIEW operacion.v_inspeccion_estado_actual RENAME TO sdg_vw_inspeccion_estado_actual;
ALTER VIEW auditoria.v_inspeccion_ultimo_estado RENAME TO sdg_vw_inspeccion_ultimo_estado;
```
## Renombramiento de índices
```sql
-- =========================
-- AUDITORIA
-- =========================
-- Índice normal
BEGIN;
ALTER INDEX auditoria.evento_entidad_entidad_id_ocurrido_en_idx
  RENAME TO idx_sdg_evento_entidad_entidad_id_ocurrido_en;

-- PK
ALTER TABLE auditoria.sdg_evento
  RENAME CONSTRAINT evento_pkey TO pk_sdg_evento_id;

-- Historial de estados
ALTER INDEX auditoria.inspeccion_estado_historial_inspeccion_id_cambiado_en_idx
  RENAME TO idx_sdg_inspeccion_estado_historial_insp_fecha;

ALTER TABLE auditoria.sdg_inspeccion_estado_historial
  RENAME CONSTRAINT inspeccion_estado_historial_pkey TO pk_sdg_inspeccion_estado_historial_id;

-- Historial de reasignaciones
ALTER INDEX auditoria.reasignacion_historial_inspeccion_id_reasignado_en_idx
  RENAME TO idx_sdg_reasignacion_historial_insp_fecha;

ALTER TABLE auditoria.sdg_reasignacion_historial
  RENAME CONSTRAINT reasignacion_historial_pkey TO pk_sdg_reasignacion_historial_id;

-- Versionado de tramo (exclusión + PK)
ALTER TABLE auditoria.sdg_tramo_version
  RENAME CONSTRAINT tramo_version_no_overlap TO ex_sdg_tramo_version_no_overlap;

ALTER TABLE auditoria.sdg_tramo_version
  RENAME CONSTRAINT tramo_version_pkey TO pk_sdg_tramo_version_id;

-- =========================
-- GEO
-- =========================
-- Punto de control
ALTER TABLE geo.sdg_punto_control
  RENAME CONSTRAINT punto_control_codigo_key TO uq_sdg_punto_control_codigo;

ALTER INDEX geo.punto_control_geom_idx
  RENAME TO idx_sdg_punto_control_geom;

ALTER TABLE geo.sdg_punto_control
  RENAME CONSTRAINT punto_control_pkey TO pk_sdg_punto_control_id;

-- Tramo
ALTER TABLE geo.sdg_tramo
  RENAME CONSTRAINT tramo_codigo_key TO uq_sdg_tramo_codigo;

ALTER INDEX geo.tramo_geom_idx
  RENAME TO idx_sdg_tramo_geom;

ALTER TABLE geo.sdg_tramo
  RENAME CONSTRAINT tramo_pkey TO pk_sdg_tramo_id;

-- =========================
-- OPERACION
-- =========================
-- Adjunto
ALTER INDEX operacion.adjunto_entidad_entidad_id_idx
  RENAME TO idx_sdg_adjunto_entidad_entidad_id;

ALTER TABLE operacion.sdg_adjunto
  RENAME CONSTRAINT adjunto_pkey TO pk_sdg_adjunto_id;

-- Asignacion (exclusión + PK)
ALTER TABLE operacion.sdg_asignacion
  RENAME CONSTRAINT asignacion_no_overlap TO ex_sdg_asignacion_no_overlap;

ALTER TABLE operacion.sdg_asignacion
  RENAME CONSTRAINT asignacion_pkey TO pk_sdg_asignacion_id;

-- Hallazgo
ALTER INDEX operacion.hallazgo_inspeccion_tramo_id_idx
  RENAME TO idx_sdg_hallazgo_inspeccion_tramo_id;

ALTER TABLE operacion.sdg_hallazgo
  RENAME CONSTRAINT hallazgo_pkey TO pk_sdg_hallazgo_id;

ALTER INDEX operacion.hallazgo_tipo_id_severidad_id_detectado_en_idx
  RENAME TO idx_sdg_hallazgo_tipo_severidad_fecha;

ALTER INDEX operacion.hallazgo_ubicacion_idx
  RENAME TO idx_sdg_hallazgo_ubicacion;

-- Inspeccion
ALTER TABLE operacion.sdg_inspeccion
  RENAME CONSTRAINT inspeccion_codigo_key TO uq_sdg_inspeccion_codigo;

ALTER INDEX operacion.inspeccion_estado_id_planificada_desde_planificada_hasta_idx
  RENAME TO idx_sdg_inspeccion_estado_planif;

ALTER TABLE operacion.sdg_inspeccion
  RENAME CONSTRAINT inspeccion_pkey TO pk_sdg_inspeccion_id;

-- Inspeccion_tramo (dos UNIQUE + PK)
ALTER TABLE operacion.sdg_inspeccion_tramo
  RENAME CONSTRAINT inspeccion_tramo_inspeccion_id_orden_key TO uq_sdg_inspeccion_tramo_insp_orden;

ALTER TABLE operacion.sdg_inspeccion_tramo
  RENAME CONSTRAINT inspeccion_tramo_inspeccion_id_tramo_id_key TO uq_sdg_inspeccion_tramo_insp_tramo;

ALTER TABLE operacion.sdg_inspeccion_tramo
  RENAME CONSTRAINT inspeccion_tramo_pkey TO pk_sdg_inspeccion_tramo_id;

-- Intervencion
ALTER TABLE operacion.sdg_intervencion
  RENAME CONSTRAINT intervencion_pkey TO pk_sdg_intervencion_id;

ALTER INDEX operacion.intervencion_tipo_id_realizado_en_idx
  RENAME TO idx_sdg_intervencion_tipo_fecha;

-- Tecnico
ALTER TABLE operacion.sdg_tecnico
  RENAME CONSTRAINT tecnico_legajo_key TO uq_sdg_tecnico_legajo;

ALTER TABLE operacion.sdg_tecnico
  RENAME CONSTRAINT tecnico_usuario_id_key TO uq_sdg_tecnico_usuario;

ALTER TABLE operacion.sdg_tecnico
  RENAME CONSTRAINT tecnico_pkey TO pk_sdg_tecnico_id;

-- Tracking_posicion
ALTER TABLE operacion.sdg_tracking_posicion
  RENAME CONSTRAINT tracking_posicion_inspeccion_id_tecnico_id_tomado_en_key
  TO uq_sdg_tracking_posicion_inspeccion_tecnico_tiempo;

ALTER INDEX operacion.tracking_posicion_inspeccion_id_tomado_en_idx
  RENAME TO idx_sdg_tracking_posicion_insp_tiempo;

ALTER TABLE operacion.sdg_tracking_posicion
  RENAME CONSTRAINT tracking_posicion_pkey TO pk_sdg_tracking_posicion_id;

ALTER INDEX operacion.tracking_posicion_punto_idx
  RENAME TO idx_sdg_tracking_posicion_punto;

-- Trayecto
ALTER INDEX operacion.trayecto_linea_idx
  RENAME TO idx_sdg_trayecto_linea;

-- PK de trayecto (la PK es inspeccion_id)
ALTER TABLE operacion.sdg_trayecto
  RENAME CONSTRAINT trayecto_pkey TO pk_sdg_trayecto_inspeccion_id;
COMMIT;
```

## Renombramiento de claves primarias y foráneas
```sql
ALTER TABLE seguridad.sdg_usuario     RENAME CONSTRAINT usuario_pkey TO pk_sdg_usuario_id;
ALTER TABLE seguridad.sdg_rol         RENAME CONSTRAINT rol_pkey TO pk_sdg_rol_id;
ALTER TABLE seguridad.sdg_usuario_rol RENAME CONSTRAINT usuario_rol_pkey TO pk_sdg_usuario_rol;

-- Ejemplo de foráneas (ajustá nombres exactos según tu pg_dump):
ALTER TABLE operacion.sdg_tecnico RENAME CONSTRAINT tecnico_usuario_id_fkey TO fk_sdg_tecnico_usuario;
ALTER TABLE operacion.sdg_inspeccion_tramo RENAME CONSTRAINT inspeccion_tramo_tramo_id_fkey TO fk_sdg_inspeccion_tramo_tramo;
ALTER TABLE operacion.sdg_asignacion RENAME CONSTRAINT asignacion_inspeccion_id_fkey TO fk_sdg_asignacion_inspeccion;
```

## Validación superficial
```sql
sistema_gas-*> \dt *.*sdg_*
                         List of relations
  Schema   |              Name               | Type  |    Owner
-----------+---------------------------------+-------+--------------
 auditoria | sdg_evento                      | table | neondb_owner
 auditoria | sdg_inspeccion_estado_historial | table | neondb_owner
 auditoria | sdg_reasignacion_historial      | table | neondb_owner
 auditoria | sdg_tramo_version               | table | neondb_owner
 catalogo  | sdg_estado_inspeccion           | table | neondb_owner
 catalogo  | sdg_material_tuberia            | table | neondb_owner
 catalogo  | sdg_motivo_reasignacion         | table | neondb_owner
 catalogo  | sdg_severidad                   | table | neondb_owner
 catalogo  | sdg_tipo_hallazgo               | table | neondb_owner
 catalogo  | sdg_tipo_intervencion           | table | neondb_owner
 catalogo  | sdg_tipo_tramo                  | table | neondb_owner
 geo       | sdg_punto_control               | table | neondb_owner
 geo       | sdg_tramo                       | table | neondb_owner
 operacion | sdg_adjunto                     | table | neondb_owner
 operacion | sdg_asignacion                  | table | neondb_owner
 operacion | sdg_hallazgo                    | table | neondb_owner
 operacion | sdg_inspeccion                  | table | neondb_owner
 operacion | sdg_inspeccion_tramo            | table | neondb_owner
 operacion | sdg_intervencion                | table | neondb_owner
 operacion | sdg_tecnico                     | table | neondb_owner
 operacion | sdg_tracking_posicion           | table | neondb_owner
 operacion | sdg_trayecto                    | table | neondb_owner
 seguridad | sdg_rol                         | table | neondb_owner
 seguridad | sdg_usuario                     | table | neondb_owner
 seguridad | sdg_usuario_rol                 | table | neondb_owner
(25 rows)

sistema_gas-*> \dv *.*sdg_*
                         List of relations
  Schema   |              Name               | Type |    Owner
-----------+---------------------------------+------+--------------
 auditoria | sdg_vw_inspeccion_ultimo_estado | view | neondb_owner
 operacion | sdg_vw_inspeccion_estado_actual | view | neondb_owner
(2 rows)
```

(Este trabajo me pasó por apurado)

---

# Ingesta de datos adicionales
## Técnicos adicionales
```sql
-- Agrego 2 técnicos más a partir de usuarios existentes
INSERT INTO operacion.sdg_tecnico (usuario_id, legajo, habilitado)
SELECT id, 'TEC-003', TRUE FROM seguridad.sdg_usuario WHERE username = 'jrojas'
ON CONFLICT DO NOTHING;

INSERT INTO operacion.sdg_tecnico (usuario_id, legajo, habilitado)
SELECT id, 'TEC-004', TRUE FROM seguridad.sdg_usuario WHERE username = 'cmendez'
ON CONFLICT DO NOTHING;
```

## Más tramos (TR-101..TR-116) y puntos de control (PC-101..PC-116)
```sql
-- 16 tramos sintéticos (líneas cortas dentro del mismo bounding box)
INSERT INTO geo.sdg_tramo (codigo, tipo_id, material_id, diametro_mm, presion_oper_kpa, instalado_en, geom, creado_por)
SELECT
  format('TR-%03s', i)                        AS codigo,
  1 + (i % 3)                                 AS tipo_id,          -- Distribución/Transporte/Ramal
  1 + (i % 4)                                 AS material_id,      -- Acero/PEAD/Fundición/PVC
  63 + (i % 5) * 50                           AS diametro_mm,
  150 + (i % 6) * 50                          AS presion_oper_kpa,
  DATE '2012-01-01' + (i % 300)               AS instalado_en,
  ST_SetSRID(ST_MakeLine(
    ST_MakePoint(-57.965 + (i-100)*0.002, -34.925 + (i % 5)*0.001),
    ST_MakePoint(-57.963 + (i-100)*0.002, -34.923 + (i % 5)*0.001)
  ), 4326)                                    AS geom,
  u.id                                        AS creado_por
FROM generate_series(101,116) i
CROSS JOIN (SELECT id FROM seguridad.sdg_usuario WHERE username='marias') u
ON CONFLICT DO NOTHING;

-- 16 puntos de control asociados al área
INSERT INTO geo.sdg_punto_control (codigo, descripcion, geom)
SELECT
  format('PC-%03s', i),
  format('Punto de control %s', i),
  ST_SetSRID(ST_MakePoint(-57.970 + i*0.002, -34.930 + (i % 6)*0.001), 4326)
FROM generate_series(101,116) i
ON CONFLICT DO NOTHING;
```

## Muchas inspecciones (INSP-2025-101..108) + historial básico

```sql
-- 8 inspecciones nuevas
INSERT INTO operacion.sdg_inspeccion (codigo, descripcion, estado_id, planificada_desde, planificada_hasta, prioridad, creado_por)
SELECT
  format('INSP-2025-%03s', i),
  format('Inspección masiva %s', i),
  CASE WHEN i % 3 = 0 THEN 2 ELSE 1 END,                                     -- Planificada o Asignada
  TIMESTAMP '2025-08-12 09:00:00-03' + ((i-101) * INTERVAL '6 hours'),
  TIMESTAMP '2025-08-12 12:00:00-03' + ((i-101) * INTERVAL '6 hours'),
  1 + (i % 5),
  u.id
FROM generate_series(101,108) i
CROSS JOIN (SELECT id FROM seguridad.sdg_usuario WHERE username='marias') u
ON CONFLICT DO NOTHING;

-- Historial de estado inicial (Planificada) y Asignada para algunas
INSERT INTO auditoria.sdg_inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
SELECT i.id, 1, u.id, i.planificada_desde - INTERVAL '1 day'
FROM operacion.sdg_inspeccion i
JOIN seguridad.sdg_usuario u ON u.username='marias'
WHERE i.codigo LIKE 'INSP-2025-1%';

INSERT INTO auditoria.sdg_inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
SELECT i.id, 2, u.id, i.planificada_desde - INTERVAL '2 hours'
FROM operacion.sdg_inspeccion i
JOIN seguridad.sdg_usuario u ON u.username='marias'
WHERE i.codigo LIKE 'INSP-2025-1%' AND (substring(i.codigo from '\d+$')::int % 2 = 0);

-- Vincular cada inspección con 3 tramos: TR-101..TR-116 rotando
INSERT INTO operacion.sdg_inspeccion_tramo (inspeccion_id, tramo_id, orden)
SELECT i.id, t.id, rn
FROM (
  SELECT id, codigo,
         ROW_NUMBER() OVER (ORDER BY codigo) AS ix
  FROM operacion.sdg_inspeccion
  WHERE codigo LIKE 'INSP-2025-1%'
) i
JOIN LATERAL (
  SELECT t.id,
         ROW_NUMBER() OVER (ORDER BY t.codigo) AS rn
  FROM geo.sdg_tramo t
  WHERE t.codigo BETWEEN 'TR-101' AND 'TR-116'
  ORDER BY t.codigo
  OFFSET ((i.ix-1)*3) % 12   -- desplaza de a 3, con wrap sobre 12
  LIMIT 3
) t ON TRUE
ON CONFLICT DO NOTHING;
```

## Asignaciones (rotando técnicos)
```sql
WITH insps AS (
  SELECT
    i.id,
    i.codigo,
    i.planificada_desde,
    i.planificada_hasta,
    ROW_NUMBER() OVER (ORDER BY i.codigo) AS rn
  FROM operacion.sdg_inspeccion i
  WHERE i.codigo LIKE 'INSP-2025-1%'
),
tecs AS (
  SELECT
    t.id,
    t.legajo,
    ROW_NUMBER() OVER (ORDER BY t.legajo) AS trn
  FROM operacion.sdg_tecnico t
),
cnt AS (
  SELECT COUNT(*)::int AS n FROM tecs
)
INSERT INTO operacion.sdg_asignacion (inspeccion_id, tecnico_id, periodo, asignado_por, motivo_id)
SELECT
  i.id,
  t.id,
  tstzrange(i.planificada_desde - INTERVAL '30 min',
            i.planificada_hasta + INTERVAL '30 min', '[)'),
  u.id,
  1 + ((i.rn - 1) % 4)  -- si querés que también rote el motivo (1..4)
FROM insps i
CROSS JOIN cnt c
JOIN tecs t
  ON t.trn = ((i.rn - 1) % c.n) + 1
JOIN seguridad.sdg_usuario u ON u.username = 'marias';
```

## Tracking masivo (cada 10 min)
```sql
-- Para cada inspección, generamos puntos cada 10 minutos sobre una línea sintética
INSERT INTO operacion.sdg_tracking_posicion (inspeccion_id, tecnico_id, tomado_en, punto, precision_m, fuente)
SELECT
  i.id,
  a.tecnico_id,
  g.ts,
  ST_SetSRID(ST_MakePoint(
      -57.960 + (ROW_NUMBER() OVER (ORDER BY i.codigo)::int) * 0.002 + (EXTRACT(EPOCH FROM g.ts - i.planificada_desde)/600.0)*0.0003,
      -34.920 + (ROW_NUMBER() OVER (ORDER BY i.codigo)::int) * 0.001 + (EXTRACT(EPOCH FROM g.ts - i.planificada_desde)/600.0)*0.0002
  ), 4326),
  3.0 + (random()*2.0),
  'gps'
FROM operacion.sdg_inspeccion i
JOIN operacion.sdg_asignacion a ON a.inspeccion_id = i.id
JOIN LATERAL (
  SELECT generate_series(i.planificada_desde, i.planificada_hasta, INTERVAL '10 min') AS ts
) g ON TRUE
WHERE i.codigo LIKE 'INSP-2025-1%';
```
## Hallazgos en cantidad (uno por tramo, a veces dos)
```sql
-- Un hallazgo por cada (inspeccion,tramo) + un segundo hallazgo alterno
-- Ubicación = punto interpolado sobre la geometría del tramo (25% y 75%)
INSERT INTO operacion.sdg_hallazgo (inspeccion_tramo_id, tipo_id, severidad_id, descripcion, ubicacion, detectado_en, detectado_por)
SELECT
  it.id,
  1 + ((ROW_NUMBER() OVER (ORDER BY it.id)) % 5) AS tipo_id,           -- ciclo de tipos
  1 + ((ROW_NUMBER() OVER (ORDER BY it.id)) % 4) AS severidad_id,      -- ciclo de severidades
  format('Hallazgo auto %s', ROW_NUMBER() OVER (ORDER BY it.id)),
  ST_LineInterpolatePoint(t.geom, 0.25),
  i.planificada_desde + INTERVAL '45 min',
  a.tecnico_id
FROM operacion.sdg_inspeccion_tramo it
JOIN operacion.sdg_inspeccion i ON i.id = it.inspeccion_id
JOIN geo.sdg_tramo t            ON t.id = it.tramo_id
JOIN operacion.sdg_asignacion a ON a.inspeccion_id = i.id
WHERE i.codigo LIKE 'INSP-2025-1%';

-- Segundo hallazgo (en ~50% de los casos)
INSERT INTO operacion.sdg_hallazgo (inspeccion_tramo_id, tipo_id, severidad_id, descripcion, ubicacion, detectado_en, detectado_por)
SELECT
  it.id,
  1 + ((ROW_NUMBER() OVER (ORDER BY it.id)) % 5),
  1 + ((ROW_NUMBER() OVER (ORDER BY it.id)) % 4),
  format('Hallazgo secundario %s', ROW_NUMBER() OVER (ORDER BY it.id)),
  ST_LineInterpolatePoint(t.geom, 0.75),
  i.planificada_desde + INTERVAL '65 min',
  a.tecnico_id
FROM (
  SELECT it.*, ROW_NUMBER() OVER (ORDER BY it.id) AS rn
  FROM operacion.sdg_inspeccion_tramo it
  JOIN operacion.sdg_inspeccion i ON i.id = it.inspeccion_id
  WHERE i.codigo LIKE 'INSP-2025-1%'
) it
JOIN operacion.sdg_inspeccion i ON i.id = it.inspeccion_id
JOIN geo.sdg_tramo t            ON t.id = it.tramo_id
JOIN operacion.sdg_asignacion a ON a.inspeccion_id = i.id
WHERE (it.rn % 2 = 0);
```
## Intervenciones (≈70% de hallazgos cerrados)
```sql
-- Elegimos “pares” por número de fila para simular 70% de cobertura
WITH h AS (
  SELECT h.*, ROW_NUMBER() OVER (ORDER BY h.id) AS rn
  FROM operacion.sdg_hallazgo h
  JOIN operacion.sdg_inspeccion_tramo it ON it.id = h.inspeccion_tramo_id
  JOIN operacion.sdg_inspeccion i ON i.id = it.inspeccion_id
  WHERE i.codigo LIKE 'INSP-2025-1%'
)
INSERT INTO operacion.sdg_intervencion (hallazgo_id, tipo_id, descripcion, realizado_por, realizado_en)
SELECT
  h.id,
  CASE WHEN (h.rn % 3)=0 THEN 3 ELSE 1 END AS tipo_id, -- Sellado/Rep
  CASE WHEN (h.rn % 3)=0 THEN 'Recubrimiento anticorrosivo' ELSE 'Reparación estándar' END,
  h.detectado_por,
  h.detectado_en + INTERVAL '40 min'
FROM h
WHERE (h.rn % 10) <> 1;  -- ~90% menos 10% ≈ 80% (ajustá a gusto)
```
## Adjuntos (evidencia y actas)
```sql
-- Evidencias para 50 hallazgos más recientes
INSERT INTO operacion.sdg_adjunto (entidad, entidad_id, nombre_archivo, mime_type, url, subido_por, subido_en)
SELECT 'hallazgo', h.id,
       format('evidencia_%s.jpg', ROW_NUMBER() OVER (ORDER BY h.detectado_en DESC)),
       'image/jpeg',
       format('s3://bucket/evidencias/%s.jpg', h.id),
       u.id,
       h.detectado_en + INTERVAL '5 min'
FROM operacion.sdg_hallazgo h
JOIN seguridad.sdg_usuario u ON u.username='lrodriguez'
ORDER BY h.detectado_en DESC
LIMIT 50;

-- Actas para intervenciones
INSERT INTO operacion.sdg_adjunto (entidad, entidad_id, nombre_archivo, mime_type, url, subido_por, subido_en)
SELECT 'intervencion', iv.id,
       format('acta_%s.pdf', iv.id),
       'application/pdf',
       format('s3://bucket/actas/%s.pdf', iv.id),
       u.id,
       iv.realizado_en + INTERVAL '10 min'
FROM operacion.sdg_intervencion iv
JOIN seguridad.sdg_usuario u ON u.username='marias';
```
## Cierre de algunas inspecciones para completar el ciclo
```sql
-- Marcamos varias como En proceso y Cerradas
INSERT INTO auditoria.sdg_inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
SELECT i.id, 3, u.id, i.planificada_desde + INTERVAL '10 min'
FROM operacion.sdg_inspeccion i
JOIN seguridad.sdg_usuario u ON u.username='marias'
WHERE i.codigo LIKE 'INSP-2025-1%' AND (substring(i.codigo from '\d+$')::int % 3 = 0);

INSERT INTO auditoria.sdg_inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
SELECT i.id, 5, u.id, i.planificada_hasta + INTERVAL '20 min'
FROM operacion.sdg_inspeccion i
JOIN seguridad.sdg_usuario u ON u.username='marias'
WHERE i.codigo LIKE 'INSP-2025-1%' AND (substring(i.codigo from '\d+$')::int % 3 = 0);
```

# Triggers de auditoría (funciones + triggers)

## Generación de triggers
- Estándar en uso: todo bajo auditoria, con prefijo "**sdg_**".
- Actoría: permitimos setear el actor desde la app con **SET LOCAL app.current_user_id** / **app.current_tecnico_id**. Si no está seteado, queda **NULL**.
```sql
-- ================================
-- Helpers: obtener actor actual
-- ================================
CREATE OR REPLACE FUNCTION auditoria.sdg_actor_usuario()
RETURNS uuid LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.current_user_id', true),'')::uuid
$$;

CREATE OR REPLACE FUNCTION auditoria.sdg_actor_tecnico()
RETURNS uuid LANGUAGE sql STABLE AS $$
  SELECT NULLIF(current_setting('app.current_tecnico_id', true),'')::uuid
$$;

-- ===========================================
-- Trigger genérico: INSERT/UPDATE/DELETE row
-- ===========================================
CREATE OR REPLACE FUNCTION auditoria.sdg_trg_audit_row()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_entidad text := regexp_replace(TG_TABLE_NAME, '^sdg_', '');
  v_actor_usuario uuid := auditoria.sdg_actor_usuario();
  v_actor_tecnico uuid := auditoria.sdg_actor_tecnico();
  v_detalle jsonb;
BEGIN
  IF (TG_OP = 'INSERT') THEN
    v_detalle := jsonb_build_object('new', to_jsonb(NEW));
    INSERT INTO auditoria.sdg_evento (ocurrido_en, actor_usuario, actor_tecnico, entidad, entidad_id, accion, detalle, origen_app)
    VALUES (now(), v_actor_usuario, v_actor_tecnico, v_entidad, NEW.id, 'INSERT', v_detalle, current_setting('application_name', true));
    RETURN NEW;
  ELSIF (TG_OP = 'UPDATE') THEN
    v_detalle := jsonb_build_object('old', to_jsonb(OLD), 'new', to_jsonb(NEW));
    INSERT INTO auditoria.sdg_evento (ocurrido_en, actor_usuario, actor_tecnico, entidad, entidad_id, accion, detalle, origen_app)
    VALUES (now(), v_actor_usuario, v_actor_tecnico, v_entidad, COALESCE(NEW.id, OLD.id), 'UPDATE', v_detalle, current_setting('application_name', true));
    RETURN NEW;
  ELSIF (TG_OP = 'DELETE') THEN
    v_detalle := jsonb_build_object('old', to_jsonb(OLD));
    INSERT INTO auditoria.sdg_evento (ocurrido_en, actor_usuario, actor_tecnico, entidad, entidad_id, accion, detalle, origen_app)
    VALUES (now(), v_actor_usuario, v_actor_tecnico, v_entidad, OLD.id, 'DELETE', v_detalle, current_setting('application_name', true));
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

-- Aplico el genérico a entidades operativas clave
DROP TRIGGER IF EXISTS sdg_tr_audit_hallazgo     ON operacion.sdg_hallazgo;
DROP TRIGGER IF EXISTS sdg_tr_audit_intervencion ON operacion.sdg_intervencion;
DROP TRIGGER IF EXISTS sdg_tr_audit_adjunto      ON operacion.sdg_adjunto;
DROP TRIGGER IF EXISTS sdg_tr_audit_tramo        ON geo.sdg_tramo;

CREATE TRIGGER sdg_tr_audit_hallazgo
AFTER INSERT OR UPDATE OR DELETE ON operacion.sdg_hallazgo
FOR EACH ROW EXECUTE FUNCTION auditoria.sdg_trg_audit_row();

CREATE TRIGGER sdg_tr_audit_intervencion
AFTER INSERT OR UPDATE OR DELETE ON operacion.sdg_intervencion
FOR EACH ROW EXECUTE FUNCTION auditoria.sdg_trg_audit_row();

CREATE TRIGGER sdg_tr_audit_adjunto
AFTER INSERT OR UPDATE OR DELETE ON operacion.sdg_adjunto
FOR EACH ROW EXECUTE FUNCTION auditoria.sdg_trg_audit_row();

-- ================================
-- Cambio de estado de inspección
-- ================================
CREATE OR REPLACE FUNCTION auditoria.sdg_trg_inspeccion_estado()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_actor_usuario uuid := auditoria.sdg_actor_usuario();
BEGIN
  IF NEW.estado_id IS DISTINCT FROM OLD.estado_id THEN
    INSERT INTO auditoria.sdg_inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
    VALUES (NEW.id, NEW.estado_id, v_actor_usuario, now());

    INSERT INTO auditoria.sdg_evento (ocurrido_en, actor_usuario, entidad, entidad_id, accion, detalle, origen_app)
    VALUES (now(), v_actor_usuario, 'inspeccion', NEW.id, 'STATE_CHANGE',
            jsonb_build_object('old_estado_id', OLD.estado_id, 'new_estado_id', NEW.estado_id),
            current_setting('application_name', true));
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS sdg_tr_inspeccion_estado ON operacion.sdg_inspeccion;
CREATE TRIGGER sdg_tr_inspeccion_estado
AFTER UPDATE OF estado_id ON operacion.sdg_inspeccion
FOR EACH ROW EXECUTE FUNCTION auditoria.sdg_trg_inspeccion_estado();

-- ================================
-- Reasignaciones de técnicos
-- ================================
CREATE OR REPLACE FUNCTION auditoria.sdg_trg_asignacion()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_actor_usuario uuid := auditoria.sdg_actor_usuario();
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO auditoria.sdg_evento (ocurrido_en, actor_usuario, entidad, entidad_id, accion, detalle)
    VALUES (now(), v_actor_usuario, 'asignacion', NEW.id, 'ASSIGNMENT',
            jsonb_build_object('inspeccion_id', NEW.inspeccion_id, 'tecnico_id', NEW.tecnico_id, 'periodo', NEW.periodo));
    RETURN NEW;
  ELSIF (TG_OP = 'UPDATE') THEN
    IF NEW.tecnico_id IS DISTINCT FROM OLD.tecnico_id THEN
      INSERT INTO auditoria.sdg_reasignacion_historial (inspeccion_id, desde_tecnico, hacia_tecnico, motivo_id, reasignado_por, reasignado_en)
      VALUES (NEW.inspeccion_id, OLD.tecnico_id, NEW.tecnico_id, NEW.motivo_id, v_actor_usuario, now());

      INSERT INTO auditoria.sdg_evento (ocurrido_en, actor_usuario, entidad, entidad_id, accion, detalle)
      VALUES (now(), v_actor_usuario, 'asignacion', NEW.id, 'REALLOCATION',
              jsonb_build_object('inspeccion_id', NEW.inspeccion_id, 'desde_tecnico', OLD.tecnico_id, 'hacia_tecnico', NEW.tecnico_id, 'motivo_id', NEW.motivo_id));
    ELSE
      -- simple UPDATE sin cambio de técnico
      PERFORM 1;
    END IF;
    RETURN NEW;
  ELSIF (TG_OP = 'DELETE') THEN
    INSERT INTO auditoria.sdg_evento (ocurrido_en, actor_usuario, entidad, entidad_id, accion, detalle)
    VALUES (now(), v_actor_usuario, 'asignacion', OLD.id, 'DELETE',
            jsonb_build_object('inspeccion_id', OLD.inspeccion_id, 'tecnico_id', OLD.tecnico_id, 'periodo', OLD.periodo));
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS sdg_tr_asignacion ON operacion.sdg_asignacion;
CREATE TRIGGER sdg_tr_asignacion
AFTER INSERT OR UPDATE OR DELETE ON operacion.sdg_asignacion
FOR EACH ROW EXECUTE FUNCTION auditoria.sdg_trg_asignacion();

-- ===========================================
-- SCD2 de TRAMO: versionado en tramo_version
-- ===========================================
CREATE OR REPLACE FUNCTION auditoria.sdg_trg_tramo_scd2()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_now timestamptz := now();
  v_actor_usuario uuid := auditoria.sdg_actor_usuario();
BEGIN
  IF (TG_OP = 'UPDATE') AND (
       NEW.material_id IS DISTINCT FROM OLD.material_id OR
       NEW.diametro_mm IS DISTINCT FROM OLD.diametro_mm OR
       NEW.presion_oper_kpa IS DISTINCT FROM OLD.presion_oper_kpa OR
       NEW.activo IS DISTINCT FROM OLD.activo
     ) THEN
    -- Cierra la versión vigente
    UPDATE auditoria.sdg_tramo_version
      SET vigente = tsrange(lower(vigente), v_now::timestamp)
    WHERE tramo_id = NEW.id AND upper(vigente) IS NULL;

    -- Inserta la nueva
    INSERT INTO auditoria.sdg_tramo_version (tramo_id, vigente, material_id, diametro_mm, presion_oper_kpa, activo, versionado_por, versionado_en)
    VALUES (NEW.id, tsrange(v_now::timestamp, NULL), NEW.material_id, NEW.diametro_mm, NEW.presion_oper_kpa, NEW.activo, v_actor_usuario, v_now);
  END IF;

  -- Evento genérico UPDATE (ya lo deja el trigger genérico sdg_trg_audit_row)
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS sdg_tr_tramo_scd2 ON geo.sdg_tramo;
CREATE TRIGGER sdg_tr_tramo_scd2
BEFORE UPDATE OF material_id, diametro_mm, presion_oper_kpa, activo
ON geo.sdg_tramo
FOR EACH ROW EXECUTE FUNCTION auditoria.sdg_trg_tramo_scd2();

-- ===========================================
-- Validación polimórfica de ADJUNTO
-- ===========================================
CREATE OR REPLACE FUNCTION auditoria.sdg_trg_adjunto_validate()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  v_exists boolean;
BEGIN
  IF NEW.entidad = 'inspeccion' THEN
    SELECT EXISTS (SELECT 1 FROM operacion.sdg_inspeccion WHERE id = NEW.entidad_id) INTO v_exists;
  ELSIF NEW.entidad = 'hallazgo' THEN
    SELECT EXISTS (SELECT 1 FROM operacion.sdg_hallazgo WHERE id = NEW.entidad_id) INTO v_exists;
  ELSIF NEW.entidad = 'intervencion' THEN
    SELECT EXISTS (SELECT 1 FROM operacion.sdg_intervencion WHERE id = NEW.entidad_id) INTO v_exists;
  ELSIF NEW.entidad = 'tramo' THEN
    SELECT EXISTS (SELECT 1 FROM geo.sdg_tramo WHERE id = NEW.entidad_id) INTO v_exists;
  ELSE
    RAISE EXCEPTION 'Entidad inválida para adjunto: %', NEW.entidad;
  END IF;

  IF NOT v_exists THEN
    RAISE EXCEPTION 'Entidad % con id % no existe para adjunto', NEW.entidad, NEW.entidad_id;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS sdg_tr_adjunto_validate ON operacion.sdg_adjunto;
CREATE TRIGGER sdg_tr_adjunto_validate
BEFORE INSERT OR UPDATE ON operacion.sdg_adjunto
FOR EACH ROW EXECUTE FUNCTION auditoria.sdg_trg_adjunto_validate();
```
## Operaciones de prueba (genera eventos)
```sql
-- Seteo de actor (usuario y técnico) para esta sesión
-- Usuario actual
SELECT set_config(
  'app.current_user_id',
  (SELECT u.id::text FROM seguridad.sdg_usuario u WHERE u.username = 'marias'),
  true
);

-- Técnico actual
SELECT set_config(
  'app.current_tecnico_id',
  (SELECT t.id::text
   FROM operacion.sdg_tecnico t
   JOIN seguridad.sdg_usuario u ON u.id = t.usuario_id
   WHERE u.username = 'lrodriguez'),
  true
);


-- A) Cambio de estado en una inspección (genera historial + STATE_CHANGE)
UPDATE operacion.sdg_inspeccion
SET estado_id = 3  -- En proceso
WHERE codigo = 'INSP-2025-101';

UPDATE operacion.sdg_inspeccion
SET estado_id = 5  -- Cerrada
WHERE codigo = 'INSP-2025-101';

-- B) Reasignación de técnico (genera reasignacion_historial + REALLOCATION)
-- Elegimos la inspección 102
WITH i AS (
  SELECT id FROM operacion.sdg_inspeccion WHERE codigo='INSP-2025-102'
),
tecs AS (
  SELECT id, ROW_NUMBER() OVER (ORDER BY legajo) rn FROM operacion.sdg_tecnico
)
UPDATE operacion.sdg_asignacion a
SET tecnico_id = (SELECT id FROM tecs WHERE rn = 2), motivo_id = 2
WHERE a.inspeccion_id = (SELECT id FROM i)
RETURNING *;

-- C) Insert/Update/Delete de hallazgo (prueba INSERT/UPDATE/DELETE genéricos)
-- Tomo un it cualquiera de INSP-2025-103
-- 1) Crear tabla temporal para guardar el ID insertado
CREATE TEMP TABLE _h_new (id uuid) ON COMMIT DROP;

-- 2) Insertar el hallazgo y guardar el id en la temp
WITH it AS (
  SELECT it.id, i.id AS inspeccion_id, a.tecnico_id
  FROM operacion.sdg_inspeccion i
  JOIN operacion.sdg_inspeccion_tramo it ON it.inspeccion_id = i.id
  JOIN operacion.sdg_asignacion a       ON a.inspeccion_id = i.id
  WHERE i.codigo = 'INSP-2025-103'
  ORDER BY it.orden
  LIMIT 1
),
ins AS (
  INSERT INTO operacion.sdg_hallazgo (
    inspeccion_tramo_id, tipo_id, severidad_id, descripcion, ubicacion, detectado_en, detectado_por
  )
  SELECT it.id, 1, 2, 'Prueba auditoría: fuga moderada',
         ST_SetSRID(ST_MakePoint(-57.95, -34.92), 4326),
         now(), it.tecnico_id
  FROM it
  RETURNING id
)
INSERT INTO _h_new (id)
SELECT id FROM ins;

-- 3) UPDATE del hallazgo recién creado (dispara evento UPDATE)
UPDATE operacion.sdg_hallazgo
SET descripcion = 'Prueba auditoría: fuga moderada (ajustada)'
WHERE id IN (SELECT id FROM _h_new);

-- 4) DELETE del hallazgo (dispara evento DELETE)
DELETE FROM operacion.sdg_hallazgo
WHERE id IN (SELECT id FROM _h_new);

-- D) Intervención y adjunto válido (INSERTs)
-- Creo otro hallazgo real y lo cierro con intervención + adjunto
WITH it AS (
  SELECT it.id, i.id AS inspeccion_id, a.tecnico_id
  FROM operacion.sdg_inspeccion i
  JOIN operacion.sdg_inspeccion_tramo it ON it.inspeccion_id = i.id
  JOIN operacion.sdg_asignacion a ON a.inspeccion_id = i.id
  WHERE i.codigo='INSP-2025-104'
  ORDER BY it.orden DESC LIMIT 1
),
h AS (
  INSERT INTO operacion.sdg_hallazgo (inspeccion_tramo_id, tipo_id, severidad_id, descripcion, ubicacion, detectado_en, detectado_por)
  SELECT it.id, 2, 3, 'Prueba: corrosión alta', ST_SetSRID(ST_MakePoint(-57.948,-34.918),4326), now(), it.tecnico_id
  FROM it
  RETURNING id
)
INSERT INTO operacion.sdg_intervencion (hallazgo_id, tipo_id, descripcion, realizado_por, realizado_en)
SELECT id, 1, 'Reparación puntual', (SELECT tecnico_id FROM it), now()
FROM h;

-- Adjunto válido a la intervención creada recién
INSERT INTO operacion.sdg_adjunto (entidad, entidad_id, nombre_archivo, mime_type, url, subido_por, subido_en)
SELECT 'intervencion', iv.id, 'acta_prueba.pdf', 'application/pdf', 's3://bucket/actas/acta_prueba.pdf',
       (SELECT id FROM seguridad.sdg_usuario WHERE username='marias'), now()
FROM operacion.sdg_intervencion iv
ORDER BY iv.realizado_en DESC LIMIT 1;

-- E) Actualización de TRAMO que dispara SCD2
UPDATE geo.sdg_tramo
SET presion_oper_kpa = presion_oper_kpa + 25
WHERE codigo = 'TR-101';

-- F) Reasginación
UPDATE operacion.sdg_asignacion a
SET tecnico_id = (
      SELECT t.id FROM operacion.sdg_tecnico t WHERE t.legajo = 'TEC-004'
    ),
    motivo_id = 2
WHERE a.inspeccion_id = (
      SELECT id FROM operacion.sdg_inspeccion WHERE codigo = 'INSP-2025-102'
    )
RETURNING *;
```

## 3) Queries de verificación (auditoría)

A) Timeline de eventos recientes (tabla)
```sql
sistema_gas=> \pset pager off
Pager usage is off.
sistema_gas=> \x
Expanded display is on.
sistema_gas=> SELECT
  e.ocurrido_en AS time,
  e.accion,
  e.entidad,
  e.entidad_id,
  COALESCE(u.username::text, tec.legajo::text) AS actor,
  e.detalle
FROM auditoria.sdg_evento e
LEFT JOIN seguridad.sdg_usuario u ON u.id = e.actor_usuario
LEFT JOIN operacion.sdg_tecnico tec ON tec.id = e.actor_tecnico
WHERE e.ocurrido_en >= now() - INTERVAL '1 day'
ORDER BY e.ocurrido_en DESC;
-[ RECORD 1 ]----------------------------------------------------------------------
time       | 2025-10-22 00:37:14.326987+00
accion     | STATE_CHANGE
entidad    | inspeccion
entidad_id | e59843f5-4374-4e23-92e7-dedb774faac8
actor      | marias
detalle    | {"new_estado_id": 3, "old_estado_id": 1}
-[ RECORD 2 ]----------------------------------------------------------------------
time       | 2025-10-22 00:37:14.326987+00
accion     | STATE_CHANGE
entidad    | inspeccion
entidad_id | e59843f5-4374-4e23-92e7-dedb774faac8
actor      | marias
detalle    | {"new_estado_id": 5, "old_estado_id": 3}
-[ RECORD 3 ]----------------------------------------------------------------------
time       | 2025-10-22 00:37:14.326987+00
accion     | INSERT
entidad    | hallazgo
entidad_id | e312e62b-6113-4ba5-ac70-b6702dd4639a
actor      | marias
detalle    | {"new": {"id": "e312e62b-6113-4ba5-ac70-b6702dd4639a", "tipo_id": 1, "ubicacion": {"crs": {"type": "name", "properties": {"name": "EPSG:4326"}}, "type": "Point", "coordinates": [-57.95, -34.92]}, "descripcion": "Prueba auditoría: fuga moderada", "detectado_en": "2025-10-22T00:37:14.326987+00:00", "severidad_id": 2, "detectado_por": "b4df0a2b-a340-4d1a-b254-e7678d02638b", "inspeccion_tramo_id": "6512e200-1acb-4047-890a-84a25a9c8b08"}}
-[ RECORD 4 ]----------------------------------------------------------------------
time       | 2025-10-22 00:37:14.326987+00
accion     | UPDATE
entidad    | hallazgo
entidad_id | e312e62b-6113-4ba5-ac70-b6702dd4639a
actor      | marias
detalle    | {"new": {"id": "e312e62b-6113-4ba5-ac70-b6702dd4639a", "tipo_id": 1, "ubicacion": {"crs": {"type": "name", "properties": {"name": "EPSG:4326"}}, "type": "Point", "coordinates": [-57.95, -34.92]}, "descripcion": "Prueba auditoría: fuga moderada (ajustada)", "detectado_en": "2025-10-22T00:37:14.326987+00:00", "severidad_id": 2, "detectado_por": "b4df0a2b-a340-4d1a-b254-e7678d02638b", "inspeccion_tramo_id": "6512e200-1acb-4047-890a-84a25a9c8b08"}, "old": {"id": "e312e62b-6113-4ba5-ac70-b6702dd4639a", "tipo_id": 1, "ubicacion": {"crs": {"type": "name", "properties": {"name": "EPSG:4326"}}, "type": "Point", "coordinates": [-57.95, -34.92]}, "descripcion": "Prueba auditoría: fuga moderada", "detectado_en": "2025-10-22T00:37:14.326987+00:00", "severidad_id": 2, "detectado_por": "b4df0a2b-a340-4d1a-b254-e7678d02638b", "inspeccion_tramo_id": "6512e200-1acb-4047-890a-84a25a9c8b08"}}
-[ RECORD 5 ]----------------------------------------------------------------------
time       | 2025-10-22 00:37:14.326987+00
accion     | DELETE
entidad    | hallazgo
entidad_id | e312e62b-6113-4ba5-ac70-b6702dd4639a
actor      | marias
detalle    | {"old": {"id": "e312e62b-6113-4ba5-ac70-b6702dd4639a", "tipo_id": 1, "ubicacion": {"crs": {"type": "name", "properties": {"name": "EPSG:4326"}}, "type": "Point", "coordinates": [-57.95, -34.92]}, "descripcion": "Prueba auditoría: fuga moderada (ajustada)", "detectado_en": "2025-10-22T00:37:14.326987+00:00", "severidad_id": 2, "detectado_por": "b4df0a2b-a340-4d1a-b254-e7678d02638b", "inspeccion_tramo_id": "6512e200-1acb-4047-890a-84a25a9c8b08"}}
-[ RECORD 6 ]----------------------------------------------------------------------
time       | 2025-10-22 00:37:14.326987+00
accion     | INSERT
entidad    | hallazgo
entidad_id | 3b138dad-cc66-4c53-b84e-8a4e02393a83
actor      | marias
detalle    | {"new": {"id": "3b138dad-cc66-4c53-b84e-8a4e02393a83", "tipo_id": 2, "ubicacion": {"crs": {"type": "name", "properties": {"name": "EPSG:4326"}}, "type": "Point", "coordinates": [-57.948, -34.918]}, "descripcion": "Prueba: corrosión alta", "detectado_en": "2025-10-22T00:37:14.326987+00:00", "severidad_id": 3, "detectado_por": "61c9a80f-a9a1-4b4e-b276-bc8a706df6f6", "inspeccion_tramo_id": "5d19b7d6-5c68-43ee-836f-00f6f2002f3d"}}
-[ RECORD 7 ]----------------------------------------------------------------------
time       | 2025-10-22 00:37:14.326987+00
accion     | INSERT
entidad    | intervencion
entidad_id | d5edd58f-faee-4e0d-805f-25fcd31acb18
actor      | marias
detalle    | {"new": {"id": "d5edd58f-faee-4e0d-805f-25fcd31acb18", "tipo_id": 1, "descripcion": "Reparación puntual", "hallazgo_id": "3b138dad-cc66-4c53-b84e-8a4e02393a83", "realizado_en": "2025-10-22T00:37:14.326987+00:00", "realizado_por": "61c9a80f-a9a1-4b4e-b276-bc8a706df6f6"}}
-[ RECORD 8 ]----------------------------------------------------------------------
time       | 2025-10-22 00:37:14.326987+00
accion     | INSERT
entidad    | adjunto
entidad_id | d3ca7124-45bd-47fd-af24-3f3afa3c9f91
actor      | marias
detalle    | {"new": {"id": "d3ca7124-45bd-47fd-af24-3f3afa3c9f91", "url": "s3://bucket/actas/acta_prueba.pdf", "entidad": "intervencion", "mime_type": "application/pdf", "subido_en": "2025-10-22T00:37:14.326987+00:00", "entidad_id": "d5edd58f-faee-4e0d-805f-25fcd31acb18", "subido_por": "10b934ba-c300-4478-ad0e-1d9183ce78ab", "nombre_archivo": "acta_prueba.pdf"}}
```

B) Cambios de estado por inspección (tabla/series)
```sql
sistema_gas=> SELECT
  i.codigo,
  e.nombre AS estado,
  h.cambiado_en AS time
FROM auditoria.sdg_inspeccion_estado_historial h
JOIN operacion.sdg_inspeccion i ON i.id = h.inspeccion_id
JOIN catalogo.sdg_estado_inspeccion e ON e.id = h.estado_id
WHERE h.cambiado_en >= now() - INTERVAL '2 days'
ORDER BY i.codigo, h.cambiado_en;
    codigo     |   estado   |             time
---------------+------------+-------------------------------
 INSP-2025-101 | En proceso | 2025-10-22 00:37:14.326987+00
 INSP-2025-101 | Cerrada    | 2025-10-22 00:37:14.326987+00
(2 rows)
```

C) Reasignaciones (quién → quién, motivo)
```sql
sistema_gas=> SELECT
  i.codigo AS inspeccion,
  t1.legajo AS desde,
  t2.legajo AS hacia,
  mr.nombre AS motivo,
  rh.reasignado_en AS time
FROM auditoria.sdg_reasignacion_historial rh
JOIN operacion.sdg_inspeccion i ON i.id = rh.inspeccion_id
LEFT JOIN operacion.sdg_tecnico t1 ON t1.id = rh.desde_tecnico
LEFT JOIN operacion.sdg_tecnico t2 ON t2.id = rh.hacia_tecnico
LEFT JOIN catalogo.sdg_motivo_reasignacion mr ON mr.id = rh.motivo_id
WHERE rh.reasignado_en >= now() - INTERVAL '2 days'
ORDER BY rh.reasignado_en DESC;
-[ RECORD 1 ]-----------------------------
inspeccion | INSP-2025-102
desde      | TEC-002
hacia      | TEC-004
motivo     | Repriorización
time       | 2025-10-22 00:47:28.237338+00
```

D) SCD2 del tramo: versiones vigentes e históricas
```sql
sistema_gas=> SELECT
  t.codigo,
  tv.vigente,
  tv.material_id,
  tv.diametro_mm,
  tv.presion_oper_kpa,
  tv.activo,
  tv.versionado_en
FROM auditoria.sdg_tramo_version tv
JOIN geo.sdg_tramo t ON t.id = tv.tramo_id
WHERE t.codigo = 'TR-101'
ORDER BY lower(tv.vigente);
-[ RECORD 1 ]----+--------------------------------
codigo           | TR-101
vigente          | ["2025-10-22 00:37:14.326987",)
material_id      | 2
diametro_mm      | 113
presion_oper_kpa | 425.00
activo           | t
versionado_en    | 2025-10-22 00:37:14.326987+00
```

E) Resumen por tipo de acción (últimas 24h)
```sql
sistema_gas=> SELECT accion, COUNT(*) AS eventos
FROM auditoria.sdg_evento
WHERE ocurrido_en >= now() - INTERVAL '1 day'
GROUP BY accion
ORDER BY eventos DESC;
    accion    | eventos
--------------+---------
 INSERT       |       4
 STATE_CHANGE |       2
 REALLOCATION |       1
 UPDATE       |       1
 DELETE       |       1
(5 rows)
```

F) Validación de adjuntos (solo para ver que quedaron bien)
```sql
sistema_gas=> SELECT entidad, COUNT(*) AS total, MIN(subido_en) AS desde, MAX(subido_en) AS hasta
FROM operacion.sdg_adjunto
GROUP BY entidad
ORDER BY total DESC;
   entidad    | total |         desde          |             hasta
--------------+-------+------------------------+-------------------------------
 hallazgo     |    40 | 2025-08-10 12:25:00+00 | 2025-08-14 04:10:00+00
 intervencion |    37 | 2025-08-10 13:25:00+00 | 2025-10-22 00:37:14.326987+00
 inspeccion   |     1 | 2025-08-10 12:18:00+00 | 2025-08-10 12:18:00+00
 tramo        |     1 | 2025-08-09 20:45:00+00 | 2025-08-09 20:45:00+00
(4 rows)
```

---

# Datos masivos
```sql
BEGIN;

-- Contexto de sesión para auditoría
SET LOCAL application_name = 'sdg_bulk_loader_v2';
-- Actores (ajustá si querés)
SELECT set_config('app.current_user_id',
  (SELECT u.id::text FROM seguridad.sdg_usuario u WHERE u.username='marias'), true);
SELECT set_config('app.current_tecnico_id',
  (SELECT t.id::text FROM operacion.sdg_tecnico t
   JOIN seguridad.sdg_usuario u ON u.id=t.usuario_id
   WHERE u.username='lrodriguez'), true);

-- =========================================================
-- 0) Técnicos extra (por si no estaban)
-- =========================================================
INSERT INTO operacion.sdg_tecnico (usuario_id, legajo, habilitado)
SELECT u.id, 'TEC-003', TRUE
FROM seguridad.sdg_usuario u WHERE u.username='jrojas'
ON CONFLICT DO NOTHING;

INSERT INTO operacion.sdg_tecnico (usuario_id, legajo, habilitado)
SELECT u.id, 'TEC-004', TRUE
FROM seguridad.sdg_usuario u WHERE u.username='cmendez'
ON CONFLICT DO NOTHING;

-- =========================================================
-- 1) Más tramos y puntos de control (idempotente)
--    TR-101..TR-160 / PC-101..PC-160
-- =========================================================
INSERT INTO geo.sdg_tramo (codigo, tipo_id, material_id, diametro_mm, presion_oper_kpa, instalado_en, geom, creado_por)
SELECT
  format('TR-%03s', g),
  1 + (g % 3),
  1 + (g % 4),
  63 + (g % 5) * 50,
  150 + (g % 6) * 50,
  DATE '2012-01-01' + (g % 300),
  ST_SetSRID(ST_MakeLine(
    ST_MakePoint(-58.05 + g*0.0015, -34.98 + (g % 7)*0.001),
    ST_MakePoint(-58.045 + g*0.0015, -34.975 + (g % 7)*0.001)
  ), 4326),
  (SELECT id FROM seguridad.sdg_usuario WHERE username='marias')
FROM generate_series(101,160) g
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO geo.sdg_punto_control (codigo, descripcion, geom)
SELECT
  format('PC-%03s', g),
  format('Punto control %s', g),
  ST_SetSRID(ST_MakePoint(-58.10 + g*0.001, -34.99 + (g % 9)*0.001), 4326)
FROM generate_series(101,160) g
ON CONFLICT (codigo) DO NOTHING;

-- Inicializar versión de tramo (solo para los nuevos)
INSERT INTO auditoria.sdg_tramo_version (tramo_id, vigente, material_id, diametro_mm, presion_oper_kpa, activo, versionado_por)
SELECT t.id, tsrange(t.instalado_en::timestamp, NULL), t.material_id, t.diametro_mm, t.presion_oper_kpa, t.activo,
       (SELECT id FROM seguridad.sdg_usuario WHERE username='marias')
FROM geo.sdg_tramo t
WHERE t.codigo BETWEEN 'TR-101' AND 'TR-160'
  AND NOT EXISTS (SELECT 1 FROM auditoria.sdg_tramo_version tv WHERE tv.tramo_id = t.id);

-- =========================================================
-- 2) Inspecciones masivas (INSP-2025-301..420)
--    Distribuidas cada 8 horas entre 2025-08-15 y 2025-10-15
-- =========================================================
INSERT INTO operacion.sdg_inspeccion
  (codigo, descripcion, estado_id, planificada_desde, planificada_hasta, prioridad, creado_por)
SELECT
  format('INSP-2025-%03s', g),
  format('Inspección masiva %s', g),
  1,  -- Planificada (luego registramos estados)
  TIMESTAMP '2025-08-15 08:00:00-03' + (g-301) * INTERVAL '8 hours',
  TIMESTAMP '2025-08-15 12:00:00-03' + (g-301) * INTERVAL '8 hours',
  1 + (g % 5),
  (SELECT id FROM seguridad.sdg_usuario WHERE username='marias')
FROM generate_series(301,420) g
ON CONFLICT (codigo) DO NOTHING;

-- Estado inicial "Planificada"
INSERT INTO auditoria.sdg_inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
SELECT i.id, 1, (SELECT id FROM seguridad.sdg_usuario WHERE username='marias'),
       i.planificada_desde - INTERVAL '1 day'
FROM operacion.sdg_inspeccion i
WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420'
  AND NOT EXISTS (SELECT 1 FROM auditoria.sdg_inspeccion_estado_historial h WHERE h.inspeccion_id=i.id AND h.estado_id=1);

-- Vincular cada inspección a 3 tramos rotando sobre TR-101..TR-160
WITH ins AS (
  SELECT i.id, i.codigo, ROW_NUMBER() OVER (ORDER BY i.codigo) AS rn
  FROM operacion.sdg_inspeccion i
  WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420'
),
pool AS (
  SELECT t.id, t.codigo, ROW_NUMBER() OVER (ORDER BY t.codigo) AS trn
  FROM geo.sdg_tramo t
  WHERE t.codigo BETWEEN 'TR-101' AND 'TR-160'
)
INSERT INTO operacion.sdg_inspeccion_tramo (inspeccion_id, tramo_id, orden)
SELECT ins.id, p1.id, 1 FROM ins
JOIN LATERAL (SELECT id FROM pool WHERE trn = ((ins.rn-1) % 60) + 1) p1 ON TRUE
ON CONFLICT DO NOTHING;

WITH ins AS (
  SELECT i.id, i.codigo, ROW_NUMBER() OVER (ORDER BY i.codigo) AS rn
  FROM operacion.sdg_inspeccion i
  WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420'
),
pool AS (
  SELECT t.id, t.codigo, ROW_NUMBER() OVER (ORDER BY t.codigo) AS trn
  FROM geo.sdg_tramo t
  WHERE t.codigo BETWEEN 'TR-101' AND 'TR-160'
)
INSERT INTO operacion.sdg_inspeccion_tramo (inspeccion_id, tramo_id, orden)
SELECT ins.id, p2.id, 2 FROM ins
JOIN LATERAL (SELECT id FROM pool WHERE trn = ((ins.rn  ) % 60) + 1) p2 ON TRUE
ON CONFLICT DO NOTHING;

WITH ins AS (
  SELECT i.id, i.codigo, ROW_NUMBER() OVER (ORDER BY i.codigo) AS rn
  FROM operacion.sdg_inspeccion i
  WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420'
),
pool AS (
  SELECT t.id, t.codigo, ROW_NUMBER() OVER (ORDER BY t.codigo) AS trn
  FROM geo.sdg_tramo t
  WHERE t.codigo BETWEEN 'TR-101' AND 'TR-160'
)
INSERT INTO operacion.sdg_inspeccion_tramo (inspeccion_id, tramo_id, orden)
SELECT ins.id, p3.id, 3 FROM ins
JOIN LATERAL (SELECT id FROM pool WHERE trn = ((ins.rn+1) % 60) + 1) p3 ON TRUE
ON CONFLICT DO NOTHING;

-- =========================================================
-- 3) Asignaciones (rotando técnicos disponibles, 1 por inspección)
-- =========================================================
WITH ins AS (
  SELECT i.id, i.codigo, i.planificada_desde, i.planificada_hasta,
         ROW_NUMBER() OVER (ORDER BY i.codigo) AS rn
  FROM operacion.sdg_inspeccion i
  WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420'
),
tecs AS (
  SELECT t.id, t.legajo, ROW_NUMBER() OVER (ORDER BY t.legajo) AS trn
  FROM operacion.sdg_tecnico t
),
cnt AS (SELECT COUNT(*)::int AS n FROM tecs)
INSERT INTO operacion.sdg_asignacion (inspeccion_id, tecnico_id, periodo, asignado_por, motivo_id)
SELECT
  ins.id,
  tec.id,
  tstzrange(ins.planificada_desde - INTERVAL '20 min', ins.planificada_hasta + INTERVAL '40 min', '[)'),
  (SELECT id FROM seguridad.sdg_usuario WHERE username='marias'),
  1 + ((ins.rn - 1) % 4)
FROM ins
CROSS JOIN cnt
JOIN tecs tec ON tec.trn = ((ins.rn - 1) % cnt.n) + 1
WHERE NOT EXISTS (SELECT 1 FROM operacion.sdg_asignacion a WHERE a.inspeccion_id = ins.id);

-- =========================================================
-- 4) Tracking (18 puntos por inspección, cada 10 min)
-- =========================================================
INSERT INTO operacion.sdg_tracking_posicion (inspeccion_id, tecnico_id, tomado_en, punto, precision_m, fuente)
SELECT
  i.id,
  a.tecnico_id,
  i.planificada_desde + gs * INTERVAL '10 min',
  ST_SetSRID(ST_MakePoint(
    -58.06 + (ROW_NUMBER() OVER (ORDER BY i.id)) * 0.0009 + gs*0.00015,
    -34.97 + (ROW_NUMBER() OVER (ORDER BY i.id)) * 0.0006 + gs*0.00010
  ), 4326),
  2.5 + (random()*2.0),
  'gps'
FROM operacion.sdg_inspeccion i
JOIN operacion.sdg_asignacion a ON a.inspeccion_id = i.id
CROSS JOIN generate_series(0,17) gs
WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420'
  AND NOT EXISTS (
    SELECT 1 FROM operacion.sdg_tracking_posicion tp
    WHERE tp.inspeccion_id = i.id
  );

-- Generar/actualizar trayecto (línea) por inspección
INSERT INTO operacion.sdg_trayecto (inspeccion_id, linea, calculado_en)
SELECT i.id,
       ST_MakeLine(tp.punto ORDER BY tp.tomado_en),
       now()
FROM operacion.sdg_inspeccion i
JOIN operacion.sdg_tracking_posicion tp ON tp.inspeccion_id = i.id
WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420'
GROUP BY i.id
ON CONFLICT (inspeccion_id) DO UPDATE
SET linea = EXCLUDED.linea, calculado_en = now();

-- =========================================================
-- 5) Hallazgos (1..3 por inspección_tramo)
-- =========================================================
-- Uno principal al 35% del tramo
INSERT INTO operacion.sdg_hallazgo
  (inspeccion_tramo_id, tipo_id, severidad_id, descripcion, ubicacion, detectado_en, detectado_por)
SELECT
  it.id,
  1 + (ROW_NUMBER() OVER (ORDER BY it.id) % 5),
  1 + (ROW_NUMBER() OVER (ORDER BY it.id) % 4),
  format('Hallazgo principal IT:%s', it.id),
  ST_LineInterpolatePoint(t.geom, 0.35),
  i.planificada_desde + INTERVAL '50 min',
  a.tecnico_id
FROM operacion.sdg_inspeccion_tramo it
JOIN operacion.sdg_inspeccion i ON i.id = it.inspeccion_id
JOIN geo.sdg_tramo t            ON t.id = it.tramo_id
JOIN operacion.sdg_asignacion a ON a.inspeccion_id = i.id
WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420';

-- Segundo hallazgo (50% de los IT) al 70%
INSERT INTO operacion.sdg_hallazgo
  (inspeccion_tramo_id, tipo_id, severidad_id, descripcion, ubicacion, detectado_en, detectado_por)
SELECT
  it.id,
  1 + ((ROW_NUMBER() OVER (ORDER BY it.id)+1) % 5),
  1 + ((ROW_NUMBER() OVER (ORDER BY it.id)+2) % 4),
  format('Hallazgo secundario IT:%s', it.id),
  ST_LineInterpolatePoint(t.geom, 0.70),
  i.planificada_desde + INTERVAL '70 min',
  a.tecnico_id
FROM (
  SELECT it.*, ROW_NUMBER() OVER (ORDER BY it.id) AS rn
  FROM operacion.sdg_inspeccion_tramo it
  JOIN operacion.sdg_inspeccion i ON i.id = it.inspeccion_id
  WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420'
) it
JOIN operacion.sdg_inspeccion i ON i.id = it.inspeccion_id
JOIN geo.sdg_tramo t            ON t.id = it.tramo_id
JOIN operacion.sdg_asignacion a ON a.inspeccion_id = i.id
WHERE (it.rn % 2) = 0;

-- Tercer hallazgo (25% de los IT) cerca del inicio
INSERT INTO operacion.sdg_hallazgo
  (inspeccion_tramo_id, tipo_id, severidad_id, descripcion, ubicacion, detectado_en, detectado_por)
SELECT
  it.id,
  5, 2,
  'Obstrucción parcial (auto)',
  ST_LineInterpolatePoint(t.geom, 0.10),
  i.planificada_desde + INTERVAL '40 min',
  a.tecnico_id
FROM (
  SELECT it.*, ROW_NUMBER() OVER (ORDER BY it.id) AS rn
  FROM operacion.sdg_inspeccion_tramo it
  JOIN operacion.sdg_inspeccion i ON i.id = it.inspeccion_id
  WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420'
) it
JOIN operacion.sdg_inspeccion i ON i.id = it.inspeccion_id
JOIN geo.sdg_tramo t            ON t.id = it.tramo_id
JOIN operacion.sdg_asignacion a ON a.inspeccion_id = i.id
WHERE (it.rn % 4) = 0;

-- =========================================================
-- 6) Intervenciones (~70% de hallazgos)
-- =========================================================
WITH pick AS (
  SELECT h.id, h.detectado_por, h.detectado_en,
         CASE WHEN random() < 0.25 THEN 3 WHEN random() < 0.50 THEN 2 ELSE 1 END AS tipo_iv
  FROM operacion.sdg_hallazgo h
  JOIN operacion.sdg_inspeccion_tramo it ON it.id = h.inspeccion_tramo_id
  JOIN operacion.sdg_inspeccion i ON i.id = it.inspeccion_id
  WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420'
    AND random() < 0.70
)
INSERT INTO operacion.sdg_intervencion (hallazgo_id, tipo_id, descripcion, realizado_por, realizado_en)
SELECT id, tipo_iv, 'Intervención auto', detectado_por, detectado_en + INTERVAL '35 min'
FROM pick;

-- =========================================================
-- 7) Adjuntos de evidencia y actas
-- =========================================================
INSERT INTO operacion.sdg_adjunto (entidad, entidad_id, nombre_archivo, mime_type, url, subido_por, subido_en)
SELECT 'hallazgo', h.id,
       format('foto_%s.jpg', h.id),
       'image/jpeg',
       format('https://cdn.sdg.local/evidencia/%s.jpg', h.id),
       (SELECT id FROM seguridad.sdg_usuario WHERE username='lrodriguez'),
       h.detectado_en + INTERVAL '6 min'
FROM operacion.sdg_hallazgo h
JOIN operacion.sdg_inspeccion_tramo it ON it.id = h.inspeccion_tramo_id
JOIN operacion.sdg_inspeccion i ON i.id = it.inspeccion_id
WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420'
  AND random() < 0.50;

INSERT INTO operacion.sdg_adjunto (entidad, entidad_id, nombre_archivo, mime_type, url, subido_por, subido_en)
SELECT 'intervencion', iv.id,
       format('acta_%s.pdf', iv.id),
       'application/pdf',
       format('https://cdn.sdg.local/actas/%s.pdf', iv.id),
       (SELECT id FROM seguridad.sdg_usuario WHERE username='marias'),
       iv.realizado_en + INTERVAL '8 min'
FROM operacion.sdg_intervencion iv
JOIN operacion.sdg_hallazgo h ON h.id = iv.hallazgo_id
JOIN operacion.sdg_inspeccion_tramo it ON it.id = h.inspeccion_tramo_id
JOIN operacion.sdg_inspeccion i ON i.id = it.inspeccion_id
WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420'
  AND random() < 0.60;

-- =========================================================
-- 8) Cambios de estado (Asignada → En proceso → Cerrada)
--    + aplicar el estado actual en la tabla principal
-- =========================================================
-- Asignada
INSERT INTO auditoria.sdg_inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
SELECT i.id, 2, (SELECT id FROM seguridad.sdg_usuario WHERE username='marias'),
       i.planificada_desde - INTERVAL '2 hours'
FROM operacion.sdg_inspeccion i
WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420';

-- En proceso
INSERT INTO auditoria.sdg_inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
SELECT i.id, 3, (SELECT id FROM seguridad.sdg_usuario WHERE username='marias'),
       i.planificada_desde + INTERVAL '10 min'
FROM operacion.sdg_inspeccion i
WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420';

-- Cerrada (70%)
INSERT INTO auditoria.sdg_inspeccion_estado_historial (inspeccion_id, estado_id, cambiado_por, cambiado_en)
SELECT i.id, 5, (SELECT id FROM seguridad.sdg_usuario WHERE username='marias'),
       i.planificada_hasta + INTERVAL '20 min'
FROM operacion.sdg_inspeccion i
WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420'
  AND (substring(i.codigo from '\d+$')::int % 10) <> 1;

-- Reflejar último estado en la entidad principal
UPDATE operacion.sdg_inspeccion i
SET estado_id = sub.estado_id
FROM (
  SELECT DISTINCT ON (h.inspeccion_id) h.inspeccion_id, h.estado_id
  FROM auditoria.sdg_inspeccion_estado_historial h
  WHERE h.cambiado_en IS NOT NULL
  ORDER BY h.inspeccion_id, h.cambiado_en DESC
) sub
WHERE i.id = sub.inspeccion_id;

-- =========================================================
-- 9) Reasignaciones reales (dispara historial + evento)
--    Cambiamos técnico en ~20% de inspecciones
-- =========================================================
WITH tgt AS (
  SELECT i.id, i.codigo,
         ROW_NUMBER() OVER (ORDER BY i.codigo) AS rn
  FROM operacion.sdg_inspeccion i
  WHERE i.codigo BETWEEN 'INSP-2025-301' AND 'INSP-2025-420'
    AND (substring(i.codigo from '\d+$')::int % 5) = 0
),
tecs AS (
  SELECT t.id, t.legajo, ROW_NUMBER() OVER (ORDER BY t.legajo) AS trn
  FROM operacion.sdg_tecnico t
)
UPDATE operacion.sdg_asignacion a
SET tecnico_id = te.id, motivo_id = 2
FROM tgt
JOIN tecs te ON te.trn = ((tgt.rn + 1) % (SELECT COUNT(*) FROM tecs)) + 1
WHERE a.inspeccion_id = tgt.id
  AND a.tecnico_id IS DISTINCT FROM te.id;

-- =========================================================
-- 10) Cambios SCD2 en tramos (dispara versionado)
-- =========================================================
UPDATE geo.sdg_tramo
SET presion_oper_kpa = presion_oper_kpa + (25 + (random()*25))
WHERE codigo BETWEEN 'TR-101' AND 'TR-160' AND (random() < 0.25);

COMMIT;
```

# Dashboards Grafana
![[Pasted image 20251021230032.png]]

![[Pasted image 20251021230042.png]]

![[Pasted image 20251021230050.png]]

![[Pasted image 20251021230151.png]]
