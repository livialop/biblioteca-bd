from flask import render_template, redirect, url_for, request, Blueprint, flash
from flask_login import login_required
from sqlalchemy import text
from config import Usuario, ENGINE

autor_bp = Blueprint('autor', __name__, static_folder='static', template_folder='templates')

@autor_bp.route('/add_autor', methods=['GET', 'POST'])
@login_required
def add_autor():
    if request.method == 'POST':
        nome_autor = request.form.get('nome_autor')
        nacionalidade = request.form.get('nacionalidade')
        data_nascimento = request.form.get('data_nascimento')
        biografia = request.form.get('biografia')

        try:
            with ENGINE.begin() as conn:
                conn.execute(text(
                    """INSERT INTO Autores 
                    (Nome_autor, Nacionalidade, Data_nascimento, Biografia)
                    VALUES (:nome_autor, :nacionalidade, :data_nascimento, :biografia);
                """), {
                    'nome_autor': nome_autor,
                    'nacionalidade': nacionalidade,
                    'data_nascimento': data_nascimento,
                    'biografia': biografia
                })

                flash(f"Autor '{nome_autor}' adicionado com sucesso!", 'success')
                return redirect(url_for('livros.add_livro'))
            
        except Exception as e:
            flash(f'Erro ao adicionar autor: {str(e)}', 'danger')
            return redirect(url_for('autor.add_autor'))

    return render_template('add_autor.html')