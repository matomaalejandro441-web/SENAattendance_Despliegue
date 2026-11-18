import os
from dotenv import load_dotenv
from sqlmodel import SQLModel, create_engine, Session

# Fuerza a Python a leer el archivo .env actualizado del disco
load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

# Control de seguridad: Si no encuentra la variable o sigue con la plantilla de ejemplo
if not DATABASE_URL or "TU_CONTRASEÑA" in DATABASE_URL:
    # Respaldo SOLO para desarrollo local
    DATABASE_URL = "mysql+pymysql://root:212202@127.0.0.1:3306/SENAattendance"

# Bases de datos en la nube (TiDB Cloud, etc.) exigen conexión cifrada (SSL).
# Se activa poniendo DB_SSL=true en las variables de entorno.
connect_args = {}
if os.getenv("DB_SSL", "false").lower() == "true":
    import certifi
    connect_args = {"ssl": {"ca": certifi.where()}}

engine = create_engine(
    DATABASE_URL,
    echo=os.getenv("SQL_ECHO", "false").lower() == "true",
    connect_args=connect_args,
    pool_pre_ping=True,   # revisa que la conexión siga viva antes de usarla
    pool_recycle=280,     # renueva conexiones antes de que la nube las cierre
)

def crear_tablas():
    SQLModel.metadata.create_all(engine)

def get_session():
    with Session(engine) as session:
        yield session
