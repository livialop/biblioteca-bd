from flask import render_template, redirect, url_for, request, Blueprint, flash
from flask_login import login_required
from sqlalchemy import text
from config import ENGINE

emprestimo_bp = Blueprint('emprestimo', __name__, static_folder='../../static/style/', template_folder='../../templates/')

@emprestimo_bp.route('/add_emprestimo', methods=['GET', 'POST'])
@login_required
def add_emprestimo():
    if request.method == 'POST':
        nome_usuario = request.form.get('nome_usuario')
        livro_titulo = request.form.get('livro_titulo')
        data_emprestimo = request.form.get('data_emprestimo')
        data_devolucao_prevista = request.form.get('data_devolucao_prevista')
        data_devolucao_real = request.form.get('data_devolucao_real')
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
                
                if data_emprestimo is None or data_emprestimo == '':
                    data_emprestimo = text('CURRENT_DATE();')
                if data_devolucao_real is None or data_devolucao_real == '':
                    data_devolucao_real = text('CURRENT_DATE() + INTERVAL \'30 days\'')
                
                disponibilidade = conn.execute(text("""
                    SELECT Quantidade_disponivel FROM Livros
                    WHERE ID_livro = :livro_id;
                """), {
                    'livro_id': livro_id
                })

                if disponibilidade.first()[0] <= 0:
                    flash('Livro indisponível para empréstimo.', category='danger')
                    return redirect(url_for('emprestimo.add_emprestimo'))
                
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

            flash('Empréstimo adicionado com sucesso!', category='success')

            conn.exec_driver_sql(text("UPDATE Livros SET Quantidade_disponivel = Quantidade_disponivel - 1 WHERE ID_livro = :livro_id;"),
                                 {'livro_id': livro_id})
            
            return redirect(url_for('emprestimo.view_emprestimo'))
        
        except Exception as e:
            flash(f'Erro {e}', category='danger')
            return redirect(url_for('emprestimo.add_emprestimo'))
    

    with ENGINE.begin() as conn:
        valores_status_emprestimo = conn.execute(text("""
            SELECT DISTINCT Status_emprestimo FROM Emprestimos;    
        """)).mappings().fetchall()

    return render_template('add_emprestimo.html', valores_status_emprestimo=valores_status_emprestimo)



@emprestimo_bp.route('/view_emprestimos')
@login_required
def view_emprestimos():
    with ENGINE.begin() as conn:
        emprestimos = conn.execute(text("""
            SELECT e.ID_emprestimo, u.Nome_usuario, l.Titulo, e.Data_emprestimo, e.Data_devolucao_prevista,
                   e.Data_devolucao_real, e.Status_emprestimo
            FROM Emprestimos e
            JOIN Usuarios u ON e.Usuario_id = u.ID_usuario
            JOIN Livros l ON e.Livro_id = l.ID_livro;
        """)).mappings().fetchall()

    return render_template('view_emprestimos.html', emprestimos=emprestimos)



@emprestimo_bp.route('/delete_emprestimo/<int:emprestimo_id>', methods=['POST'])
@login_required
def delete_emprestimo(emprestimo_id):
    with ENGINE.begin() as conn:
        conn.execute(text(
            """DELETE FROM Emprestimos WHERE ID_emprestimo = :emprestimo_id"""
        ), {
            'emprestimo_id': emprestimo_id
        })

    flash('Empréstimo deletado com sucesso.', category='success')
    return redirect(url_for('emprestimo.view_emprestimos'))


@emprestimo_bp.route('/update_emprestimo/<int:emprestimo_id>', methods=['GET', 'POST'])
@login_required
def update_emprestimo(emprestimo_id):
    if request.method == 'POST':
        # Não pode mudar o usuário do empréstimo e nem pode mudar o livro emprestado
        # O que muda mudar: Status do empréstimo, data de devolução real

        status_emprestimo = request.form.get('status_emprestimo')
        data_devolucao_real = request.form.get('data_devolucao_real')

        with ENGINE.begin() as conn:
            conn.execute(text(
                """UPDATE Emprestimos
                SET Status_emprestimo = :status_emprestimo, Data_devolucao_real = :data_devolucao_real
                WHERE ID_emprestimo = :emprestimo_id"""
            ), {
                'status_emprestimo': status_emprestimo,
                'data_devolucao_real': data_devolucao_real,
                'emprestimo_id': emprestimo_id
            })

            flash('Empréstimo atualizado com sucesso!', category='success')
            return redirect(url_for('emprestimo.view_emprestimos'))
        
    with ENGINE.begin() as conn:
        emprestimo = conn.execute(text(
            """SELECT * FROM Emprestimos WHERE ID_emprestimo = :emprestimo_id;"""
        ), {
            'emprestimo_id': emprestimo_id
        }).mappings().fetchone()

    return render_template('update_emprestimo.html', emprestimo=emprestimo)
