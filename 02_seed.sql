-- =============================================================================
-- Questão 06: Carga de dados (DML) — mínimo de 10 registros por tabela
-- Rode DEPOIS de 01_ddl.sql.
--
-- As tabelas usam SERIAL; os IDs gerados seguem a ordem de inserção abaixo
-- (aeroporto usa codigo_iata como chave natural).
-- =============================================================================

-- 1) Aeroporto (12) -----------------------------------------------------------
INSERT INTO aeroporto (codigo_iata, nome, cidade, pais, fuso_horario) VALUES
('GRU','Guarulhos Intl',        'Sao Paulo',     'Brasil',   'UTC-3'),
('CGH','Congonhas',             'Sao Paulo',     'Brasil',   'UTC-3'),
('GIG','Galeao Intl',           'Rio de Janeiro','Brasil',   'UTC-3'),
('SDU','Santos Dumont',         'Rio de Janeiro','Brasil',   'UTC-3'),
('BSB','Pres. Juscelino K.',    'Brasilia',      'Brasil',   'UTC-3'),
('CNF','Tancredo Neves',        'Belo Horizonte','Brasil',   'UTC-3'),
('SSA','Dep. Luis E. Magalhaes','Salvador',      'Brasil',   'UTC-3'),
('REC','Guararapes',            'Recife',        'Brasil',   'UTC-3'),
('POA','Salgado Filho',         'Porto Alegre',  'Brasil',   'UTC-3'),
('CWB','Afonso Pena',           'Curitiba',      'Brasil',   'UTC-3'),
('MIA','Miami Intl',            'Miami',         'EUA',      'UTC-4'),
('LIS','Humberto Delgado',      'Lisboa',        'Portugal', 'UTC+1');

-- 2) Companhia Aérea (10) -----------------------------------------------------
INSERT INTO companhia_aerea (nome, codigo_iata, pais) VALUES
('LATAM',          'LA','Brasil'),    -- id 1
('GOL',            'G3','Brasil'),    -- id 2
('Azul',           'AD','Brasil'),    -- id 3
('Avianca',        'AV','Colombia'),  -- id 4
('American Air',   'AA','EUA'),       -- id 5
('Delta',          'DL','EUA'),       -- id 6
('United',         'UA','EUA'),       -- id 7
('Emirates',       'EK','EAU'),       -- id 8
('TAP',            'TP','Portugal'),  -- id 9
('Iberia',         'IB','Espanha');   -- id 10

-- 3) Modelo de Aeronave (10) --------------------------------------------------
INSERT INTO modelo_aeronave (fabricante, modelo, capacidade) VALUES
('Boeing', '737-800',  189),  -- id 1
('Boeing', '737 MAX',  186),  -- id 2
('Airbus', 'A320',     180),  -- id 3
('Airbus', 'A320neo',  186),  -- id 4
('Airbus', 'A321',     220),  -- id 5
('Airbus', 'A350',     325),  -- id 6
('Boeing', '777',      396),  -- id 7
('Boeing', '787',      296),  -- id 8
('Embraer','E195',     124),  -- id 9
('ATR',    '72',        70);  -- id 10

-- 4) Aeronave (10) ------------------------------------------------------------
INSERT INTO aeronave (prefixo, modelo_id, companhia_id, ano_fabricacao) VALUES
('PR-AAA', 1, 1, 2018),
('PR-BBB', 3, 1, 2020),
('PS-CCC', 9, 2, 2019),
('PS-DDD', 3, 2, 2021),
('PR-EEE', 4, 3, 2022),
('PR-FFF', 9, 3, 2017),
('N100AA', 7, 5, 2015),
('N200DL', 8, 6, 2016),
('A6-EMI', 6, 8, 2019),
('CS-TPA', 5, 9, 2020);

