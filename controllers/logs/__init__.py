from flask import render_template, Blueprint
from flask_login import login_required
from sqlalchemy import text
from config import ENGINE

logs_bp = Blueprint('logs', __name__, static_folder='static', template_folder='templates')

@logs_bp.route('/logs')
@login_required
def view_logs():
    with ENGINE.begin() as conn:
        logs_usuarios = conn.execute(text("""
            SELECT ID_log, ID_usuario, Acao, Data_hora
            FROM Logs_usuarios
            ORDER BY Data_hora DESC
            LIMIT 200;
        """)).mappings().fetchall()

        logs_emprestimos = conn.execute(text("""
            SELECT ID_log, ID_emprestimo, Status_antigo, Status_novo, Data_hora
            FROM Logs_emprestimos
            ORDER BY Data_hora DESC
            LIMIT 200;
        """)).mappings().fetchall()

        logs_livros = conn.execute(text("""
            SELECT ID_log, ID_livro, Titulo, Acao, Data_hora
            FROM Logs_livros
            ORDER BY Data_hora DESC
            LIMIT 200;
        """)).mappings().fetchall()

    return render_template(
        'view_logs.html',
        logs_usuarios=logs_usuarios,
        logs_emprestimos=logs_emprestimos,
        logs_livros=logs_livros
    )
