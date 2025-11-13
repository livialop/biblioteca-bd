from flask import render_template, redirect, url_for, Blueprint, flash, request
from flask_login import login_required
from sqlalchemy import text
from config import ENGINE

editora_bp = Blueprint('editora', __name__, static_folder='../../static/style/', template_folder='../../templates/')

@editora_bp.route('/add_editora', methods=['GET', 'POST'])
@login_required
def add_editora():
    if request.method == 'POST':
        nome_editora = request.form.get('nome_editora')
        endereco_editora = request.form.get('endereco_editora')

        try:
            with ENGINE.begin() as conn:
                conn.execute(text("""
                    INSERT INTO Editoras 
                    (Nome_editora, Endereco_editora)
                    VALUES (:nome_editora, :endereco_editora)
                """), {
                    'nome_editora': nome_editora,
                    'endereco_editora': endereco_editora 
                })

            flash(f"Editora '{nome_editora}' adicionada.", category='success')
            return redirect(url_for('livros.add_livro'))

        except Exception as e:
            flash(f'Erro {str(e)}', category='danger')
            return redirect(url_for('editora.add_editora'))

    return render_template('add_editora.html')