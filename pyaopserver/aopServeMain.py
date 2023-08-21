from fastapi import FastAPI, HTTPException, status
from fastapi.staticfiles import StaticFiles
from sqlmodel import SQLModel, create_engine, Session, Field
import os

app = FastAPI()

# Define the database connection URL
DATABASE_URL = "mysql+mysqlconnector://photos:photos00@localhost:3306/allourphotos_asus"

# Define the Photo model
class Photo(SQLModel, table=True):
    id: int = Field(default=None, primary_key=True)
    filename: str
    description: str = None

# Create the database engine
engine = create_engine(DATABASE_URL,echo=True)

# Create the database tables
# SQLModel.metadata.create_all(engine)
@app.get('/testdb')
def testdbConnection():
  fred = engine.execute('select count(*) from  aopalbums')
  return fred

@app.post("/photosx")
def create_photo(photo: Photo):
    with Session(engine) as session:
        session.add(photo)
        session.commit()
        session.refresh(photo)
    return photo


@app.get("/photosx/{photo_id}")
def get_photo(photo_id: int):
    with Session(engine) as session:
        photo = session.get(Photo, photo_id)
        if not photo:
            return {"error": "Photo not found"}
        return photo



app.mount('/photos', StaticFiles(directory="c:\\data\\photos", check_dir=True), name="photos")   
# static root catchall must be last 
app.mount('/', StaticFiles(directory="static", html=True, check_dir=True), name="static")    

print('mounted.')

if __name__ == "__main__":
    import uvicorn

    # Run the server using Uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)

