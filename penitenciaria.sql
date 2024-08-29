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