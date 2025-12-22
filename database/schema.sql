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

-- TRIGGERS
    -- Exemplos 1 (VALIDAÇÃO):
    --Bloquear valores inválidos.
    --Garantir regras de negócio obrigatórias.
    --Impedir registros duplicados.
    --Verificar dependências antes de permitir alterações.
    --Impedir matrícula duplicada na mesma disciplina.
    --Bloquear nota fora do intervalo 0 a 10.
    --Impedir matrícula quando o aluno estiver inativo.


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