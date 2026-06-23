-- =============================================================================
-- Projeto Final de Banco de Dados — Rede Aérea
-- Questão 03: DDL de criação do banco
-- Questão 04: Restrições (CHECK, DEFAULT, CHECK baseado em lista, UNIQUE)
-- SGBD: PostgreSQL
--
-- Para recriar do zero, rode este arquivo inteiro. As tabelas são removidas
-- em ordem reversa de dependência antes de serem recriadas.
-- =============================================================================

DROP TABLE IF EXISTS atendimento_cia   CASCADE;
DROP TABLE IF EXISTS escalacao         CASCADE;
DROP TABLE IF EXISTS bagagem           CASCADE;
DROP TABLE IF EXISTS bilhete           CASCADE;
DROP TABLE IF EXISTS dependente        CASCADE;
DROP TABLE IF EXISTS assento           CASCADE;
DROP TABLE IF EXISTS ocorrencia_voo    CASCADE;
DROP TABLE IF EXISTS portao            CASCADE;
DROP TABLE IF EXISTS terminal          CASCADE;
DROP TABLE IF EXISTS voo_programado    CASCADE;
DROP TABLE IF EXISTS rota              CASCADE;
DROP TABLE IF EXISTS aeronave          CASCADE;
DROP TABLE IF EXISTS modelo_aeronave   CASCADE;
DROP TABLE IF EXISTS tripulante        CASCADE;
DROP TABLE IF EXISTS passageiro        CASCADE;
DROP TABLE IF EXISTS companhia_aerea   CASCADE;
DROP TABLE IF EXISTS aeroporto         CASCADE;

-- =============================================================================
-- ENTIDADES FORTES
-- =============================================================================

-- 1) Aeroporto -----------------------------------------------------------------
CREATE TABLE aeroporto (
    codigo_iata   CHAR(3)      PRIMARY KEY,
    nome          VARCHAR(120) NOT NULL,
    cidade        VARCHAR(80)  NOT NULL,
    pais          VARCHAR(60)  NOT NULL DEFAULT 'Brasil',   -- [Q4] DEFAULT
    fuso_horario  VARCHAR(10)  NOT NULL DEFAULT 'UTC-3'      -- [Q4] DEFAULT
);

-- 2) Companhia Aérea -----------------------------------------------------------
CREATE TABLE companhia_aerea (
    id           SERIAL       PRIMARY KEY,
    nome         VARCHAR(120) NOT NULL,
    codigo_iata  CHAR(2)      NOT NULL UNIQUE,              -- [Q4] UNIQUE
    pais         VARCHAR(60)  NOT NULL DEFAULT 'Brasil'      -- [Q4] DEFAULT
);

-- 3) Modelo de Aeronave --------------------------------------------------------
CREATE TABLE modelo_aeronave (
    id          SERIAL       PRIMARY KEY,
    fabricante  VARCHAR(60)  NOT NULL,
    modelo      VARCHAR(60)  NOT NULL,
    capacidade  INTEGER      NOT NULL CHECK (capacidade > 0),  -- [Q4] CHECK
    CONSTRAINT uq_modelo UNIQUE (fabricante, modelo)           -- [Q4] UNIQUE composta
);

-- 4) Aeronave ------------------------------------------------------------------
CREATE TABLE aeronave (
    prefixo         VARCHAR(7) PRIMARY KEY,                     -- ex.: PR-XYZ
    modelo_id       INTEGER    NOT NULL REFERENCES modelo_aeronave(id),
    companhia_id    INTEGER    NOT NULL REFERENCES companhia_aerea(id),
    ano_fabricacao  INTEGER    NOT NULL CHECK (ano_fabricacao BETWEEN 1950 AND 2100) -- [Q4] CHECK
);

-- 5) Rota ----------------------------------------------------------------------
CREATE TABLE rota (
    id                 SERIAL  PRIMARY KEY,
    aeroporto_origem   CHAR(3) NOT NULL REFERENCES aeroporto(codigo_iata),
    aeroporto_destino  CHAR(3) NOT NULL REFERENCES aeroporto(codigo_iata),
    distancia_km       INTEGER NOT NULL CHECK (distancia_km > 0),  -- [Q4] CHECK
    CONSTRAINT ck_rota_diferente CHECK (aeroporto_origem <> aeroporto_destino), -- [Q4] CHECK
    CONSTRAINT uq_rota UNIQUE (aeroporto_origem, aeroporto_destino)             -- [Q4] UNIQUE composta
);