-- 5) Rota (10) ----------------------------------------------------------------
INSERT INTO rota (aeroporto_origem, aeroporto_destino, distancia_km) VALUES
('GRU','GIG', 360),   -- id 1
('GRU','BSB', 870),   -- id 2
('CGH','SDU', 360),   -- id 3
('GIG','CNF', 370),   -- id 4
('BSB','CNF', 600),   -- id 5
('SSA','REC', 680),   -- id 6
('POA','CWB', 540),   -- id 7
('GRU','MIA',6600),   -- id 8
('GRU','LIS',7900),   -- id 9
('CNF','SSA', 960);   -- id 10

-- 6) Voo Programado (10) ------------------------------------------------------
INSERT INTO voo_programado (numero_voo, rota_id, companhia_id, hora_partida, hora_chegada) VALUES
('LA3001', 1, 1, '08:00','09:00'),  -- id 1
('LA3002', 2, 1, '10:00','11:45'),  -- id 2
('G31001', 3, 2, '07:00','08:00'),  -- id 3
('G31002', 4, 2, '12:00','13:10'),  -- id 4
('AD2001', 5, 3, '09:30','10:30'),  -- id 5
('AD2002', 6, 3, '14:00','15:20'),  -- id 6
('AD2003', 7, 3, '16:00','17:00'),  -- id 7
('LA8000', 8, 1, '22:00','06:00'),  -- id 8
('TP0080', 9, 9, '23:00','13:00'),  -- id 9
('LA3010',10, 1, '18:00','19:40');  -- id 10

-- 7) Passageiro (12) ----------------------------------------------------------
INSERT INTO passageiro (cpf, nome, data_nascimento) VALUES
('11111111111','Joao Faria',        '1995-03-12'),  -- id 1
('22222222222','Mariana Souza',     '1988-07-25'),  -- id 2
('33333333333','Carlos Pereira',    '1992-11-03'),  -- id 3
('44444444444','Beatriz Lima',      '2000-01-18'),  -- id 4
('55555555555','Rafael Costa',      '1979-09-30'),  -- id 5
('66666666666','Fernanda Alves',    '1985-05-09'),  -- id 6
('77777777777','Gustavo Rocha',     '1998-12-22'),  -- id 7
('88888888888','Patricia Gomes',    '1990-04-14'),  -- id 8
('99999999999','Eduardo Martins',   '1983-08-07'),  -- id 9
('10101010101','Luciana Barros',    '1996-02-28'),  -- id 10
('12121212121','Thiago Nunes',      '2001-06-16'),  -- id 11
('13131313131','Camila Ribeiro',    '1987-10-11');  -- id 12

-- 8) Tripulante (12) ----------------------------------------------------------
INSERT INTO tripulante (nome, cargo, num_licenca, companhia_id) VALUES
('Roberto Dias',     'COMANDANTE', 'LIC-0001', 1),  -- id 1
('Sandra Melo',      'COPILOTO',   'LIC-0002', 1),  -- id 2
('Paulo Henrique',   'COMISSARIO', 'LIC-0003', 1),  -- id 3
('Aline Cardoso',    'COMANDANTE', 'LIC-0004', 2),  -- id 4
('Marcos Vieira',    'COMANDANTE', 'LIC-0005', 2),  -- id 5
('Juliana Freitas',  'COPILOTO',   'LIC-0006', 2),  -- id 6
('Andre Teixeira',   'COMANDANTE', 'LIC-0007', 3),  -- id 7
('Vanessa Pinto',    'COMISSARIO', 'LIC-0008', 3),  -- id 8
('Felipe Ramos',     'COMANDANTE', 'LIC-0009', 3),  -- id 9
('Bruna Carvalho',   'COMANDANTE', 'LIC-0010', 1),  -- id 10
('Diego Fernandes',  'COMANDANTE', 'LIC-0011', 9),  -- id 11
('Renata Azevedo',   'COMISSARIO', 'LIC-0012', 1);  -- id 12

