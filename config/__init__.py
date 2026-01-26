from flask import Flask
from flask_login import LoginManager, UserMixin
from sqlalchemy import text, create_engine
import re


# Se o seu root não tiver senha, tire o 1234 da parte do 'root:1234@localhost:3306'
# Se a porta do seu banco de dados for 3307, mude o 3306 para 3307.
ENGINE = create_engine('mysql+pymysql://root:1234@localhost:3306/db_atividade17')
# ENGINE = create_engine('mysql+mysqldb://root:1234@localhost:3306/db_atividade17')

class Usuario(UserMixin):
    def __init__(self, id_usuario, email, senha) -> None:
        self.id = id_usuario
        self.email = email
        self.senha = senha
    

def config(app: Flask):
    app.secret_key = ')*!(&!*@%&771412JIAJD)'

    login_manager: LoginManager = LoginManager(app)
    login_manager.login_view = 'auth.login'
    login_manager.init_app(app)

    @login_manager.user_loader
    def load_user(user_id):
        query = text(f"SELECT ID_usuario, Email, senha FROM Usuarios WHERE ID_usuario = :user_id;")
        with ENGINE.connect() as conn:
            result = conn.execute(query, {'user_id': user_id}).mappings().fetchone()
            if result:
                return Usuario(
                    id_usuario=result['ID_usuario'],
                    email=result['Email'],
                    senha=result['senha']
                )
            return None

def start_database(app: Flask):
    # Mude a porta caso necessário (normalmente fica 3306 ou 3307)
    with ENGINE.connect() as con:
        with open("database/schema.sql", encoding='utf-8') as file:
            raw = file.read()

        # O arquivo estava tendo problema para ler UTF-8 e símbolos como '--'. Não soube como resolver e pedi ao chat para resolver esse problema.
        processed = re.sub(r'(?mi)^\s*DELIMITER.*$', '', raw)
        processed = re.sub(r'END\s*;?\s*//', 'END;', processed)
        processed = processed.replace('END;//', 'END;')
        processed = re.sub(r'(?m)^\s*//\s*$', '', processed)

        trigger_pattern = re.compile(r'(CREATE\s+TRIGGER[\s\S]*?END;)', re.IGNORECASE)
        triggers = trigger_pattern.findall(processed)
        processed_without_triggers = trigger_pattern.sub('', processed)

        try:
            if processed_without_triggers.strip():
                con.exec_driver_sql(processed_without_triggers)
        except Exception:
            for block in [b.strip() for b in processed_without_triggers.split(';') if b.strip()]:
                try:
                    con.exec_driver_sql(block + ';')
                except Exception:
                    pass

        for trig in triggers:
            try:
                con.exec_driver_sql(trig)
            except Exception:
                pass

        try:
            trigger_info = con.execute(text("""
                SELECT TRIGGER_NAME, EVENT_MANIPULATION, EVENT_OBJECT_TABLE
                FROM information_schema.TRIGGERS
                WHERE TRIGGER_SCHEMA = DATABASE();
            """)).mappings().fetchall()
            print('Triggers aplicados no banco:')
            for t in trigger_info:
                print('-', t['TRIGGER_NAME'], t['EVENT_MANIPULATION'], 'on', t['EVENT_OBJECT_TABLE'])
        except Exception:
            pass

    app.run(debug=True)