-- =============================================================================
-- Questão 05: Scripts DML que VIOLAM cada restrição da Questão 04.
-- Cada comando abaixo DEVE FALHAR. A mensagem de erro esperada do PostgreSQL
-- está comentada acima de cada um. Rode um por vez para observar o erro.
--
-- Rode DEPOIS de 01_ddl.sql e 02_seed.sql.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1) Violação de CHECK (valor numérico) — capacidade deve ser > 0
--    ERRO esperado: new row ... violates check constraint "modelo_aeronave_capacidade_check"
-- -----------------------------------------------------------------------------
INSERT INTO modelo_aeronave (fabricante, modelo, capacidade)
VALUES ('Boeing','737-TESTE', 0);

-- Outro exemplo de CHECK: preço do bilhete deve ser > 0
--    ERRO esperado: violates check constraint "bilhete_preco_check"
INSERT INTO bilhete (passageiro_id, voo_programado_id, data_ocorrencia, numero_assento, preco)
VALUES (1, 1, '2026-06-10','99Z', -10.00);

-- -----------------------------------------------------------------------------
-- 2) Violação de CHECK BASEADO EM LISTA — cargo fora do conjunto permitido
--    ERRO esperado: violates check constraint "tripulante_cargo_check"
-- -----------------------------------------------------------------------------
INSERT INTO tripulante (nome, cargo, num_licenca, companhia_id)
VALUES ('Fulano Teste','PILOTO_DE_TESTE','LIC-9999', 1);

-- Outro exemplo de CHECK em lista: classe inválida no bilhete
--    ERRO esperado: violates check constraint "bilhete_classe_check"
INSERT INTO bilhete (passageiro_id, voo_programado_id, data_ocorrencia, numero_assento, classe, preco)
VALUES (1, 1, '2026-06-10','98Z','SUPER_LUXO', 500.00);

-- -----------------------------------------------------------------------------
-- 3) Violação de UNIQUE — CPF de passageiro duplicado (CPF '11111111111' já existe)
--    ERRO esperado: duplicate key value violates unique constraint "passageiro_cpf_key"
-- -----------------------------------------------------------------------------
INSERT INTO passageiro (cpf, nome, data_nascimento)
VALUES ('11111111111','Clone do Joao','1995-03-12');

-- Outro exemplo de UNIQUE composta: dois bilhetes no mesmo assento da mesma
-- ocorrência (voo 1 / 2026-06-10 / assento 12A já vendido)
--    ERRO esperado: violates unique constraint "uq_assento_ocorrencia"
INSERT INTO bilhete (passageiro_id, voo_programado_id, data_ocorrencia, numero_assento, preco)
VALUES (5, 1, '2026-06-10','12A', 450.00);

-- -----------------------------------------------------------------------------
-- 4) Demonstração de DEFAULT — uma restrição DEFAULT NÃO É VIOLÁVEL por
--    definição: ela apenas fornece um valor quando a coluna é omitida, logo
--    não existe INSERT capaz de "quebrá-la". Em vez de violar, comprovamos que
--    o DEFAULT é de fato aplicado: ao omitir as colunas, o banco preenche os
--    valores padrão. Resultado esperado: pais='Brasil', fuso_horario='UTC-3'.
-- -----------------------------------------------------------------------------
INSERT INTO aeroporto (codigo_iata, nome, cidade)
VALUES ('XXX','Aeroporto Teste Default','Cidade Teste');

SELECT codigo_iata, pais, fuso_horario
FROM aeroporto
WHERE codigo_iata = 'XXX';   -- deve mostrar Brasil / UTC-3

-- limpa o registro de teste do DEFAULT
DELETE FROM aeroporto WHERE codigo_iata = 'XXX';

-- -----------------------------------------------------------------------------
-- 5) (Bônus) Violação de CHECK com intervalo — bagagem acima de 32 kg
--    ERRO esperado: violates check constraint "bagagem_peso_kg_check"
-- -----------------------------------------------------------------------------
INSERT INTO bagagem (bilhete_id, numero_volume, peso_kg)
VALUES (1, 9, 50.0);

-- -----------------------------------------------------------------------------
-- 6) (Bônus) Violação de CHECK de regra de negócio — rota com origem = destino
--    ERRO esperado: violates check constraint "ck_rota_diferente"
-- -----------------------------------------------------------------------------
INSERT INTO rota (aeroporto_origem, aeroporto_destino, distancia_km)
VALUES ('GRU','GRU', 0);
