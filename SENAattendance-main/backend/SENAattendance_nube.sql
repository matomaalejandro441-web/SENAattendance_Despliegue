DROP DATABASE IF EXISTS SENAattendance;
CREATE DATABASE SENAattendance;
USE SENAattendance;

-- =========================================================
-- CARRERA
-- =========================================================

CREATE TABLE Carrera(
    Id_Car INT PRIMARY KEY AUTO_INCREMENT,
    Nom_Car VARCHAR(150) NOT NULL,
    Des_Car TEXT NULL,
    Fec_Cre DATETIME DEFAULT CURRENT_TIMESTAMP,
    Fec_Mod DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =========================================================
-- FICHAS
-- =========================================================

CREATE TABLE Fichas (
    Id_Fic INT PRIMARY KEY AUTO_INCREMENT,
    Id_Car INT NOT NULL,
    Fec_inicio_Fic DATE NOT NULL,
    Fec_Fin_Fic DATE NOT NULL,
    Num_Fic INT NOT NULL UNIQUE,
    Jor_Fic ENUM("Mañana","Tarde","Noche") NOT NULL,
    Fec_Cre DATETIME DEFAULT CURRENT_TIMESTAMP,
    Fec_Mod DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY(Id_Car) REFERENCES Carrera(Id_Car)
    
);

-- =========================================================
-- COMPETENCIA
-- =========================================================

CREATE TABLE competencia(
    Id_Comp INT PRIMARY KEY AUTO_INCREMENT,
    Nom_Comp VARCHAR(150) NOT NULL,
    Des_Comp TEXT NULL,
    Fec_Cre DATETIME DEFAULT CURRENT_TIMESTAMP,
    Fec_Mod DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =========================================================
-- INSTRUCTOR
-- =========================================================

CREATE TABLE Instructor (
    Id_Ins INT PRIMARY KEY AUTO_INCREMENT,
    Nom_Ins VARCHAR(100) NOT NULL,
    Ape_Ins VARCHAR(100) NOT NULL,
    Tip_ide_Ins ENUM("CC","TI","CE","PEP","PPT") NOT NULL,
    Num_ide_Ins INT NOT NULL UNIQUE,
    Cor_Ins VARCHAR(100) NOT NULL UNIQUE,
    Con_Ins VARCHAR(255) NOT NULL,
    Es_Ins BOOLEAN NOT NULL DEFAULT TRUE,
    Fec_Cre DATETIME DEFAULT CURRENT_TIMESTAMP,
    Fec_Mod DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =========================================================
-- ADMINISTRADOR
-- =========================================================

CREATE TABLE Administrador (
    Id_Adm INT PRIMARY KEY AUTO_INCREMENT,
    Nom_Adm VARCHAR(100) NOT NULL,
    Ape_Adm VARCHAR(100) NOT NULL,
    Tip_ide_Adm ENUM("CC","TI","CE","PEP","PPT") NOT NULL,
    Num_ide_Adm INT NOT NULL UNIQUE,
    Cor_Adm VARCHAR(100) NOT NULL UNIQUE,
    Con_Adm VARCHAR(255) NOT NULL,
    Es_Adm BOOLEAN NOT NULL DEFAULT TRUE,
    Fec_Cre DATETIME DEFAULT CURRENT_TIMESTAMP,
    Fec_Mod DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- =========================================================
-- APRENDIZ
-- (Id_Fic ya nace NULL, sin necesitar el ALTER de antes)
-- =========================================================

CREATE TABLE Aprendiz (
    Id_Apr INT PRIMARY KEY AUTO_INCREMENT,
    Nom_Apr VARCHAR(100) NOT NULL,
    Ape_Apr VARCHAR(100) NOT NULL,
    Tip_ide_Apr ENUM("CC","TI","CE","PEP","PPT") NOT NULL,
    Num_ide_Apr INT NOT NULL UNIQUE,
    Cor_Apr VARCHAR(100) NOT NULL UNIQUE,
    Con_Apr VARCHAR(255) NOT NULL,
    Es_Apr BOOLEAN NOT NULL DEFAULT TRUE,
    Id_Fic INT NULL,
    Fec_Cre DATETIME DEFAULT CURRENT_TIMESTAMP,
    Fec_Mod DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (Id_Fic) REFERENCES Fichas(Id_Fic)
);


-- =========================================================
-- RESULTADO DE APRENDIZAJE
-- =========================================================

CREATE TABLE ResultadoAprendizaje (
    Id_RA INT AUTO_INCREMENT PRIMARY KEY,
    Nom_RA VARCHAR(150) NOT NULL,
    Des_RA TEXT NULL,
    Id_Comp INT NOT NULL,

    Fec_Cre DATETIME DEFAULT CURRENT_TIMESTAMP,
    Fec_Mod DATETIME DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_ra_competencia
        FOREIGN KEY (Id_Comp)
        REFERENCES competencia(Id_Comp)
);

-- =========================================================
-- FICHA_INSTRUCTOR
-- =========================================================

CREATE TABLE Ficha_Instructor (
    Id_Fic INT NOT NULL,
    Id_Ins INT NOT NULL,
    Id_RA INT NOT NULL,

    Dia ENUM(
        'Lunes',
        'Martes',
        'Miercoles',
        'Jueves',
        'Viernes',
        'Sabado'
    ) NOT NULL,

    Fec_Inicio_RA DATE NOT NULL,
    Fec_Fin_RA DATE NOT NULL,

    PRIMARY KEY (Id_Fic, Id_Ins, Id_RA, Dia),

    CONSTRAINT fk_fi_ficha
        FOREIGN KEY (Id_Fic)
        REFERENCES Fichas(Id_Fic),

    CONSTRAINT fk_fi_instructor
        FOREIGN KEY (Id_Ins)
        REFERENCES Instructor(Id_Ins),

    CONSTRAINT fk_fi_resultado
        FOREIGN KEY (Id_RA)
        REFERENCES ResultadoAprendizaje(Id_RA),

    CONSTRAINT chk_fi_fechas
        CHECK (Fec_Fin_RA >= Fec_Inicio_RA)
);

-- =========================================================
-- ASISTENCIA
-- =========================================================

CREATE TABLE Asistencia (
    Id_Asi INT AUTO_INCREMENT PRIMARY KEY,
    Fec_Asi DATE NOT NULL,

    Es_Asi ENUM(
        'Retardo',
        'Excusa',
        'Falla',
        'Presente'
    ) NOT NULL,

    Id_Apr INT NOT NULL,
    Id_Fic INT NOT NULL,
    Id_Ins INT NOT NULL,
    Id_RA INT NOT NULL,

    Dia ENUM(
        'Lunes',
        'Martes',
        'Miercoles',
        'Jueves',
        'Viernes',
        'Sabado'
    ) NOT NULL,

    Fec_Cre DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_asistencia_aprendiz
        FOREIGN KEY (Id_Apr)
        REFERENCES Aprendiz(Id_Apr),

    CONSTRAINT fk_asistencia_ficha_instructor
        FOREIGN KEY (Id_Fic, Id_Ins, Id_RA, Dia)
        REFERENCES Ficha_Instructor(Id_Fic, Id_Ins, Id_RA, Dia),

    CONSTRAINT uq_asistencia_sesion
        UNIQUE (
            Fec_Asi,
            Id_Apr,
            Id_Fic,
            Id_Ins,
            Id_RA,
            Dia
        ),

    INDEX ix_asistencia_apr_fic_fec (Id_Apr, Id_Fic, Fec_Asi)
);

-- =========================================================
-- NOTIFICACION
-- (Id_Fic, Tip_Not, Env_Not ya integrados desde el inicio)
-- =========================================================

CREATE TABLE Notificacion (
    Id_Not INT PRIMARY KEY AUTO_INCREMENT,
    Asu_Not TEXT NOT NULL,
    Men_Not TEXT NOT NULL,
    Fec_Not DATE NOT NULL,
    Id_Apr INT NULL,
    Id_Ins INT NULL,
    Id_Adm INT NULL,
    Id_Fic INT NULL,
    Tip_Not ENUM('ADVERTENCIA_ACUMULADO', 'DESERCION_RACHA', 'LISTA_NO_LLAMADA') NOT NULL,
    Env_Not TINYINT(1) NOT NULL DEFAULT 0,
    Fec_Cre DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (Id_Apr) REFERENCES Aprendiz(Id_Apr),
    FOREIGN KEY (Id_Ins) REFERENCES Instructor(Id_Ins),
    FOREIGN KEY (Id_Adm) REFERENCES Administrador(Id_Adm),
    FOREIGN KEY (Id_Fic) REFERENCES Fichas(Id_Fic)
);

-- =========================================================
-- LOG es la que guarda un historial de todo lo importante que pasa 
-- quien borro 
-- que usuario modifico 
-- a que hora lo hizo
-- =========================================================

CREATE TABLE Log (
    Id_Log INT PRIMARY KEY AUTO_INCREMENT,
    Tabla_Afectada VARCHAR(50) NOT NULL,
    Id_Registro INT NOT NULL,
    Accion ENUM("INSERT","UPDATE","DELETE") NOT NULL,
    Usu_Log VARCHAR(100) NOT NULL,
    Fec_Log DATETIME DEFAULT CURRENT_TIMESTAMP,
    Det_Log TEXT NULL
);

-- =========================================================
-- DATOS DE PRUEBA
-- =========================================================

INSERT INTO Aprendiz (Nom_Apr, Ape_Apr, Tip_ide_Apr, Num_ide_Apr, Cor_Apr, Con_Apr)
VALUES (
    'Alejandro',
    'Prueba',
    'TI',
    1234567890,
    'alejandro.prueba@sena.edu.co',
    'scrypt:32768:8:1jmAas7Lm9lfDzTZ93080f58433b821b277f640fafa71585ecc2460e8323c224d311ec63e36a7d25fc1552f16aed9998017d9602173c7f4e1203e290f8445346044581ec55814b613'
);

INSERT INTO Administrador (Nom_Adm, Ape_Adm, Tip_ide_Adm, Num_ide_Adm, Cor_Adm, Con_Adm)
VALUES (
    'Samuel',
    'Bravo',
    'CC',
    1234567897,
    'samuel.bravo@sena.edu.co',
    'scrypt:32768:8:1cOtZGeAQAHkSqeyi172e3027678cde86d1af9168592f74c581b096096c7dd403ab17c99b496142c1f0fc81a0437b691af00add46bf96f9fbca3fe0b8c69fee48ceffed72d24630a6'
);

INSERT INTO Carrera (Nom_Car, Des_Car)
VALUES (
    'ADSO',
    'Analisis y Desarrollo de software'
);

INSERT INTO Carrera (Nom_Car, Des_Car)
VALUES (
    'VOML',
    'Ventas online mercado logistico'
);

INSERT INTO Fichas (Id_Car, Fec_inicio_Fic, Fec_Fin_Fic, Num_Fic, Jor_Fic)
VALUES (
    1,
    '2026-06-29',
    '2027-06-07',
    3407184,
    'Mañana'
);

-- =========================================================
-- CONSULTAS DE VERIFICACIÓN
-- =========================================================

select * from Administrador;
select * from Aprendiz;
select * from Instructor;
select * from Fichas;
select * from competencia;

ALTER TABLE Fichas MODIFY Jor_Fic ENUM('Mañana','Tarde','Noche') NULL;  
