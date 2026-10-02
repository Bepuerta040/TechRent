# TechRent - Sistema de Gestión de Alquiler de Material Tecnológico

Repositorio para la gestión integral de bases de datos PostgreSQL  **TechRent** 
---

## 📋 Descripción del Proyecto

**TechRent** es una empresa dedicada al alquiler de material tecnológico para eventos, formación y corporaciones. Este proyecto implementa desde cero la arquitectura de bases de datos relacional para gestionar clientes, categorías, equipos, alquileres y detalles de operaciones, incorporando controles estrictos de integridad, seguridad por perfiles (RBAC), auditoría automática de transacciones y exportaciones comerciales.

---

## 🛠️ Tecnologías y Herramientas Utilizadas

* **SGBD:** PostgreSQL (compatible con versiones 14+)
* **Lenguaje:** SQL (DDL, DML, DCL), PL/pgSQL
* **Herramientas de gestión:** pgAdmin 4 / `psql`
* **Control de versiones:** Git & GitHub

---

## 📂 Estructura del Repositorio

```text
techrent_lab/
├── 01_creacion_datos.sql      # Script DDL (esquema, tablas, restricciones) e inserción de datos (DML)
├── 02_consultas.sql           # Consultas SELECT complejas y operaciones de acción (INSERT, UPDATE, DELETE)
├── 03_seguridad.sql           # Creación de roles, usuarios LOGIN y asignación de privilegios (GRANT/REVOKE)
├── 04_auditoria.sql           # Esquema de auditoría, funciones PL/pgSQL y triggers automáticos
└── equipos_comercial.csv      # Exportación en formato CSV (UTF-8) para el departamento comercial

```

---

## ⚙️ Arquitectura y Modelo de Datos

El diseño relacional consta de 5 tablas principales dentro del esquema `app`:

1. **`categorias`**: Catálogo de clasificación de equipos.
2. **`clientes`**: Información de contacto y NIF único de los clientes.
3. **`equipos`**: Inventario de material tecnológico con restricciones de stock y precio diario no negativo.
4. **`alquileres`**: Cabecera de las operaciones de alquiler asociadas a un cliente y controladas por estados (`pendiente`, `activo`, `devuelto`, `cancelado`).
5. **`detalle_alquileres`**: Entidad asociativa que resuelve la relación N:M entre alquileres y equipos, conservando el precio aplicado en el momento de la contratación.

---

## 🚀 Guía de Instalación y Ejecución

Para reproducir el entorno completo de laboratorio, ejecuta los scripts en el siguiente orden desde tu cliente PostgreSQL (`psql` o pgAdmin):

1. **Crear la base de datos y esquema:**
```sql
CREATE DATABASE techrent_lab;
\c techrent_lab
CREATE SCHEMA app;

```


2. **Ejecutar el script de creación y carga de datos (`01_creacion_datos.sql`):**
Crea la estructura física de tablas y carga los datos maestros e iniciales.
3. **Ejecutar consultas y operaciones (`02_consultas.sql`):**
Contiene las 6 consultas analíticas (con `JOIN`, funciones de agregación, subconsultas) y las 4 consultas de acción controladas.
4. **Configurar seguridad y accesos (`03_seguridad.sql`):**
Establece los perfiles de usuario (`Recepcion`, `Almacen`, `Administracion`, `Auditoria`) bajo el principio de mínimo privilegio.
5. **Implementar el sistema de auditoría (`04_auditoria.sql`):**
Configura el esquema `audit`, la tabla de registros, la función en PL/pgSQL y el disparador (`trigger`) para los cambios de estado en alquileres.

---

## 📄 Exportación Comercial

El archivo `equipos_comercial.csv` incluido en el repositorio contiene el inventario actual de equipos con cabecera y codificación UTF-8, listo para su distribución al departamento comercial.

---

## 👤 Autor

Proyecto desarrollado como parte de las actividades prácticas del módulo de gestión de bases de datos.