-- 6) Voo Programado ------------------------------------------------------------
CREATE TABLE voo_programado (
    id            SERIAL      PRIMARY KEY,
    numero_voo    VARCHAR(7)  NOT NULL,
    rota_id       INTEGER     NOT NULL REFERENCES rota(id),
    companhia_id  INTEGER     NOT NULL REFERENCES companhia_aerea(id),
    hora_partida  TIME        NOT NULL,
    hora_chegada  TIME        NOT NULL,
    CONSTRAINT uq_voo_numero UNIQUE (companhia_id, numero_voo)   -- [Q4] UNIQUE composta
);

-- 7) Passageiro ----------------------------------------------------------------
CREATE TABLE passageiro (
    id               SERIAL       PRIMARY KEY,
    cpf              CHAR(11)     NOT NULL UNIQUE,           -- [Q4] UNIQUE
    nome             VARCHAR(120) NOT NULL,
    data_nascimento  DATE         NOT NULL
);

-- 8) Tripulante ----------------------------------------------------------------
CREATE TABLE tripulante (
    id            SERIAL       PRIMARY KEY,
    nome          VARCHAR(120) NOT NULL,
    cargo         VARCHAR(20)  NOT NULL
                  CHECK (cargo IN ('COMANDANTE','COPILOTO','COMISSARIO')), -- [Q4] CHECK em lista
    num_licenca   VARCHAR(20)  NOT NULL UNIQUE,             -- [Q4] UNIQUE
    companhia_id  INTEGER      NOT NULL REFERENCES companhia_aerea(id)
);

-- =============================================================================
-- ENTIDADES FRACAS
-- =============================================================================

-- Terminal (fraca de Aeroporto) -----------------------------------------------
CREATE TABLE terminal (
    aeroporto_iata   CHAR(3)     NOT NULL REFERENCES aeroporto(codigo_iata),
    numero_terminal  INTEGER     NOT NULL,
    nome             VARCHAR(40) NOT NULL DEFAULT 'Terminal Principal', -- [Q4] DEFAULT
    PRIMARY KEY (aeroporto_iata, numero_terminal)
);

-- Portao (fraca de Terminal — fraca aninhada) ---------------------------------
CREATE TABLE portao (
    aeroporto_iata   CHAR(3) NOT NULL,
    numero_terminal  INTEGER NOT NULL,
    numero_portao    INTEGER NOT NULL,
    PRIMARY KEY (aeroporto_iata, numero_terminal, numero_portao),
    FOREIGN KEY (aeroporto_iata, numero_terminal)
        REFERENCES terminal(aeroporto_iata, numero_terminal)
);

-- Assento (fraca de Aeronave) -------------------------------------------------
CREATE TABLE assento (
    aeronave_prefixo  VARCHAR(7)  NOT NULL REFERENCES aeronave(prefixo),
    numero_assento    VARCHAR(4)  NOT NULL,                   -- ex.: 12A
    classe            VARCHAR(12) NOT NULL DEFAULT 'ECONOMICA' -- [Q4] DEFAULT
                      CHECK (classe IN ('ECONOMICA','EXECUTIVA','PRIMEIRA')), -- [Q4] CHECK em lista
    PRIMARY KEY (aeronave_prefixo, numero_assento)
);

-- Dependente (fraca de Tripulante) --------------------------------------------
CREATE TABLE dependente (
    tripulante_id    INTEGER      NOT NULL REFERENCES tripulante(id),
    nome             VARCHAR(120) NOT NULL,
    parentesco       VARCHAR(20)  NOT NULL
                     CHECK (parentesco IN ('CONJUGE','FILHO','FILHA','PAI','MAE')), -- [Q4] CHECK em lista
    data_nascimento  DATE         NOT NULL,
    PRIMARY KEY (tripulante_id, nome)
);

