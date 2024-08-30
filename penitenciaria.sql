DROP DATABASE IF EXISTS penitenciaria;
CREATE DATABASE penitenciaria;
USE penitenciaria;

CREATE TABLE pavilhao (
id INT PRIMARY KEY AUTO_INCREMENT,
nome VARCHAR(100) NOT NULL
);

CREATE TABLE cela (
id INT PRIMARY KEY AUTO_INCREMENT,
numero VARCHAR(10) NOT NULL,
capacidade INT NOT NULL,
tipo VARCHAR(50) NOT NULL,
bloco VARCHAR(50) NOT null,
id_pavilhao int,
FOREIGN KEY (id_pavilhao) REFERENCES pavilhao(id)
);

CREATE TABLE detento (
id INT PRIMARY KEY AUTO_INCREMENT,
nome VARCHAR(100) NOT NULL,
data_nascimento DATE NOT NULL,
altura INT,
peso FLOAT,
sexo ENUM('M', 'F') NOT NULL,
historico_delitos VARCHAR(1027) NOT NULL,
data_ingresso DATE NOT NULL,
data_saida DATE,
motivo_saida VARCHAR(255),
id_cela INT,
FOREIGN KEY (id_cela) REFERENCES cela(id)
);

CREATE TABLE funcionario (
id INT PRIMARY KEY AUTO_INCREMENT,
nome VARCHAR(100) NOT NULL,
sexo ENUM('M', 'F') NOT NULL,
cargo VARCHAR(50) NOT NULL,
salario DECIMAL(10, 2) NOT NULL,
data_adm DATE NOT null,
id_pavilhao int,
FOREIGN KEY (id_pavilhao) REFERENCES pavilhao(id));
CREATE TABLE visitante (
id INT PRIMARY KEY AUTO_INCREMENT,
nome VARCHAR(100) NOT NULL,
genero ENUM('M', 'F') NOT NULL,
parentesco VARCHAR(50),
telefone VARCHAR(15),
endereco VARCHAR(255),
data_nasc DATE NOT NULL
);

CREATE TABLE visita (
id INT PRIMARY KEY AUTO_INCREMENT,
id_detento INT NOT NULL,
id_visitante INT NOT NULL,
data_visita DATE NOT NULL,
hora_entrada TIME NOT NULL,
hora_saida TIME,
FOREIGN KEY (id_detento) REFERENCES detento(id),
FOREIGN KEY (id_visitante) REFERENCES visitante(id)
);

CREATE TABLE relatorio (
id INT PRIMARY KEY AUTO_INCREMENT,
id_detento INT NOT NULL,
data_relatorio DATE NOT NULL,
descricao TEXT NOT NULL,
FOREIGN KEY (id_detento) REFERENCES detento(id)
);

-- ============================== ex 01 - Procedures ==============================

-- Procedimento para Inserir ou Atualizar informações de detentos (Lucas)
DELIMITER //

CREATE PROCEDURE inserir_ou_atualizar_detento(
    IN p_nome VARCHAR(100),
    IN p_data_nascimento DATE,
    IN p_altura INT,
    IN p_peso FLOAT,
    IN p_sexo ENUM('M', 'F'),
    IN p_historico_delitos VARCHAR(1027),
    IN p_data_ingresso DATE,
    IN p_data_saida DATE,
    IN p_motivo_saida VARCHAR(255),
    IN p_id_cela INT,
    IN p_id INT
)
BEGIN
    IF p_nome IS NULL OR p_nome = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nome do detento é obrigatório.';
    END IF;

    IF p_data_nascimento IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data de nascimento do detento é obrigatória.';
    END IF;

    IF p_data_ingresso IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data de ingresso do detento é obrigatória.';
    END IF;

    IF p_id_cela IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ID da cela é obrigatório.';
    END IF;

    IF p_id IS NULL THEN
        INSERT INTO detento (nome, data_nascimento, altura, peso, sexo, historico_delitos, data_ingresso, data_saida, motivo_saida, id_cela)
        VALUES (p_nome, p_data_nascimento, p_altura, p_peso, p_sexo, p_historico_delitos, p_data_ingresso, p_data_saida, p_motivo_saida, p_id_cela);
    ELSE
        UPDATE detento 
        SET nome = p_nome, data_nascimento = p_data_nascimento, altura = p_altura, peso = p_peso, sexo = p_sexo, historico_delitos = p_historico_delitos, 
            data_ingresso = p_data_ingresso, data_saida = p_data_saida, motivo_saida = p_motivo_saida, id_cela = p_id_cela
        WHERE id = p_id;
    END IF;
