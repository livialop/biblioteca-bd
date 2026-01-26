from flask import render_template, redirect, url_for, request, Blueprint, flash
from flask_login import login_required
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError
from config import ENGINE

genero_bp = Blueprint('genero', __name__, static_folder='static', template_folder='templates')

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
                        VALUES (:nome_genero)
                    """
                ), {
                    'nome_genero': nome_genero
                })
            
            flash(f"Gênero '{nome_genero}' adicionado com sucesso.", category='success')
            return redirect(url_for('livros.add_livro'))
        
        except DBAPIError as e:
            # Extrai mensagem enviada pelo SIGNAL no trigger (ex: MySQL via PyMySQL: orig.args == (45000, 'mensagem'))
            # O DPABIError vem do mysqlalchemy e pega a exception quando acontece erro no banco de dados. 'orig' é o erro vindo do mysql. o 'orig.args[1]' é a mensagem do signal.
            erro_mysql = ''
            orig = e.orig
            erro_mysql = orig.args[1]
            flash(erro_mysql, 'danger')
            return redirect(url_for('genero.add_genero'))
        
    return render_template('add_genero.html')


@genero_bp.route('/view_generos')
@login_required
def view_generos():
    with ENGINE.begin() as conn:
        generos = conn.execute(text(
            """SELECT ID_genero, Nome_genero FROM Generos;"""
        )).mappings().fetchall()
    return render_template('view_generos.html', generos=generos)


@genero_bp.route('/delete_genero/<int:genero_id>', methods=['POST'])
@login_required
def delete_genero(genero_id):
    with ENGINE.connect() as conn:
        try:
            conn.execute(text(
                """DELETE FROM Generos WHERE ID_genero = :genero_id;"""
            ), {
                'genero_id': genero_id
            })

        except Exception as e:
            flash('Erro: Não foi possível deletar o gênero. Verifique se há livros associados.', category='error')
            return redirect(url_for('genero.view_generos'))

    flash('Gênero deletado com sucesso!', category='success')
    return redirect(url_for('genero.view_generos'))


@genero_bp.route('/update_genero/<int:genero_id>', methods=['GET', 'POST'])
@login_required
def update_genero(genero_id):
    if request.method == 'POST':
        nome_genero: str = request.form.get('nome_genero')

        with ENGINE.begin() as conn:
            conn.execute(text(
                """UPDATE Generos
                SET Nome_genero = :nome_genero
                WHERE ID_genero = :genero_id"""
            ), {
                'nome_genero': nome_genero,
                'genero_id': genero_id
            })

        flash('Gênero atualizado com sucesso.', category='success')
        return redirect(url_for('genero.view_generos'))

    with ENGINE.begin() as conn:
        genero = conn.execute(text(
            """SELECT * from Generos WHERE ID_genero = :genero_id"""
        ), {
            'genero_id': genero_id
        }).mappings().fetchone()

    return render_template('update_genero.html', genero=genero)

