from flask import render_template, redirect, url_for, Blueprint, flash, request
from flask_login import login_required
from sqlalchemy import text
from config import ENGINE

editora_bp = Blueprint('editora', __name__, static_folder='static', template_folder='templates')

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


@editora_bp.route('/view_editoras')
@login_required
def view_editoras():
    with ENGINE.begin() as conn:
        editoras = conn.execute(text("""
            SELECT Nome_editora, Endereco_editora FROM Editoras;
        """)).mappings().fetchall()

    return render_template('view_editoras.html', editoras=editoras)


@editora_bp.route('/delete_editora/<int:editora_id>', methods=['POST'])
@login_required
def delete_editora(editora_id):
    with ENGINE.begin() as conn:
        conn.execute(text(
            """DELETE FROM Editoras WHERE ID_editora = :editora_id;"""
        ), {
            'editora_id': editora_id
        })
    
    flash('Editora deletada.', category='success')
    return redirect(url_for('editora.add_editora'))


@editora_bp.route('/update_editora/<int:editora_id>', methods=['GET', 'POST'])
@login_required
def update_editora(editora_id):
    if request.method == 'POST':
        nome_editora: str = request.form.get('nome_editora')
        endereco_editora: str = request.form.get('endereco_editora')

        with ENGINE.begin() as conn:
            conn.execute(text(
                """UPDATE Editoras 
                SET Nome_editora = :nome_editora, Endereco_editora = :endereco_editora
                WHERE ID_editora = :editora_id"""
            ), {
                'nome_editora': nome_editora,
                'endereco_editora': endereco_editora,
                'editora_id': editora_id
            })

        flash('Informações da editora atualizadas!', category='success')
        return redirect(url_for('editora.view_editoras'))
    
    with ENGINE.begin() as conn:
        editora = conn.execute(text(
            """SELECT * FROM Editoras WHERE ID_editora = :editora_id;"""
        ), {
            'editora_id': editora_id
        }).mappings().fetchone()
        return render_template('update_editora.html', editora=editora)