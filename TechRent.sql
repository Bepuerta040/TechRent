-- Creación de la base de datos (Ejecutar de forma independiente si es necesario)
-- CREATE DATABASE techrent_lab;

-- Conectarse a techrent_lab y crear el esquema
CREATE SCHEMA IF NOT EXISTS app;

-- 1. Tabla de Categorías
CREATE TABLE app.categorias (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL
);

-- 2. Tabla de Clientes
CREATE TABLE app.clientes (
    id_cliente SERIAL PRIMARY KEY,
    nif VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL,
    telefono VARCHAR(30)
);

-- 3. Tabla de Equipos
CREATE TABLE app.equipos (
    id_equipo SERIAL PRIMARY KEY,
    codigo VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(150) NOT NULL,
    id_categoria INT NOT NULL,
    precio_dia NUMERIC(10,2) NOT NULL CHECK (precio_dia >= 0),
    stock INT NOT NULL CHECK (stock >= 0),
    CONSTRAINT fk_equipo_categoria FOREIGN KEY (id_categoria) 
        REFERENCES app.categorias(id_categoria) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 4. Tabla de Alquileres
CREATE TABLE app.alquileres (
    id_alquiler SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_prevista_devolucion DATE NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('pendiente', 'activo', 'devuelto', 'cancelado')),
    CONSTRAINT fk_alquiler_cliente FOREIGN KEY (id_cliente) 
        REFERENCES app.clientes(id_cliente) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_fechas_alquiler CHECK (fecha_prevista_devolucion >= fecha_inicio)
);