END //

DELIMITER ;

-- procedimento para gerar relatório com informações sobre celas por pavilhão (Lucas)
DELIMITER //

CREATE PROCEDURE relatorio_celas_por_pavilhao(
    IN p_id_pavilhao INT
)
BEGIN
    SELECT 
        p.nome AS nome_pavilhao,
        c.tipo AS tipo_cela,
        COUNT(c.id) AS total_celas,
        SUM(c.capacidade) AS capacidade_total
    FROM 
        pavilhao p
    INNER JOIN 
        cela c ON p.id = c.id_pavilhao
    WHERE 
        p.id = p_id_pavilhao
    GROUP BY 
        p.nome, c.tipo;
END //

DELIMITER ;

-- procedimento para gerar relatório com informações de visitas por cada detento (Lucas)
DELIMITER //

CREATE PROCEDURE relatorio_visitas_por_detento(
    IN p_id_detento INT
)
BEGIN
    SELECT 
        d.nome AS nome_detento,
        v.data_visita AS data_visita,
        v.hora_entrada AS hora_entrada,
        v.hora_saida AS hora_saida,
        vi.nome AS nome_visitante,
        vi.parentesco AS parentesco
    FROM 
        visita v
    INNER JOIN 
        detento d ON v.id_detento = d.id
    INNER JOIN 
        visitante vi ON v.id_visitante = vi.id
    WHERE 
        d.id = p_id_detento
    ORDER BY 
        v.data_visita DESC;
END //

DELIMITER ;

-- Procedimento para Inserir ou Atualizar Pavilhão (Vinicius)
DELIMITER //

CREATE PROCEDURE inserir_ou_atualizar_pavilhao(
    IN p_nome VARCHAR(100),
    IN p_id INT
)
BEGIN
    IF p_nome IS NULL OR p_nome = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Nome do pavilhão é obrigatório.';
    END IF;

    IF p_id IS NULL THEN
        INSERT INTO pavilhao (nome) VALUES (p_nome);
    ELSE
        UPDATE pavilhao SET nome = p_nome WHERE id = p_id;
    END IF;
END //

DELIMITER ;

-- Procedimento para Inserir ou Atualizar Cela (Vinicius)
DELIMITER //

CREATE PROCEDURE inserir_ou_atualizar_cela(
    IN p_numero VARCHAR(10),
    IN p_capacidade INT,
    IN p_tipo VARCHAR(50),
    IN p_bloco VARCHAR(50),
    IN p_id_pavilhao INT,
    IN p_id INT
)
BEGIN
    IF p_numero IS NULL OR p_numero = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Número da cela é obrigatório.';
    END IF;
    IF p_capacidade IS NULL OR p_capacidade <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Capacidade da cela deve ser maior que zero.';
    END IF;
    IF p_tipo IS NULL OR p_tipo = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo da cela é obrigatório.';
    END IF;
    IF p_bloco IS NULL OR p_bloco = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bloco da cela é obrigatório.';
    END IF;

    IF p_id IS NULL THEN
        INSERT INTO cela (numero, capacidade, tipo, bloco, id_pavilhao) 
        VALUES (p_numero, p_capacidade, p_tipo, p_bloco, p_id_pavilhao);
    ELSE
        UPDATE cela 
        SET numero = p_numero, capacidade = p_capacidade, tipo = p_tipo, bloco = p_bloco, id_pavilhao = p_id_pavilhao
        WHERE id = p_id;
    END IF;
END //

DELIMITER ;

-- Procedimentos para Gerar Relatórios por Tipo de Cela: (Vinicius)
DELIMITER //

