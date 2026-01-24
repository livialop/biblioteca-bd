drop database db_atividade17;
create database db_atividade17;
use db_atividade17;

-- 1 - Cria o usuário na aplicação

-- 2 - Teste do trigger 'data_nascimento_autor'
insert into Autores (Nome_autor, Nacionalidade, Data_nascimento) values ('livia', 'brasileira', '9007-12-06');

-- 3 - Trigger 'editora_repetida'
insert into Editoras (Nome_editora, Endereco_editora) values ('editora o preco bom', 'uma outra rua');

-- 4 - Trigger 'genero_repetido'
insert into Generos(Nome_genero) values ('romance');

-- 5 - Trigger 'quantidade_livro_invalida'
insert into Livros(Titulo, Autor_id, ISBN, Ano_publicacao, Genero_id, Editora_id, Quantidade_disponivel) values ('a menina', 1, '1312313', 2016, 1, 1, -3);

-- 6 - Trigger 'nome_usuario_repetido'
insert into Usuarios(Nome_usuario, Email, Numero_telefone, senha) values ('livialop', 'testii@gmail.com', '5445', '123');

-- 7 - Trigger 'auditoria_usuario_insert'
-- A visualização deste trigger está na aba logs, na parte de usuário na aplicação.
select * from Logs_usuarios;	

-- 8 - Criar livro e autor
-- 9 - Trigger 'auditoria_livro_delete'
-- A visualização deste trigger está na aba logs, na parte de livro na aplicação.
select * from Logs_livros;

-- 10 - Criar livro e autor, refazer emprestimo
-- 11 - Trigger 'auditoria_livro_emprestimo'
-- A visualização deste trigger está na aba logs, na parte de usuário na aplicação.
select * from Logs_emprestimos;

-- 12 - Trigger 'auditoria_quantidade_livro_update'
-- A visualização deste trigger está na aba logs, na parte de quantidade de livros na aplicação.
select * from Logs_quantidade_livros;

-- 14 - Mudar nacionalidade do autor
-- 13 - Trigger 'auditoria_autor_update'
-- A visualização deste trigger está na aba logs, na parte de autor na aplicação.
select * from Logs_autor;

-- Trigger 'gerar_data_emprestimo', 'gerar_data_devolucao_prevista' e 'gerar_status_emprestimo'
insert into Emprestimos(Usuario_id, Livro_id) values (1, 2);
select * from Emprestimos;
-- Triggers 'reduzir_quantidade_livro' e 'aumentar_livro_devolucao'
-- Esses triggers podem ser checados na aplicação.

-- Trigger 'marcar_emprestimo_atrasado'
insert into Emprestimos (Usuario_id, Livro_id, Data_emprestimo, Data_devolucao_prevista, Status_emprestimo)
values (2, 2, CURDATE()-interval 10 day, CURDATE()-interval 1 day, 'pendente');
select * from Emprestimos;

-- Trigger 'bloquear_emprestimo_usuario_inadimplente'
insert into Usuarios(Nome_usuario, Numero_telefone, senha, Data_inscricao, Multa_atual) values ('raissa', '0888219', '123', curdate(), 210);
insert into Emprestimos(Usuario_id, Livro_id) values (3, 2);

-- Trigger 'bloquear_usuario_com_atraso'
insert into Emprestimos(Usuario_id, Livro_id) values (1, 2);