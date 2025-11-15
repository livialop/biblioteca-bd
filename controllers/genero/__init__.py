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
                        VALUES (:nome_genero)
                    """
                ), {
                'nome_genero': nome_genero
            })
            
            flash(f"Gênero '{nome_genero}' adicionado com sucesso.", category='success')
            return redirect(url_for('livros.add_livro'))
        
        except Exception as e:
            flash(f'Erro: {str(e)}', category='danger')
            print(e)
            return redirect(url_for('genero.add_genero'))
        
    return render_template('add_genero.html')


@genero_bp.route('/view_generos')
@login_required
def view_generos():
    with ENGINE.begin() as conn:
        generos = conn.execute(text(
            """SELECT Nome_genero FROM Generos;"""
        )).mappings().fetchall()
    return render_template('view_generos.html', generos=generos)


@genero_bp.route('/delete_genero/<int:genero_id>', methods=['POST'])
@login_required
def delete_genero(genero_id):
    with ENGINE.connect() as conn:
        conn.execute(text(
            """DELETE FROM Generos WHERE ID_genero = :genero_id;"""
        ), {
            'genero_id': genero_id
        })

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
        })

    return render_template('update_genero.html', genero=genero)

