use db_atividade17;

-- Teste do trigger 'data_nascimento_autor'
insert into Autores (Nome_autor, Nacionalidade, Data_nascimento) values ('livia', 'brasileira', '9007-12-06');

-- Trigger 'editora_repetida'
insert into Editoras (Nome_editora, Endereco_editora) values ('editora o preco bom', 'uma outra rua');

-- Trigger 'genero_repetido'
insert into Generos(Nome_genero) values ('romance');

-- Trigger 'quantidade_livro_invalida'
insert into Livros(Titulo, Autor_id, ISBN, Ano_publicacao, Genero_id, Editora_id, Quantidade_disponivel) values ('a menina', 1, '1312313', 2016, 1, 1, -3);

-- Trigger 'nome_usuario_repetido'
insert into Usuarios(Nome_usuario, Email, Numero_telefone, senha) values ('livialop', 'testii@gmail.com', '5445', '123');

-- Trigger 'auditoria_usuario_insert'
-- A visualização deste trigger está na aba logs, na parte de usuário na aplicação.
select * from Logs_usuarios;	

-- Trigger 'auditoria_livro_delete'
-- A visualização deste trigger está na aba logs, na parte de livro na aplicação.
select * from Logs_livros;

-- Trigger 'auditoria_livro_emprestimo'
-- A visualização deste trigger está na aba logs, na parte de usuário na aplicação.
select * from Logs_emprestimos;

-- Trigger 'auditoria_quantidade_livro_update'
-- A visualização deste trigger está na aba logs, na parte de quantidade de livros na aplicação.
select * from Logs_quantidade_livros;

-- Trigger 'auditoria_autor_update'
-- A visualização deste trigger está na aba logs, na parte de autor na aplicação.
select * from Logs_autor;

-- Trigger 'gerar_data_emprestimo', 'gerar_data_devolucao_prevista' e 'gerar_status_emprestimo'
insert into Emprestimos(Usuario_id, Livro_id) values (3, 2);
select * from Emprestimos;
-- Triggers 'reduzir_quantidade_livro' e 'aumentar_livro_devolucao'
-- Esses triggers podem ser checados na aplicação.

-- Trigger 'marcar_emprestimo_atrasado'
INSERT INTO Emprestimos (Usuario_id, Livro_id, Data_emprestimo, Data_devolucao_prevista, Status_emprestimo)
VALUES (3, 2, CURDATE()-INTERVAL 10 DAY, CURDATE()-INTERVAL 1 DAY, 'pendente');
select * from Emprestimos;

-- Trigger 'bloquear_emprestimo_usuario_inadimplente'
insert into Usuarios(Nome_usuario, Numero_telefone, senha, Data_inscricao, Multa_atual) values ('raissa', '0888219', '123', curdate(), 210);
insert into Emprestimos(Usuario_id, Livro_id) values (4, 2);

-- Trigger 'bloquear_usuario_com_atraso'
insert into Emprestimos(Usuario_id, Livro_id) values (1, 2);