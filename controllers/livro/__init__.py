from flask import render_template, redirect, url_for, request, Blueprint, flash
from flask_login import login_required, current_user
from sqlalchemy import text
from config import ENGINE


livros_bp = Blueprint('livros', __name__, static_folder='static', template_folder='templates')


@livros_bp.route('/add_livro', methods=['GET', 'POST'])
@login_required
def add_livro():
    if request.method == 'POST':
        titulo = request.form.get('titulo')
        autor_id = request.form.get('autor')
        isbn = request.form.get('isbn')
        ano = request.form.get('ano_publicacao')
        genero_id = request.form.get('genero')
        editora_id = request.form.get('editora')
        quantidade = request.form.get('quantidade')
        resumo = request.form.get('resumo')

        with ENGINE.begin() as conn:
            conn.execute(text("""
                INSERT INTO Livros 
                (Titulo, Autor_id, ISBN, Ano_publicacao, Genero_id, Editora_id, Quantidade_disponivel, Resumo)
                VALUES (:titulo, :autor_id, :isbn, :ano, :genero_id, :editora_id, :quantidade, :resumo)
            """), {
                "titulo": titulo,
                "autor_id": autor_id,
                "isbn": isbn,
                "ano": ano,
                "genero_id": genero_id,
                "editora_id": editora_id,
                "quantidade": quantidade,
                "resumo": resumo
            })

        flash(f"Livro '{titulo}' adicionado com sucesso.", 'success')
        return redirect(url_for('livros.view_livros'))

    with ENGINE.connect() as conn:
        autores = conn.execute(text("SELECT ID_autor, Nome_autor FROM Autores;")).mappings()
        generos = conn.execute(text("SELECT ID_genero, Nome_genero FROM Generos;")).mappings()
        editoras = conn.execute(text("SELECT ID_editora, Nome_editora FROM Editoras;")).mappings()
    
    return render_template('add_livro.html', autores=autores, generos=generos, editoras=editoras)


@livros_bp.route('/view_livros')
@login_required
def view_livros():
    with ENGINE.begin() as conn:
        livros = conn.execute(text("""
            SELECT l.Titulo, a.Nome_autor, l.ISBN, l.Ano_publicacao, g.Nome_genero, e.Nome_editora, l.Quantidade_disponivel, l.Resumo
            FROM Livros l
            JOIN Autores a ON l.Autor_id = a.ID_autor
            JOIN Generos g ON l.Genero_id = g.ID_genero
            JOIN Editoras e ON l.Editora_id = e.ID_editora;
        """)).mappings().all()
    return render_template('view_livros.html', livros=livros)



@livros_bp.route('/delete_livro/<int:livro_id>', methods=['POST'])
@login_required
def delete_livro(livro_id):
    query_delete = text(f"DELETE FROM Livros WHERE ID_livro = :livro_id;")
    with ENGINE.connect() as conn:
        conn.execute(query_delete, {"livro_id": livro_id})
        conn.commit()
    
    flash('Livro deletado com sucesso!', category='success')
    return redirect(url_for('livros.view_livros'))




@livros_bp.route('/update_livro/<int:livro_id>', methods=['GET', 'POST'])
@login_required
def update_livro(livro_id):
    if request.method == 'POST':
        titulo: str = request.form.get('titulo')
        autor: str = request.form.get('autor')
        isbn: str = request.form.get('isbn')
        ano_publicacao: int = request.form.get('ano_publicacao')
        genero: str = request.form.get('genero')
        editora: str = request.form.get('editora')
        quantidade: int = request.form.get('quantidade')
        resumo: str = request.form.get('resumo')

        query_update = text(f"""
            UPDATE Livros
            SET Titulo = :titulo, Autor_id = (SELECT ID_autor FROM Autores WHERE Nome_autor = :autor), ISBN = :isbn, Ano_publicacao = :ano_publicacao, Genero_id = (SELECT ID_genero FROM Generos WHERE Nome_genero = :genero), Editora_id = (SELECT ID_editora FROM Editoras WHERE Nome_editora = :editora), Quantidade_disponivel = :quantidade, Resumo = :resumo
            WHERE ID_livro = :livro_id;
        """)

        with ENGINE.begin() as conn:
            conn.execute(query_update, {
                "titulo": titulo,
                "autor": autor,
                "isbn": isbn,
                "ano_publicacao": ano_publicacao,
                "genero": genero,
                "editora": editora,
                "quantidade": quantidade,
                "resumo": resumo,
                "livro_id": livro_id
            })

            flash('Livro atualizado com sucesso!', category='success')
            return redirect(url_for('livros.view_livros'))
        
    query_select = text(f"SELECT * FROM Livros WHERE ID_livro = :livro_id;")
    
    with ENGINE.connect() as conn:
        livro = conn.execute(query_select, {"livro_id": livro_id}).mappings().fetchone()
    return render_template('update_livro.html', livro=livro)