-- 5. Tabla de Detalle de Alquileres (Relación N:M)
CREATE TABLE app.detalle_alquileres (
    id_alquiler INT NOT NULL,
    id_equipo INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_aplicado NUMERIC(10,2) NOT NULL CHECK (precio_aplicado > 0),
    PRIMARY KEY (id_alquiler, id_equipo),
    CONSTRAINT fk_detalle_alquiler FOREIGN KEY (id_alquiler) 
        REFERENCES app.alquileres(id_alquiler) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detalle_equipo FOREIGN KEY (id_equipo) 
        REFERENCES app.equipos(id_equipo) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Inserción de Categorías
INSERT INTO app.categorias (nombre) VALUES 
('Portátiles'),
('Proyectores'),
('Audio');

-- Inserción de Clientes
INSERT INTO app.clientes (nif, nombre, email, telefono) VALUES 
('B10010010', 'Formacion Nova SL', 'info@nova.test', '600100100'),
('B20020020', 'Eventos Delta SA', 'contacto@delta.test', '600200200'),
('B30030030', 'Aula Digital SL', 'aula@digital.test', '600300300'),
('B40040040', 'Congresos BCN SL', 'gestion@congresos.test', '600400400');

-- Inserción de Equipos
INSERT INTO app.equipos (codigo, nombre, id_categoria, precio_dia, stock) VALUES 
('PORT-01', 'Portátil Lenovo ThinkPad', 1, 35.00, 8),
('PORT-02', 'Portátil Dell Latitude', 1, 32.00, 6),
('PROY-01', 'Proyector Epson X500', 2, 45.00, 4),
('PROY-02', 'Proyector BenQ M700', 2, 50.00, 3),
('AUD-01', 'Altavoz JBL Pro', 3, 25.00, 10),
('AUD-02', 'Micrófono inalámbrico', 3, 18.00, 12);

-- Inserción de Alquileres
INSERT INTO app.alquileres (id_cliente, fecha_inicio, fecha_prevista_devolucion, estado) VALUES 
(1, '2026-10-05', '2026-10-07', 'devuelto'),
(2, '2026-10-10', '2026-10-12', 'activo'),
(3, '2026-10-15', '2026-10-18', 'pendiente'),
(1, '2026-10-20', '2026-10-21', 'pendiente');

-- Inserción de Detalles de Alquileres
INSERT INTO app.detalle_alquileres (id_alquiler, id_equipo, cantidad, precio_aplicado) VALUES 
(1, 1, 2, 35.00),
(1, 3, 1, 45.00),
(2, 4, 2, 50.00),
(2, 5, 4, 25.00),
(3, 2, 3, 32.00),
(3, 6, 3, 18.00),
(4, 1, 1, 35.00),
(4, 5, 2, 25.00);

-- 1. Equipos con categoría, precio y stock, ordenados de mayor a menor precio
SELECT e.codigo, e.nombre AS equipo, c.nombre AS categoria, e.precio_dia, e.stock
FROM app.equipos e
JOIN app.categorias c ON e.id_categoria = c.id_categoria
ORDER BY e.precio_dia DESC;

-- 2. Alquileres con nombre del cliente, fechas y estado
SELECT a.id_alquiler, cl.nombre AS cliente, a.fecha_inicio, a.fecha_prevista_devolucion, a.estado
FROM app.alquileres a
JOIN app.clientes cl ON a.id_cliente = cl.id_cliente;

-- 3. Detalle de alquileres indicando cliente, equipo, cantidad, precio aplicado y coste de la línea
SELECT a.id_alquiler, cl.nombre AS cliente, eq.nombre AS equipo, 
       d.cantidad, d.precio_aplicado, (d.cantidad * d.precio_aplicado) AS coste_linea
FROM app.detalle_alquileres d
JOIN app.alquileres a ON d.id_alquiler = a.id_alquiler
JOIN app.clientes cl ON a.id_cliente = cl.id_cliente
JOIN app.equipos eq ON d.id_equipo = eq.id_equipo;

-- 4. Clientes que han realizado al menos un alquiler (sin duplicados)
SELECT DISTINCT cl.nif, cl.nombre
FROM app.clientes cl
JOIN app.alquileres a ON cl.id_cliente = a.id_cliente;

-- 5. Equipos cuyo precio diario sea superior al precio medio global
SELECT codigo, nombre, precio_dia
FROM app.equipos
WHERE precio_dia > (SELECT AVG(precio_dia) FROM app.equipos);

-- 6. Número de alquileres por cliente (incluyendo los que no tienen alquileres)
SELECT cl.nombre, COUNT(a.id_alquiler) AS total_alquileres
FROM app.clientes cl
LEFT JOIN app.alquileres a ON cl.id_cliente = a.id_cliente
GROUP BY cl.id_cliente, cl.nombre;

-- 1. INSERT: Dar de alta un nuevo cliente
INSERT INTO app.clientes (nif, nombre, email, telefono) 
VALUES ('B50050050', 'Soluciones Digitales SL', 'contacto@soluciones.test', '600500500');

-- 2. UPDATE: Cambiar el estado del alquiler 3 de 'pendiente' a 'activo'
UPDATE app.alquileres 
SET estado = 'activo' 
WHERE id_alquiler = 3;

-- 3. UPDATE: Incrementar un 5% el precio diario de los equipos de la categoría 'Proyectores'
UPDATE app.equipos 
SET precio_dia = precio_dia * 1.05 
WHERE id_categoria = (SELECT id_categoria FROM app.categorias WHERE nombre = 'Proyectores');

-- 4. DELETE: Crear equipo de prueba que no esté alquilado y eliminarlo de forma controlada
INSERT INTO app.equipos (codigo, nombre, id_categoria, precio_dia, stock) 
VALUES ('TEST-99', 'Equipo de Prueba Obsoleto', 3, 10.00, 1);

-- Verificación previa del registro a borrar
SELECT * FROM app.equipos WHERE codigo = 'TEST-99';

-- Borrado controlado mediante clave primaria/código específico
DELETE FROM app.equipos 
WHERE codigo = 'TEST-99';

-- tarea 6 --
-- 1. Crear roles de grupo NOLOGIN para cada perfil
CREATE ROLE rol_recepcion NOLOGIN;
CREATE ROLE rol_almacen NOLOGIN;
CREATE ROLE rol_administracion NOLOGIN;
CREATE ROLE rol_auditoria NOLOGIN;

-- 2. Crear usuarios LOGIN de prueba y asignarlos a sus roles
CREATE USER usr_recepcion WITH PASSWORD 'Recepcion2026*';
GRANT rol_recepcion TO usr_recepcion;

CREATE USER usr_almacen WITH PASSWORD 'Almacen2026*';
GRANT rol_almacen TO usr_almacen;

CREATE USER usr_administracion WITH PASSWORD 'Admin2026*';
GRANT rol_administracion TO usr_administracion;

CREATE USER usr_auditoria WITH PASSWORD 'Audit2026*';
GRANT rol_auditoria TO usr_auditoria;

-- 3. Concesión de conexión y uso de esquemas
GRANT CONNECT ON DATABASE techrent_lab TO rol_recepcion, rol_almacen, rol_administracion, rol_auditoria;
GRANT USAGE ON SCHEMA app TO rol_recepcion, rol_almacen, rol_administracion, rol_auditoria;

-- 4. Permisos específicos por rol (Sin usar ALL PRIVILEGES)

-- Recepción: Consultar clientes/equipos; crear alquileres y detalles.
GRANT SELECT ON app.clientes, app.equipos, app.categorias TO rol_recepcion;
GRANT SELECT, INSERT, UPDATE ON app.alquileres, app.detalle_alquileres TO rol_recepcion;
GRANT USAGE, SELECT ON SEQUENCE app.alquileres_id_alquiler_seq TO rol_recepcion;

-- Almacén: Consultar equipos y alquileres; actualizar stock y estado de alquiler.
GRANT SELECT ON app.equipos, app.alquileres, app.detalle_alquileres, app.categorias TO rol_almacen;
GRANT UPDATE (stock) ON app.equipos TO rol_almacen;
GRANT UPDATE (estado) ON app.alquileres TO rol_almacen;

-- Administración: Consultar y modificar datos operativos y precios (Control total sobre app excepto gestión de roles).
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app TO rol_administracion;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA app TO rol_administracion;

-- Auditoría: Consultar tablas operativas y la tabla de auditoría.
GRANT SELECT ON ALL TABLES IN SCHEMA app TO rol_auditoria;
GRANT USAGE ON SCHEMA audit TO rol_auditoria;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO rol_auditoria;

-- 5. Pruebas de permisos (Ejemplos):
-- * Prueba permitida para Recepción: INSERT INTO app.alquileres ... (Éxito)
-- * Prueba denegada para Recepción: DELETE FROM app.equipos ... (Denegado por permisos insuficientes)

-- 1. Crear esquema de auditoría si no existe
CREATE SCHEMA IF NOT EXISTS audit;

-- 2. Crear tabla de auditoría
CREATE TABLE audit.alquileres_audit (
    id_auditoria SERIAL PRIMARY KEY,
    id_alquiler INT,
    usuario VARCHAR(100),
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operacion VARCHAR(20),
    estado_anterior VARCHAR(20),
    estado_nuevo VARCHAR(20)
);

-- 3. Crear función de trigger en PL/pgSQL
CREATE OR REPLACE FUNCTION audit.fn_auditar_cambio_alquiler()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        IF OLD.estado IS DISTINCT FROM NEW.estado THEN
            INSERT INTO audit.alquileres_audit (id_alquiler, usuario, operacion, estado_anterior, estado_nuevo)
            VALUES (NEW.id_alquiler, current_user, TG_OP, OLD.estado, NEW.estado);
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. Crear el trigger sobre la tabla de alquileres
CREATE TRIGGER trg_auditar_alquiler
AFTER UPDATE ON app.alquileres
FOR EACH ROW
EXECUTE FUNCTION audit.fn_auditar_cambio_alquiler();

-- 5. Prueba de auditoría
-- Actualizamos el estado de un alquiler para disparar la auditoría
UPDATE app.alquileres SET estado = 'cancelado' WHERE id_alquiler = 3;

-- Consultar la tabla de auditoría para verificar el registro
SELECT * FROM audit.alquileres_audit;

-- Exportación ejecutada en consola psql o cliente compatible
\copy (SELECT codigo, nombre, (SELECT nombre FROM app.categorias c WHERE c.id_categoria = e.id_categoria) AS categoria, precio_dia, stock FROM app.equipos e) TO 'equipos_comercial.csv' WITH CSV HEADER ENCODING 'UTF8';