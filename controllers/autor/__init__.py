from flask import render_template, redirect, url_for, request, Blueprint, flash
from datetime import date, datetime
from flask_login import login_required
from sqlalchemy import text
from config import ENGINE

autor_bp = Blueprint('autor', __name__, static_folder='static', template_folder='templates')

@autor_bp.route('/add_autor', methods=['GET', 'POST'])
@login_required
def add_autor():
    if request.method == 'POST':
        nome_autor = request.form.get('nome_autor')
        nacionalidade = request.form.get('nacionalidade')
        data_nascimento = request.form.get('data_nascimento')
        biografia = request.form.get('biografia')

        if data_nascimento:
            try:
                data_nascimento_date = datetime.strptime(data_nascimento, "%Y-%m-%d").date()
                if data_nascimento_date > date.today():
                    flash('Data de nascimento não pode ser no futuro.', 'danger')
                    return redirect(url_for('autor.add_autor'))
            except ValueError:
                flash('Data de nascimento inválida.', 'danger')
                return redirect(url_for('autor.add_autor'))

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



@autor_bp.route('/view_autores')
@login_required
def view_autores():
    with ENGINE.connect() as conn:
        autores = conn.execute(text("""
            SELECT ID_autor, Nome_autor, Nacionalidade, Data_nascimento, Biografia
            FROM Autores;
    """)).mappings().all()
    return render_template('view_autores.html', autores=autores)    



@autor_bp.route('/delete_autor/<int:autor_id>', methods=['POST'])
@login_required
def delete_autor(autor_id):
    with ENGINE.begin() as conn:
        try: 
            conn.execute(text(
                """DELETE FROM Autores WHERE ID_autor = :autor_id;"""
            ), {
                'autor_id': autor_id
            })
        except Exception as e:
            flash('Erro: Não foi possível deletar o autor. Verifique se há livros associados.', category='error')
            return redirect(url_for('autor.view_autores'))

    flash('Autor deletado.', category='success')
    return redirect(url_for('autor.add_autor'))



@autor_bp.route('/update_autor/<int:autor_id>', methods=['GET', 'POST'])
@login_required
def update_autor(autor_id):
    if request.method == 'POST':
        nome_autor: str = request.form.get('nome_autor')
        nacionalidade: str = request.form.get('nacionalidade')
        data_nascimento: str = request.form.get('data_nascimento')
        biografia: str = request.form.get('biografia')

        with ENGINE.begin() as conn:
            conn.execute(text(
                """UPDATE Autores  
                    SET Nome_autor = :nome_autor, Nacionalidade = :nacionalidade, Data_nascimento = :data_nascimento, Biografia = :biografia
                    WHERE ID_autor = :autor_id;
                """
            ), {
                'nome_autor': nome_autor,
                'nacionalidade': nacionalidade,
                'data_nascimento': data_nascimento,
                'biografia': biografia
            })

            flash('Livro atualizado com sucesso.', category='success')
            return redirect(url_for('autor.view_autores'))
        
    with ENGINE.connect() as conn:
        autor = conn.execute(text(
            """SELECT * FROM Autores WHERE ID_autor = :autor_id;"""
        ), {
            'autor_id': autor_id
        }).mappings().fetchone()
    
    return render_template('update_autor.html', autor=autor)