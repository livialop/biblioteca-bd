from sqlalchemy import create_engine, text
from sqlalchemy.orm import Session

engine = create_engine("mysql+mysqldb://root:@localhost:3306/db_atividade17") # o Echo está sendo mantido para ver as atualizações sobre o BD
session = Session(bind=engine)

result = session.execute(text("SELECT * FROM livros"))

for row in result:
    print(row)

with engine.begin() as conn:
    autores = conn.execute(text("""SELECT * FROM Autores;""")).mappings().fetchall()
    print(autores)
    
    for row in range(0, len(autores)):
        print(autores[row]['Nome_autor'])