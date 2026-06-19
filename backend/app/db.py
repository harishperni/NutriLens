from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import declarative_base, sessionmaker


SQLALCHEMY_DATABASE_URL = "sqlite:///./nutrilens.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


FOOD_NUMERIC_COLUMNS = {
    "added_sugar_g_per_100g": "FLOAT DEFAULT 0.0 NOT NULL",
    "net_carbs_g_per_100g": "FLOAT DEFAULT 0.0 NOT NULL",
    "saturated_fat_g_per_100g": "FLOAT DEFAULT 0.0 NOT NULL",
    "trans_fat_g_per_100g": "FLOAT DEFAULT 0.0 NOT NULL",
    "monounsaturated_fat_g_per_100g": "FLOAT DEFAULT 0.0 NOT NULL",
    "polyunsaturated_fat_g_per_100g": "FLOAT DEFAULT 0.0 NOT NULL",
    "cholesterol_mg_per_100g": "FLOAT DEFAULT 0.0 NOT NULL",
    "potassium_mg_per_100g": "FLOAT DEFAULT 0.0 NOT NULL",
    "magnesium_mg_per_100g": "FLOAT DEFAULT 0.0 NOT NULL",
    "phosphorus_mg_per_100g": "FLOAT DEFAULT 0.0 NOT NULL",
    "zinc_mg_per_100g": "FLOAT DEFAULT 0.0 NOT NULL",
    "vitamin_a_mcg_per_100g": "FLOAT DEFAULT 0.0 NOT NULL",
    "vitamin_c_mg_per_100g": "FLOAT DEFAULT 0.0 NOT NULL",
    "vitamin_d_mcg_per_100g": "FLOAT DEFAULT 0.0 NOT NULL",
    "vitamin_b12_mcg_per_100g": "FLOAT DEFAULT 0.0 NOT NULL",
    "folate_mcg_per_100g": "FLOAT DEFAULT 0.0 NOT NULL",
}


def ensure_food_columns(db_engine: Engine) -> None:
    """SQLite create_all does not add columns to existing tables."""
    if not SQLALCHEMY_DATABASE_URL.startswith("sqlite"):
        return

    with db_engine.begin() as connection:
        existing_columns = {
            row[1]
            for row in connection.exec_driver_sql("PRAGMA table_info(foods)").fetchall()
        }
        for column, definition in FOOD_NUMERIC_COLUMNS.items():
            if column not in existing_columns:
                connection.exec_driver_sql(f"ALTER TABLE foods ADD COLUMN {column} {definition}")