-- Ocorrência de Voo (fraca de VooProgramado) ----------------------------------
CREATE TABLE ocorrencia_voo (
    voo_programado_id  INTEGER     NOT NULL REFERENCES voo_programado(id),
    data               DATE        NOT NULL,
    aeronave_prefixo   VARCHAR(7)  NOT NULL REFERENCES aeronave(prefixo),
    -- portão de embarque (FK composta para a fraca portao); opcional
    portao_aeroporto   CHAR(3),
    portao_terminal    INTEGER,
    portao_numero      INTEGER,
    status             VARCHAR(12) NOT NULL DEFAULT 'PROGRAMADO'  -- [Q4] DEFAULT
                       CHECK (status IN ('PROGRAMADO','EMBARCANDO','DECOLOU','POUSOU','CANCELADO')), -- [Q4] CHECK em lista
    PRIMARY KEY (voo_programado_id, data),
    FOREIGN KEY (portao_aeroporto, portao_terminal, portao_numero)
        REFERENCES portao(aeroporto_iata, numero_terminal, numero_portao)
);

-- =============================================================================
-- TABELAS ASSOCIATIVAS (relacionamentos N:N com atributos)
-- =============================================================================

-- Bilhete = Passageiro x OcorrenciaVoo ----------------------------------------
CREATE TABLE bilhete (
    id               SERIAL       PRIMARY KEY,
    passageiro_id    INTEGER      NOT NULL REFERENCES passageiro(id),
    voo_programado_id INTEGER     NOT NULL,
    data_ocorrencia  DATE         NOT NULL,
    numero_assento   VARCHAR(4)   NOT NULL,
    classe           VARCHAR(12)  NOT NULL DEFAULT 'ECONOMICA'  -- [Q4] DEFAULT
                     CHECK (classe IN ('ECONOMICA','EXECUTIVA','PRIMEIRA')), -- [Q4] CHECK em lista
    preco            NUMERIC(10,2) NOT NULL CHECK (preco > 0),   -- [Q4] CHECK
    status_checkin   BOOLEAN      NOT NULL DEFAULT FALSE,        -- [Q4] DEFAULT
    FOREIGN KEY (voo_programado_id, data_ocorrencia)
        REFERENCES ocorrencia_voo(voo_programado_id, data),
    -- não pode haver dois bilhetes no mesmo assento da mesma ocorrência
    CONSTRAINT uq_assento_ocorrencia
        UNIQUE (voo_programado_id, data_ocorrencia, numero_assento) -- [Q4] UNIQUE composta
);

-- Bagagem (fraca de Bilhete) --------------------------------------------------
CREATE TABLE bagagem (
    bilhete_id     INTEGER       NOT NULL REFERENCES bilhete(id),
    numero_volume  INTEGER       NOT NULL,
    peso_kg        NUMERIC(5,2)  NOT NULL CHECK (peso_kg > 0 AND peso_kg <= 32), -- [Q4] CHECK
    PRIMARY KEY (bilhete_id, numero_volume)
);

-- Escalacao = Tripulante x OcorrenciaVoo (relacionamento COM ATRIBUTOS) --------
CREATE TABLE escalacao (
    tripulante_id      INTEGER     NOT NULL REFERENCES tripulante(id),
    voo_programado_id  INTEGER     NOT NULL,
    data_ocorrencia    DATE        NOT NULL,
    funcao_no_voo      VARCHAR(20) NOT NULL
                       CHECK (funcao_no_voo IN ('COMANDANTE','COPILOTO','COMISSARIO')), -- [Q4] CHECK em lista
    horario_apresentacao TIME      NOT NULL,
    PRIMARY KEY (tripulante_id, voo_programado_id, data_ocorrencia),
    FOREIGN KEY (voo_programado_id, data_ocorrencia)
        REFERENCES ocorrencia_voo(voo_programado_id, data)
);

-- AtendimentoCia = CompanhiaAerea x Aeroporto ---------------------------------
CREATE TABLE atendimento_cia (
    companhia_id          INTEGER NOT NULL REFERENCES companhia_aerea(id),
    aeroporto_iata        CHAR(3) NOT NULL REFERENCES aeroporto(codigo_iata),
    terminal_base         INTEGER NOT NULL DEFAULT 1,            -- [Q4] DEFAULT
    data_inicio_operacao  DATE    NOT NULL DEFAULT CURRENT_DATE, -- [Q4] DEFAULT
    PRIMARY KEY (companhia_id, aeroporto_iata)
);