CREATE PROCEDURE relatorio_detentos_por_tipo_cela()
BEGIN
    SELECT c.tipo, COUNT(d.id) AS quantidade_detentos
    FROM detento d
    JOIN cela c ON d.id_cela = c.id
    GROUP BY c.tipo;
END //

DELIMITER ;

-- Procedimento para Relatório de Visitas e Detentos com Junção de Tabelas (Vinicius)
DELIMITER //

CREATE PROCEDURE relatorio_visitas_detentos()
BEGIN
    SELECT v.id AS visita_id, d.nome AS detento_nome, v.data_visita, v.hora_entrada, v.hora_saida
    FROM visita v
    JOIN detento d ON v.id_detento = d.id;
END //

DELIMITER ;

-- ============================== ex 02 - Functions ==============================

-- Função para calcular o tempo de permanência do detento (Lucas)
DELIMITER //

CREATE FUNCTION calcular_tempo_permanencia(data_ingresso DATE, data_saida DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE tempo_permanencia INT;

    IF data_saida IS NULL THEN
        SET tempo_permanencia = TIMESTAMPDIFF(DAY, data_ingresso, CURDATE());
    ELSE
        SET tempo_permanencia = TIMESTAMPDIFF(DAY, data_ingresso, data_saida);
    END IF;

    RETURN tempo_permanencia;
END //

DELIMITER ;

-- Função para Calcular a Idade do Detento (Vinicius)
DELIMITER //

CREATE FUNCTION calcular_idade(data_nascimento DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE idade INT;
    SET idade = TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE());
    RETURN idade;
END //

DELIMITER ;

-- Função para Formatar o Nome do Detento (Vinicius)
DELIMITER //

CREATE FUNCTION formatar_nome(nome VARCHAR(100))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    RETURN CONCAT(UCASE(LEFT(nome, 1)), LCASE(SUBSTRING(nome, 2)));
END //

DELIMITER ; 

-- ============================== ex 03 - Triggers ==============================

-- Trigger para backup de dados de detendo antes de exclusão (Lucas)
DELIMITER //

CREATE TRIGGER before_detento_delete
BEFORE DELETE ON detento
FOR EACH ROW
BEGIN
    INSERT INTO detento_backup (id, nome, data_nascimento, altura, peso, sexo, historico_delitos, data_ingresso, data_saida, motivo_saida, id_cela)
    VALUES (OLD.id, OLD.nome, OLD.data_nascimento, OLD.altura, OLD.peso, OLD.sexo, OLD.historico_delitos, OLD.data_ingresso, OLD.data_saida, OLD.motivo_saida, OLD.id_cela);
END //

DELIMITER ;

-- Trigger para atualizar data de saída do detento quando for inserido o motivo de saída (Lucas)
DELIMITER //

CREATE TRIGGER after_detento_update
AFTER UPDATE ON detento
FOR EACH ROW
BEGIN
    IF NEW.motivo_saida IS NOT NULL AND OLD.motivo_saida IS NULL THEN
        UPDATE detento
        SET data_saida = CURDATE()
        WHERE id = NEW.id;
    END IF;
END //

DELIMITER ;

-- Trigger para Atualizar a Data de Saída do Detento ao Mudar a Cela (Vinicius)
DELIMITER //

CREATE TRIGGER atualizar_data_saida_detento
AFTER UPDATE ON cela
FOR EACH ROW
BEGIN
    IF OLD.id <> NEW.id THEN
        UPDATE detento
        SET data_saida = CURDATE()
        WHERE id_cela = OLD.id;
    END IF;
END //

DELIMITER ;

-- Trigger para Registro de Exclusão de Visitante (Vinicius)
ALTER TABLE visitante
ADD COLUMN motivo_exclusao VARCHAR(255),
ADD COLUMN data_exclusao DATETIME;

DELIMITER //

CREATE TRIGGER marcar_exclusao_visitante
BEFORE DELETE ON visitante
FOR EACH ROW
BEGIN
    SET @sql = CONCAT(
        'UPDATE visitante SET motivo_exclusao = \'Excluído por administrador\', data_exclusao = NOW() WHERE id = ', OLD.id
    );
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;


