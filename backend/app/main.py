import os
import asyncpg
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.health import router as health_router
from app.recommendations import router as recommendations_router

app = FastAPI(
    title="LaptopAI API",
    version="0.1.0",
    docs_url="/docs",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "https://localhost:3000",
        "https://laptopai.dev",
        "http://laptopai.dev",
    ],
    allow_origin_regex=r"https://([a-zA-Z0-9-]+\.)?laptopai\.dev",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(health_router, prefix="/api")
app.include_router(recommendations_router, prefix="/api")
@app.get("/api/test-db")
async def test_db():
    try:
        # Беремо URL бази з нашого секрету, який ми прокинули в кластер
        db_url = os.environ.get("DATABASE_URL")
        
        # Підключаємось до AWS RDS
        conn = await asyncpg.connect(db_url)
        
        # Створюємо тестову таблицю (якщо її ще немає)
        await conn.execute('''
            CREATE TABLE IF NOT EXISTS test_connection (
                id serial PRIMARY KEY,
                message text,
                created_at timestamp DEFAULT now()
            )
        ''')
        
        # Робимо тестовий запис
        await conn.execute('''
            INSERT INTO test_connection (message) VALUES ('Hello from k3s to AWS RDS!')
        ''')
        
        # Читаємо кількість записів, щоб переконатися, що запис зберігся
        row = await conn.fetchrow('SELECT COUNT(*) FROM test_connection')
        
        await conn.close()
        
        return {
            "status": "success", 
            "message": "AWS RDS works perfectly!", 
            "db_records_count": row["count"]
        }
        
    except Exception as e:
        return {"status": "error", "error_details": str(e)}
