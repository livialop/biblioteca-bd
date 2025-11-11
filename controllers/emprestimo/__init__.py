from flask import render_template, redirect, url_for, request, Blueprint, flash
from flask_login import login_required, current_user
from sqlalchemy import text
from config import ENGINE

emprestimo_bp = Blueprint('emprestimo', __name__, static_folder='static', template_folder='templates')

@emprestimo_bp.route('/add_emprestimo', methods=['GET', 'POST'])
@login_required
def add_emprestimo():
    if request.method == 'POST':
        # puxar id do usuário por flask_login 
        nome_usuario = request.form.get('nome_usuario')
        # puxar o id do livro pelo nome do livro
        livro_titulo = request.form.get('livro_titulo')
        # default now()
        data_emprestimo = request.form.get('data_emprestimo')
        # data que o usuario quer devolver
        data_devolucao_prevista = request.form.get('data_devolucao_prevista')
        # default 30 dias a partir de now()
        data_devolucao_real = request.form.get('data_devolucao_real')
        # isso tem que ser o select entre os valores do ENUm (pendente, devolvido, etc)
        status_emprestimo = request.form.get('status_emprestimo')

        try:
            with ENGINE.begin() as conn:
                livro_id = conn.execute(text("""
                    SELECT ID_livro from Livros
                    WHERE Titulo = :livro_titulo;
                    """), {
                    'livro_titulo': livro_titulo
                    })
                
                usuario_id = conn.execute(text("""
                    SELECT ID_usuario FROM Usuarios
                    WHERE Nome_usuario = :nome_usuario;
                """), {
                    'nome_usuario': nome_usuario
                })
                
                conn.execute(text("""
                    INSERT INTO Emprestimos
                    (Usuario_id, Livro_id, Data_emprestimo, Data_devolucao_prevista, Data_devolucao_real, Status_emprestimo)
                    VALUES (:usuario_id, :livro_id, :data_emprestimo, :data_devolucao_prevista, :data_devolucao_real, :status_emprestimo)
                """), {
                    'usuario_id': usuario_id,
                    'livro_id': livro_id,
                    'data_emprestimo': data_emprestimo,
                    'data_devolucao_prevista': data_devolucao_prevista,
                    'data_devolucao_real': data_devolucao_real,
                    'status_emprestimo': status_emprestimo
                })

                # FALTA TERMINAR

        except Exception as e:
            flash(f'Erro {e}', category='danger')
            return redirect(url_for('emprestimo.add_emprestimo'))

    return render_template('add_emprestimo.html')

@emprestimo_bp.route('/view_emprestimo')
@login_required
def view_emprestimo():
    pass