from flask import render_template, redirect, url_for, request, Blueprint, flash
from flask_login import login_required
from sqlalchemy import text
from config import ENGINE

genero_bp = Blueprint('genero', __name__, static_folder='../../static/style/', template_folder='../../templates/')

@genero_bp.route('/add_genero', methods=['GET', 'POST'])
@login_required
def add_genero():
    if request.method == 'POST':
        nome_genero = request.form.get('nome_genero')

        try:
            with ENGINE.begin() as conn:
                conn.execute(text(
                    """INSERT INTO Generos
                        (Nome_genero)
                        VALUE (:nome_genero)
                    """
                ), {
                'nome_genero': nome_genero
            })
            
            flash(f"Gênero '{nome_genero}' adicionado com sucesso.", category='success')
            return redirect(url_for('livros.add_livro'))
        
        except Exception as e:
            flash(f'Erro: {str(e)}', category='danger')
            return redirect(url_for('genero.add_genero'))
        
    return render_template('add_genero.html')