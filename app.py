from flask import Flask
import controllers.auth
import controllers.main
import controllers.livro
import controllers.autor
import controllers.editora
import controllers.genero
import controllers.emprestimo
import config

app: Flask = Flask(__name__)
app.register_blueprint(controllers.auth.auth_bp)
app.register_blueprint(controllers.main.main_bp)
app.register_blueprint(controllers.livro.livros_bp)
app.register_blueprint(controllers.autor.autor_bp)
app.register_blueprint(controllers.editora.editora_bp)
app.register_blueprint(controllers.genero.genero_bp)
app.register_blueprint(controllers.emprestimo.emprestimo_bp)

config.config(app)

if __name__ == '__main__':
    config.start_database(app)