-- Terminal (10) ---------------------------------------------------------------
INSERT INTO terminal (aeroporto_iata, numero_terminal, nome) VALUES
('GRU',1,'Terminal 1'),
('GRU',2,'Terminal 2'),
('CGH',1,'Terminal Unico'),
('GIG',1,'Terminal 1'),
('GIG',2,'Terminal 2'),
('BSB',1,'Terminal Principal'),
('CNF',1,'Terminal Principal'),
('SSA',1,'Terminal Principal'),
('REC',1,'Terminal Principal'),
('POA',1,'Terminal Principal');

-- Portao (10) -----------------------------------------------------------------
INSERT INTO portao (aeroporto_iata, numero_terminal, numero_portao) VALUES
('GRU',1,1),
('GRU',1,2),
('GRU',2,1),
('CGH',1,1),
('GIG',1,1),
('GIG',2,1),
('BSB',1,1),
('CNF',1,1),
('SSA',1,1),
('POA',1,1);

-- Assento (12) ----------------------------------------------------------------
INSERT INTO assento (aeronave_prefixo, numero_assento, classe) VALUES
('PR-AAA','1A','EXECUTIVA'),
('PR-AAA','1B','EXECUTIVA'),
('PR-AAA','12A','ECONOMICA'),
('PR-AAA','12B','ECONOMICA'),
('PR-AAA','14C','ECONOMICA'),
('PR-AAA','14D','ECONOMICA'),
('PR-BBB','1A','EXECUTIVA'),
('PR-BBB','10A','ECONOMICA'),
('PR-BBB','10B','ECONOMICA'),
('PS-CCC','5D','ECONOMICA'),
('PS-CCC','7F','ECONOMICA'),
('PR-EEE','3C','ECONOMICA');

-- Ocorrência de Voo (11) ------------------------------------------------------
INSERT INTO ocorrencia_voo
    (voo_programado_id, data, aeronave_prefixo, portao_aeroporto, portao_terminal, portao_numero, status) VALUES
(1, '2026-06-10','PR-AAA','GRU',1,1,'POUSOU'),
(1, '2026-06-11','PR-AAA','GRU',1,2,'PROGRAMADO'),
(2, '2026-06-10','PR-BBB','GRU',2,1,'POUSOU'),
(3, '2026-06-10','PS-CCC','CGH',1,1,'POUSOU'),
(4, '2026-06-10','PS-DDD','GIG',1,1,'DECOLOU'),
(5, '2026-06-10','PR-EEE','BSB',1,1,'POUSOU'),
(6, '2026-06-10','PR-FFF','SSA',1,1,'CANCELADO'),
(7, '2026-06-10','PR-EEE','POA',1,1,'POUSOU'),
(8, '2026-06-12','PR-AAA','GRU',1,1,'PROGRAMADO'),
(9, '2026-06-12','CS-TPA','GRU',2,1,'PROGRAMADO'),
(10,'2026-06-11','PR-BBB','CNF',1,1,'EMBARCANDO');

-- Bilhete (14) ----------------------------------------------------------------
-- (passageiro_id, voo_programado_id, data_ocorrencia, assento, classe, preco, checkin)
INSERT INTO bilhete
    (passageiro_id, voo_programado_id, data_ocorrencia, numero_assento, classe, preco, status_checkin) VALUES
( 1, 1, '2026-06-10','12A','ECONOMICA',  450.00, TRUE),   -- id 1
( 2, 1, '2026-06-10','12B','ECONOMICA',  450.00, TRUE),   -- id 2
( 3, 1, '2026-06-10','1A', 'EXECUTIVA',  900.00, FALSE),  -- id 3
( 4, 2, '2026-06-10','14C','ECONOMICA',  600.00, TRUE),   -- id 4
( 5, 3, '2026-06-10','10A','ECONOMICA',  300.00, TRUE),   -- id 5
( 1, 3, '2026-06-10','10B','ECONOMICA',  300.00, FALSE),  -- id 6  (pax1 voa de CGH tambem)
( 6, 4, '2026-06-10','5D', 'ECONOMICA',  350.00, TRUE),   -- id 7
( 7, 5, '2026-06-10','7F', 'ECONOMICA',  500.00, TRUE),   -- id 8
( 8, 6, '2026-06-10','3C', 'EXECUTIVA',  700.00, FALSE),  -- id 9
( 9, 7, '2026-06-10','3C', 'ECONOMICA',  280.00, TRUE),   -- id 10
(10, 8, '2026-06-12','1A', 'PRIMEIRA',  3500.00, FALSE),  -- id 11
(11, 9, '2026-06-12','1B', 'EXECUTIVA', 4200.00, FALSE),  -- id 12
(12,10, '2026-06-11','10A','ECONOMICA',  320.00, TRUE),   -- id 13
( 2, 2, '2026-06-10','14D','ECONOMICA',  600.00, FALSE);  -- id 14 (pax2 de GRU 2x)

