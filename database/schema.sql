CREATE SCHEMA IF NOT EXISTS db_atividade17;
USE db_atividade17;

CREATE TABLE IF NOT EXISTS Autores (
    ID_autor INT AUTO_INCREMENT PRIMARY KEY,
    Nome_autor VARCHAR(255) NOT NULL,
    Nacionalidade VARCHAR(255),
    Data_nascimento DATE,
    
    Biografia TEXT
);

CREATE TABLE IF NOT EXISTS Generos (
    ID_genero INT AUTO_INCREMENT PRIMARY KEY,
    Nome_genero VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS Editoras (
    ID_editora INT AUTO_INCREMENT PRIMARY KEY,
    Nome_editora VARCHAR(255) NOT NULL,
    Endereco_editora TEXT
);

CREATE TABLE IF NOT EXISTS Livros (
    ID_livro INT AUTO_INCREMENT PRIMARY KEY,
    Titulo VARCHAR(255) NOT NULL,
    Autor_id INT,
    ISBN VARCHAR(13) NOT NULL,
    Ano_publicacao INT,
    Genero_id INT,
    Editora_id INT,
    Quantidade_disponivel INT,
    Resumo TEXT,
    FOREIGN KEY (Autor_id) REFERENCES Autores(ID_autor),
    FOREIGN KEY (Genero_id) REFERENCES Generos(ID_genero),
    FOREIGN KEY (Editora_id) REFERENCES Editoras(ID_editora)
);

CREATE TABLE IF NOT EXISTS Usuarios (
    ID_usuario INT AUTO_INCREMENT PRIMARY KEY,
    Nome_usuario VARCHAR(255) NOT NULL,
    Email VARCHAR(255),
    Numero_telefone VARCHAR(15),
    senha VARCHAR(255) NOT NULL,
    Data_inscricao DATE DEFAULT (CURRENT_DATE()),
    Multa_atual DECIMAL(10, 2)
);

CREATE TABLE IF NOT EXISTS Emprestimos (
    ID_emprestimo INT AUTO_INCREMENT PRIMARY KEY,
    Usuario_id INT,
    Livro_id INT,
    Data_emprestimo DATE,
    Data_devolucao_prevista DATE,
    Data_devolucao_real DATE,
    Status_emprestimo ENUM('pendente', 'devolvido', 'atrasado', 'Em andamento'),
    FOREIGN KEY (Usuario_id) REFERENCES Usuarios(ID_usuario),
    FOREIGN KEY (Livro_id) REFERENCES Livros(ID_livro)
);

-- CREATE AUDITORIA

CREATE TABLE IF NOT EXISTS Logs_usuarios (
    ID_log INT AUTO_INCREMENT PRIMARY KEY,
    ID_usuario INT,
    Acao VARCHAR(100),
    Data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Logs_emprestimos (
    ID_log INT AUTO_INCREMENT PRIMARY KEY,
    ID_emprestimo INT,
    Status_antigo ENUM('pendente', 'devolvido', 'atrasado'),
    Status_novo ENUM('pendente', 'devolvido', 'atrasado'),
    Data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Logs_livros (
    ID_log INT AUTO_INCREMENT PRIMARY KEY,
    ID_livro INT,
    Titulo VARCHAR(255),
    Acao VARCHAR(100),
    Data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS Logs_quantidade_livros (
    ID_log INT AUTO_INCREMENT PRIMARY KEY,
    ID_livro INT,
    Quantidade_antiga INT,
    Quantidade_nova INT,
    Acao VARCHAR(100),
    Data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS Logs_autor (
    ID_log INT AUTO_INCREMENT PRIMARY KEY,
    ID_autor INT NOT NULL,
    Campo_alterado VARCHAR(50),
    Valor_antigo TEXT,
    Valor_novo TEXT,
    Data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);




-- TRIGGERS


DELIMITER //
CREATE TRIGGER data_nascimento_autor BEFORE INSERT
ON Autores
FOR EACH ROW
BEGIN
    IF NEW.Data_nascimento > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Data de nascimento não pode ser no futuro.';
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER editora_repetida BEFORE INSERT
ON Editoras
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Editoras WHERE Nome_editora = NEW.Nome_editora) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Editora repetida.';
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER genero_repetido BEFORE INSERT
ON Generos
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Generos WHERE Nome_genero = NEW.Nome_genero) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Gênero repetido.';
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER quantidade_livro_invalida BEFORE INSERT 
ON Livros
FOR EACH ROW 
BEGIN 
    IF NEW.Quantidade_disponivel <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Quantidade de livros deve ser maior que zero.';
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER nome_usuario_repetido BEFORE INSERT
ON Usuarios
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Usuarios WHERE Nome_usuario = NEW.Nome_usuario) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nome de usuário repetido.';
    END IF;
END;//
DELIMITER ;

-- TIGGERS AUDITORIA

DELIMITER //
CREATE TRIGGER auditoria_usuario_insert
AFTER INSERT ON Usuarios
FOR EACH ROW
BEGIN
    INSERT INTO Logs_usuarios (ID_usuario, Acao)
    VALUES (NEW.ID_usuario, 'Novo usuário cadastrado');
END;//
DELIMITER ;

SELECT * FROM Logs_usuarios ORDER BY ID_log DESC;


DELIMITER //
CREATE TRIGGER auditoria_livro_delete
BEFORE DELETE ON Livros
FOR EACH ROW
BEGIN
    INSERT INTO Logs_livros (ID_livro, Titulo, Acao)
    VALUES (OLD.ID_livro, OLD.Titulo, 'Livro removido do acervo');
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER auditoria_status_emprestimo
AFTER UPDATE ON Emprestimos
FOR EACH ROW
BEGIN
    IF OLD.Status_emprestimo <> NEW.Status_emprestimo THEN
        INSERT INTO Logs_emprestimos (ID_emprestimo, Status_antigo, Status_novo)
        VALUES (OLD.ID_emprestimo, OLD.Status_emprestimo, NEW.Status_emprestimo);
    END IF;
END;//
DELIMITER ;

DELIMITER //
CREATE TRIGGER auditoria_quantidade_livro_update
AFTER UPDATE ON Livros
FOR EACH ROW
BEGIN
    IF OLD.Quantidade_disponivel <> NEW.Quantidade_disponivel THEN
        INSERT INTO Logs_quantidade_livros (ID_livro, Quantidade_antiga, Quantidade_nova, Acao)
        VALUES (OLD.ID_livro, OLD.Quantidade_disponivel, NEW.Quantidade_disponivel, 'Quantidade de livros atualizada');
    END IF;
END;//
DELIMITER ;

SELECT * FROM Logs_quantidade_livros ORDER BY ID_log DESC;

DELIMITER //

CREATE TRIGGER auditoria_autor_update
AFTER UPDATE ON Autores
FOR EACH ROW
BEGIN
    -- Nome
    IF NOT (OLD.Nome_autor <=> NEW.Nome_autor) THEN
        INSERT INTO Logs_autor (ID_autor, Campo_alterado, Valor_antigo, Valor_novo)
        VALUES (OLD.ID_autor, 'Nome_autor', OLD.Nome_autor, NEW.Nome_autor);
    END IF;

    -- Nacionalidade
    IF NOT (OLD.Nacionalidade <=> NEW.Nacionalidade) THEN
        INSERT INTO Logs_autor (ID_autor, Campo_alterado, Valor_antigo, Valor_novo)
        VALUES (OLD.ID_autor, 'Nacionalidade', OLD.Nacionalidade, NEW.Nacionalidade);
    END IF;

    -- Data Nascimento
    IF NOT (OLD.Data_nascimento <=> NEW.Data_nascimento) THEN
        INSERT INTO Logs_autor (ID_autor, Campo_alterado, Valor_antigo, Valor_novo)
        VALUES (OLD.ID_autor, 'Data_nascimento', OLD.Data_nascimento, NEW.Data_nascimento);
    END IF;

    -- Biografia
    IF NOT (OLD.Biografia <=> NEW.Biografia) THEN
        INSERT INTO Logs_autor (ID_autor, Campo_alterado, Valor_antigo, Valor_novo)
        VALUES (OLD.ID_autor, 'Biografia', OLD.Biografia, NEW.Biografia);
    END IF;
END;//

DELIMITER ;


-- GERAÇÃO DE VALORES

-- Gerar automaticamente a data do empréstimo
DELIMITER //
CREATE TRIGGER gerar_data_emprestimo
BEFORE INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    SET NEW.Data_emprestimo = CURDATE();
END;
//
DELIMITER ;

-- Gerar automaticamente a data prevista de devolução (7 dias)
DELIMITER //
CREATE TRIGGER gerar_data_devolucao_prevista
BEFORE INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    SET NEW.Data_devolucao_prevista = DATE_ADD(CURDATE(), INTERVAL 7 DAY);
END;
//
DELIMITER ;

-- Gerar automaticamente o status inicial do empréstimo
DELIMITER //
CREATE TRIGGER gerar_status_emprestimo
BEFORE INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    SET NEW.Status_emprestimo = 'pendente';
END;
//
DELIMITER ;

DELIMITER //

CREATE TRIGGER aumentar_livro_devolucao
AFTER UPDATE ON Emprestimos
FOR EACH ROW
BEGIN
    IF OLD.Status_emprestimo <> 'devolvido'
       AND NEW.Status_emprestimo = 'devolvido' THEN

        UPDATE Livros
        SET Quantidade_disponivel = Quantidade_disponivel + 1
        WHERE ID_livro = NEW.Livro_id;

    END IF;
END;//
DELIMITER ;

-- Reduzir automaticamente a quantidade de livros ao registrar empréstimo
DELIMITER //
CREATE TRIGGER reduzir_quantidade_livro
AFTER INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    UPDATE Livros
    SET Quantidade_disponivel = Quantidade_disponivel - 1
    WHERE ID_livro = NEW.Livro_id;
END;
//
DELIMITER ;

-- Atualizar automaticamente o status para 'atrasado'
DELIMITER //
CREATE TRIGGER atualizar_status_atrasado
BEFORE UPDATE ON Emprestimos
FOR EACH ROW
BEGIN
    IF NEW.Data_devolucao_real IS NULL
       AND CURDATE() > NEW.Data_devolucao_prevista THEN
        SET NEW.Status_emprestimo = 'atrasado';
    END IF;
END;
//
DELIMITER ;

-- Aumentar a quantidade disponível ao devolver um livro

-- Bloquear usuário com empréstimo em atraso

DELIMITER //

CREATE TRIGGER bloquear_usuario_com_atraso
BEFORE INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    DECLARE atrasos INT;

    SELECT COUNT(*)
    INTO atrasos
    FROM Emprestimos
    WHERE Usuario_id = NEW.Usuario_id
      AND Status_emprestimo = 'atrasado';

    IF atrasos > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário possui empréstimo em atraso';
    END IF;
END;//
DELIMITER ;

DELIMITER //

CREATE TRIGGER bloquear_emprestimo_usuario_inadimplente
BEFORE INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    DECLARE total_multas DECIMAL(10,2);

    SELECT IFNULL(Multa_atual, 0)
    INTO total_multas
    FROM Usuarios
    WHERE ID_usuario = NEW.Usuario_id;

    IF total_multas > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Usuário possui multa pendente e não pode realizar novo empréstimo';
    END IF;
END;//

DELIMITER ;
