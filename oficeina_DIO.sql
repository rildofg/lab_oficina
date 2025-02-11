
-- Criando o banco de dados
CREATE DATABASE Oficina;
USE Oficina;

-- Criando a tabela de Clientes
CREATE TABLE Clientes (
    id_cliente INT PRIMARY KEY IDENTITY(1,1),
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(15),
    email VARCHAR(100),
    endereco VARCHAR(255)
);

-- Criando a tabela de Veículos
CREATE TABLE Veiculos (
    id_veiculo INT PRIMARY KEY IDENTITY(1,1),
    id_cliente INT NOT NULL,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(50) NOT NULL,
    ano INT NOT NULL,
    placa VARCHAR(10) UNIQUE NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);
 
-- Criando a tabela de Serviços
CREATE TABLE Servicos (
    id_servico INT PRIMARY KEY IDENTITY(1,1),
    descricao VARCHAR(255) NOT NULL,
    preco DECIMAL(10,2) NOT NULL
);

-- Criando a tabela de Ordens de Serviço
CREATE TABLE OrdensDeServico (
    id_ordem INT PRIMARY KEY IDENTITY(1,1),
    id_veiculo INT NOT NULL,
    data_abertura DATE NOT NULL,
    data_fechamento DATE,
    status VARCHAR(30) NOT NULL, 
    FOREIGN KEY (id_veiculo) REFERENCES Veiculos(id_veiculo)
--Para o status da tabela de ordens de serviço os valores para preenchimento podem ser ('Aberto', 'Em andamento', 'Concluído').
);


-- Criando a tabela de Itens da Ordem de Serviço
CREATE TABLE ItensOrdemServico (
    id_item INT PRIMARY KEY IDENTITY(1,1),
    id_ordem INT NOT NULL,
    id_servico INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_ordem) REFERENCES OrdensDeServico(id_ordem),
    FOREIGN KEY (id_servico) REFERENCES Servicos(id_servico)
);

-- Inserindo dados de teste
INSERT INTO Clientes (nome, telefone, email, endereco) VALUES
('João Silva', '11999999999', 'joao@email.com', 'Rua A, 100'),
('Maria Souza', '11888888888', 'maria@email.com', 'Rua B, 200'),
('Luiz Souza', '11777777777', 'luiz@email.com', 'Rua B, 230');

INSERT INTO Veiculos (id_cliente, marca, modelo, ano, placa) VALUES
(1, 'Ford', 'Fiesta', 2015, 'ABC1D23'),
(2, 'Chevrolet', 'Onix', 2020, 'XYZ4E56'),
(3, 'Ford', 'Corcel II LDO', 1986, 'XAT4E86');

INSERT INTO Servicos (descricao, preco) VALUES
('Troca de óleo', 150.00),
('Alinhamento e balanceamento', 200.00),
('Discos e Pastilhas de Freios', 330.00);

INSERT INTO OrdensDeServico (id_veiculo, data_abertura, status) VALUES
(1, '2024-02-01', 'Aberto'),
(2, '2024-02-02', 'Em andamento'),
(3, '2024-02-02', 'Concluído');

INSERT INTO ItensOrdemServico (id_ordem, id_servico, quantidade, preco_unitario) VALUES
(1, 1, 1, 150.00),
(2, 2, 1, 200.00),
(3, 3, 1, 330.00);


-- Queries para respostas do modelo

-- 1. Selecionar todos os clientes e seus veículos
SELECT c.nome, v.marca, v.modelo, v.ano, v.placa
FROM Clientes c
LEFT JOIN Veiculos v ON c.id_cliente = v.id_cliente;

-- 2. Selecionar ordens de serviço abertas
SELECT TOP 10 * FROM OrdensDeServico WHERE status = 'Aberto';

-- 3. Selecionar os serviços prestados em uma ordem de serviço
SELECT o.id_ordem, s.descricao, i.quantidade, i.preco_unitario
FROM ItensOrdemServico i
LEFT JOIN Servicos s ON i.id_servico = s.id_servico
LEFT JOIN OrdensDeServico o ON i.id_ordem = o.id_ordem
WHERE o.id_ordem = 1;

-- 4. Quantidade de ordens de serviço por status
SELECT status, COUNT(*) AS quantidade FROM OrdensDeServico GROUP BY status;

-- 5. Receita total por serviço
SELECT s.descricao, SUM(i.quantidade * i.preco_unitario) AS receita_total
FROM ItensOrdemServico i
LEFT JOIN Servicos s ON i.id_servico = s.id_servico
GROUP BY s.descricao;

-- 6. Receita total da oficina
SELECT SUM(i.quantidade * i.preco_unitario) AS receita_total FROM ItensOrdemServico;

-- 7. Selecionar ordens de serviço que faturaram mais que R$ 150,00
SELECT o.id_ordem, SUM(i.quantidade * i.preco_unitario) AS faturamento
FROM ItensOrdemServico i
LEFT JOIN OrdensDeServico o ON i.id_ordem = o.id_ordem
GROUP BY o.id_ordem
HAVING faturamento > 150.00;

-- 8. Clientes com mais de um veículo cadastrado
SELECT c.nome, COUNT(v.id_veiculo) AS total_veiculos
FROM Clientes c
LEFT JOIN Veiculos v ON c.id_cliente = v.id_cliente
GROUP BY c.nome
HAVING total_veiculos > 1;

-- 9. Selecionar os serviços realizados em fevereiro de 2024
SELECT s.descricao, COUNT(*) AS total_servicos
FROM ItensOrdemServico i
LEFT JOIN Servicos s ON i.id_servico = s.id_servico
LEFT JOIN OrdensDeServico o ON i.id_ordem = o.id_ordem
WHERE MONTH(o.data_abertura) = 2 AND YEAR(o.data_abertura) = 2024
GROUP BY s.descricao;

 
-- 10. Listar os veículos atendidos em ordens de serviço
SELECT DISTINCT v.marca, v.modelo, v.placa
FROM Veiculos v
LEFT JOIN OrdensDeServico o ON v.id_veiculo = o.id_veiculo;
