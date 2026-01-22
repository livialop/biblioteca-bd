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
    Status_emprestimo ENUM('pendente', 'devolvido', 'atrasado'),
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



DELIMITER //
CREATE TRIGGER quantidade_livro_invalida BEFORE INSERT 
ON Livros
FOR EACH ROW 
BEGIN 
    IF NEW.Quantidade_disponivel <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Quantidade de livros deve ser maior que zero.';
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER data_nascimento_autor BEFORE INSERT
ON Autores
FOR EACH ROW
BEGIN
    IF NEW.Data_nascimento > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Data de nascimento não pode ser no futuro.';
    END IF;
END;
//
DELIMITER ;

DELIMITER // 
CREATE TRIGGER genero_repetido BEFORE INSERT
ON Generos
FOR EACH ROW
BEGIN 
    IF NEW.Nome_genero IN (
        SELECT Nome_genero FROM Generos
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Gênero repetido.'
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER editora_repetida BEFORE INSERT
ON Editoras
FOR EACH ROW
BEGIN
    IF NEW.Nome_editora IN (
        SELECT Nome_editora FROM Editoras
    ) THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Editora repetida.'
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER nome_usuario_repetido BEFORE INSERT
ON Usuarios
FOR EACH ROW
BEGIN
    IF NEW.Nome_usuario IN (
        SELECT Nome_usuario FROM Usuarios
    ) THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Nome de usuário repetido.'
    END IF;
END;
//
DELIMITER ;

-- TIGGERS AUDITORIA

DELIMITER //
CREATE TRIGGER auditoria_usuario_insert
AFTER INSERT ON Usuarios
FOR EACH ROW
BEGIN
    INSERT INTO Logs_usuarios (ID_usuario, Acao)
    VALUES (NEW.ID_usuario, 'Novo usuário cadastrado');
END;
//
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
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER auditoria_livro_delete
BEFORE DELETE ON Livros
FOR EACH ROW
BEGIN
    INSERT INTO Logs_livros (ID_livro, Titulo, Acao)
    VALUES (OLD.ID_livro, OLD.Titulo, 'Livro removido do acervo');
END;
//
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
END;
//
DELIMITER ;

-- GERAÇÃO DE VALORES

-- Geração automática de valores



DELIMITER //
CREATE TRIGGER gerar_data_emprestimo
BEFORE INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    IF NEW.Data_emprestimo IS NULL THEN
        SET NEW.Data_emprestimo = CURDATE();
    END IF;
END;
//
DELIMITER ;

-- 2. Definir status padrão do empréstimo
DELIMITER //
CREATE TRIGGER status_padrao_emprestimo
BEFORE INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    IF NEW.Status_emprestimo IS NULL THEN
        SET NEW.Status_emprestimo = 'pendente';
    END IF;
END;
//
DELIMITER ;

-- 3. Gerar descrição automática na auditoria ao remover um livro
DELIMITER //
CREATE TRIGGER gerar_log_remocao_livro
BEFORE DELETE ON Livros
FOR EACH ROW
BEGIN
    INSERT INTO Logs_livros (ID_livro, Titulo, Acao)
    VALUES (OLD.ID_livro, OLD.Titulo, 'Livro removido do acervo');
END;
//
DELIMITER ;

-- AUTOMAÇÃO

-- Atualizar quantidade de livros ao registrar um emprestimo
DELIMITER //

CREATE TRIGGER diminuir_livro_emprestimo
AFTER INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    UPDATE Livros
    SET Quantidade_disponivel = Quantidade_disponivel - 1
    WHERE ID_livro = NEW.Livro_id;
END;
//
DELIMITER;

-- Aumentar a quantidade disponível ao devolver um livro
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
END;
//
DELIMITER ;