-- Bagagem (11) ----------------------------------------------------------------
INSERT INTO bagagem (bilhete_id, numero_volume, peso_kg) VALUES
( 1, 1, 23.0),
( 1, 2, 15.5),
( 2, 1, 20.0),
( 3, 1, 18.0),
( 4, 1, 25.0),
( 5, 1, 10.0),
( 7, 1, 30.0),
( 8, 1, 22.0),
( 9, 1, 12.0),
(11, 1, 28.0),
(12, 1, 19.0);

-- Escalacao (12) — relacionamento COM ATRIBUTOS -------------------------------
INSERT INTO escalacao (tripulante_id, voo_programado_id, data_ocorrencia, funcao_no_voo, horario_apresentacao) VALUES
( 1, 1, '2026-06-10','COMANDANTE','06:30'),
( 2, 1, '2026-06-10','COPILOTO',  '06:30'),
( 3, 1, '2026-06-10','COMISSARIO','06:45'),
( 4, 2, '2026-06-10','COMANDANTE','08:30'),
( 5, 3, '2026-06-10','COMANDANTE','05:30'),
( 6, 4, '2026-06-10','COPILOTO',  '10:30'),
( 7, 5, '2026-06-10','COMANDANTE','08:00'),
( 8, 6, '2026-06-10','COMISSARIO','12:30'),
( 9, 7, '2026-06-10','COMANDANTE','14:30'),
(10, 8, '2026-06-12','COMANDANTE','20:30'),
(11, 9, '2026-06-12','COMANDANTE','21:30'),
(12,10, '2026-06-11','COMISSARIO','16:30');

-- Dependente (10) -------------------------------------------------------------
INSERT INTO dependente (tripulante_id, nome, parentesco, data_nascimento) VALUES
( 1,'Maria Dias',      'CONJUGE','1990-05-01'),
( 1,'Joao Dias',       'FILHO',  '2015-09-20'),
( 2,'Ana Melo',        'CONJUGE','1986-03-15'),
( 4,'Pedro Cardoso',   'FILHO',  '2012-07-08'),
( 4,'Lucas Cardoso',   'FILHO',  '2014-11-30'),
( 5,'Carla Vieira',    'CONJUGE','1982-01-22'),
( 7,'Sofia Teixeira',  'FILHA',  '2018-04-10'),
( 8,'Rita Pinto',      'MAE',    '1955-06-05'),
( 9,'Bruno Ramos',     'FILHO',  '2010-12-12'),
(10,'Clara Carvalho',  'CONJUGE','1989-08-19');

-- AtendimentoCia (10) ---------------------------------------------------------
INSERT INTO atendimento_cia (companhia_id, aeroporto_iata, terminal_base, data_inicio_operacao) VALUES
( 1,'GRU',1,'2010-01-01'),
( 1,'GIG',1,'2011-03-01'),
( 1,'BSB',1,'2012-06-01'),
( 2,'CGH',1,'2009-05-01'),
( 2,'SDU',1,'2013-08-01'),
( 2,'GRU',2,'2015-02-01'),
( 3,'BSB',1,'2014-09-01'),
( 3,'SSA',1,'2016-11-01'),
( 5,'MIA',1,'2008-01-01'),
( 9,'LIS',1,'2007-04-01');
