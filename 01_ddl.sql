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
    codigo_iata   CHAR(3),
    nome          VARCHAR(120) NOT NULL,
    cidade        VARCHAR(80)  NOT NULL,
    pais          VARCHAR(60)  NOT NULL DEFAULT 'Brasil',   -- [Q4] DEFAULT
    fuso_horario  VARCHAR(10)  NOT NULL DEFAULT 'UTC-3',     -- [Q4] DEFAULT
    CONSTRAINT pk_aeroporto PRIMARY KEY (codigo_iata)
);

-- 2) Companhia Aérea -----------------------------------------------------------
CREATE TABLE companhia_aerea (
    id           SERIAL,
    nome         VARCHAR(120) NOT NULL,
    codigo_iata  CHAR(2)      NOT NULL UNIQUE,              -- [Q4] UNIQUE
    pais         VARCHAR(60)  NOT NULL DEFAULT 'Brasil',     -- [Q4] DEFAULT
    CONSTRAINT pk_companhia_aerea PRIMARY KEY (id)
);

-- 3) Modelo de Aeronave --------------------------------------------------------
CREATE TABLE modelo_aeronave (
    id          SERIAL,
    fabricante  VARCHAR(60)  NOT NULL,
    modelo      VARCHAR(60)  NOT NULL,
    capacidade  INTEGER      NOT NULL CHECK (capacidade > 0),  -- [Q4] CHECK
    CONSTRAINT pk_modelo_aeronave PRIMARY KEY (id),
    CONSTRAINT uq_modelo UNIQUE (fabricante, modelo)           -- [Q4] UNIQUE composta
);

-- 4) Aeronave ------------------------------------------------------------------
CREATE TABLE aeronave (
    prefixo         VARCHAR(7),                                 -- ex.: PR-XYZ
    modelo_id       INTEGER    NOT NULL,
    companhia_id    INTEGER    NOT NULL,
    ano_fabricacao  INTEGER    NOT NULL CHECK (ano_fabricacao BETWEEN 1950 AND 2100), -- [Q4] CHECK
    CONSTRAINT pk_aeronave PRIMARY KEY (prefixo),
    CONSTRAINT fk_aeronave_modelo FOREIGN KEY (modelo_id) REFERENCES modelo_aeronave(id),
    CONSTRAINT fk_aeronave_companhia FOREIGN KEY (companhia_id) REFERENCES companhia_aerea(id)
);

-- 5) Rota ----------------------------------------------------------------------
CREATE TABLE rota (
    id                 SERIAL,
    aeroporto_origem   CHAR(3) NOT NULL,
    aeroporto_destino  CHAR(3) NOT NULL,
    distancia_km       INTEGER NOT NULL CHECK (distancia_km > 0),  -- [Q4] CHECK
    CONSTRAINT pk_rota PRIMARY KEY (id),
    CONSTRAINT fk_rota_origem FOREIGN KEY (aeroporto_origem) REFERENCES aeroporto(codigo_iata),
    CONSTRAINT fk_rota_destino FOREIGN KEY (aeroporto_destino) REFERENCES aeroporto(codigo_iata),
    CONSTRAINT ck_rota_diferente CHECK (aeroporto_origem <> aeroporto_destino), -- [Q4] CHECK
    CONSTRAINT uq_rota UNIQUE (aeroporto_origem, aeroporto_destino)             -- [Q4] UNIQUE composta
);

-- 6) Voo Programado ------------------------------------------------------------
CREATE TABLE voo_programado (
    id            SERIAL,
    numero_voo    VARCHAR(7)  NOT NULL,
    rota_id       INTEGER     NOT NULL,
    companhia_id  INTEGER     NOT NULL,
    hora_partida  TIME        NOT NULL,
    hora_chegada  TIME        NOT NULL,
    CONSTRAINT pk_voo_programado PRIMARY KEY (id),
    CONSTRAINT fk_voo_programado_rota FOREIGN KEY (rota_id) REFERENCES rota(id),
    CONSTRAINT fk_voo_programado_companhia FOREIGN KEY (companhia_id) REFERENCES companhia_aerea(id),
    CONSTRAINT uq_voo_numero UNIQUE (companhia_id, numero_voo)   -- [Q4] UNIQUE composta
);

-- 7) Passageiro ----------------------------------------------------------------
CREATE TABLE passageiro (
    id               SERIAL,
    cpf              CHAR(11)     NOT NULL UNIQUE,           -- [Q4] UNIQUE
    nome             VARCHAR(120) NOT NULL,
    data_nascimento  DATE         NOT NULL,
    CONSTRAINT pk_passageiro PRIMARY KEY (id)
);

-- 8) Tripulante ----------------------------------------------------------------
CREATE TABLE tripulante (
    id            SERIAL,
    nome          VARCHAR(120) NOT NULL,
    cargo         VARCHAR(20)  NOT NULL
                  CHECK (cargo IN ('COMANDANTE','COPILOTO','COMISSARIO')), -- [Q4] CHECK em lista
    num_licenca   VARCHAR(20)  NOT NULL UNIQUE,             -- [Q4] UNIQUE
    companhia_id  INTEGER      NOT NULL,
    CONSTRAINT pk_tripulante PRIMARY KEY (id),
    CONSTRAINT fk_tripulante_companhia FOREIGN KEY (companhia_id) REFERENCES companhia_aerea(id)
);

-- =============================================================================
-- ENTIDADES FRACAS
-- =============================================================================

-- Terminal (fraca de Aeroporto) -----------------------------------------------
CREATE TABLE terminal (
    aeroporto_iata   CHAR(3)     NOT NULL,
    numero_terminal  INTEGER     NOT NULL,
    nome             VARCHAR(40) NOT NULL DEFAULT 'Terminal Principal', -- [Q4] DEFAULT
    CONSTRAINT pk_terminal PRIMARY KEY (aeroporto_iata, numero_terminal),
    CONSTRAINT fk_terminal_aeroporto FOREIGN KEY (aeroporto_iata) REFERENCES aeroporto(codigo_iata)
);

-- Portao (fraca de Terminal — fraca aninhada) ---------------------------------
CREATE TABLE portao (
    aeroporto_iata   CHAR(3) NOT NULL,
    numero_terminal  INTEGER NOT NULL,
    numero_portao    INTEGER NOT NULL,
    CONSTRAINT pk_portao PRIMARY KEY (aeroporto_iata, numero_terminal, numero_portao),
    CONSTRAINT fk_portao_terminal FOREIGN KEY (aeroporto_iata, numero_terminal)
        REFERENCES terminal(aeroporto_iata, numero_terminal)
);

-- Assento (fraca de Aeronave) -------------------------------------------------
CREATE TABLE assento (
    aeronave_prefixo  VARCHAR(7)  NOT NULL,
    numero_assento    VARCHAR(4)  NOT NULL,                   -- ex.: 12A
    classe            VARCHAR(12) NOT NULL DEFAULT 'ECONOMICA' -- [Q4] DEFAULT
                      CHECK (classe IN ('ECONOMICA','EXECUTIVA','PRIMEIRA')), -- [Q4] CHECK em lista
    CONSTRAINT pk_assento PRIMARY KEY (aeronave_prefixo, numero_assento),
    CONSTRAINT fk_assento_aeronave FOREIGN KEY (aeronave_prefixo) REFERENCES aeronave(prefixo)
);

-- Dependente (fraca de Tripulante) --------------------------------------------
CREATE TABLE dependente (
    tripulante_id    INTEGER      NOT NULL,
    nome             VARCHAR(120) NOT NULL,
    parentesco       VARCHAR(20)  NOT NULL
                     CHECK (parentesco IN ('CONJUGE','FILHO','FILHA','PAI','MAE')), -- [Q4] CHECK em lista
    data_nascimento  DATE         NOT NULL,
    CONSTRAINT pk_dependente PRIMARY KEY (tripulante_id, nome),
    CONSTRAINT fk_dependente_tripulante FOREIGN KEY (tripulante_id) REFERENCES tripulante(id)
);

-- Ocorrência de Voo (fraca de VooProgramado) ----------------------------------
CREATE TABLE ocorrencia_voo (
    voo_programado_id  INTEGER     NOT NULL,
    data               DATE        NOT NULL,
    aeronave_prefixo   VARCHAR(7)  NOT NULL,
    -- portão de embarque (FK composta para a fraca portao); opcional
    portao_aeroporto   CHAR(3),
    portao_terminal    INTEGER,
    portao_numero      INTEGER,
    status             VARCHAR(12) NOT NULL DEFAULT 'PROGRAMADO'  -- [Q4] DEFAULT
                       CHECK (status IN ('PROGRAMADO','EMBARCANDO','DECOLOU','POUSOU','CANCELADO')), -- [Q4] CHECK em lista
    CONSTRAINT pk_ocorrencia_voo PRIMARY KEY (voo_programado_id, data),
    CONSTRAINT fk_ocorrencia_voo_programado FOREIGN KEY (voo_programado_id) REFERENCES voo_programado(id),
    CONSTRAINT fk_ocorrencia_voo_aeronave FOREIGN KEY (aeronave_prefixo) REFERENCES aeronave(prefixo),
    CONSTRAINT fk_ocorrencia_voo_portao FOREIGN KEY (portao_aeroporto, portao_terminal, portao_numero)
        REFERENCES portao(aeroporto_iata, numero_terminal, numero_portao)
);

-- =============================================================================
-- TABELAS ASSOCIATIVAS (relacionamentos N:N com atributos)
-- =============================================================================

-- Bilhete = Passageiro x OcorrenciaVoo ----------------------------------------
CREATE TABLE bilhete (
    id               SERIAL,
    passageiro_id    INTEGER      NOT NULL,
    voo_programado_id INTEGER     NOT NULL,
    data_ocorrencia  DATE         NOT NULL,
    numero_assento   VARCHAR(4)   NOT NULL,
    classe           VARCHAR(12)  NOT NULL DEFAULT 'ECONOMICA'  -- [Q4] DEFAULT
                     CHECK (classe IN ('ECONOMICA','EXECUTIVA','PRIMEIRA')), -- [Q4] CHECK em lista
    preco            NUMERIC(10,2) NOT NULL CHECK (preco > 0),   -- [Q4] CHECK
    status_checkin   BOOLEAN      NOT NULL DEFAULT FALSE,        -- [Q4] DEFAULT
    CONSTRAINT pk_bilhete PRIMARY KEY (id),
    CONSTRAINT fk_bilhete_passageiro FOREIGN KEY (passageiro_id) REFERENCES passageiro(id),
    CONSTRAINT fk_bilhete_ocorrencia FOREIGN KEY (voo_programado_id, data_ocorrencia)
        REFERENCES ocorrencia_voo(voo_programado_id, data),
    -- não pode haver dois bilhetes no mesmo assento da mesma ocorrência
    CONSTRAINT uq_assento_ocorrencia
        UNIQUE (voo_programado_id, data_ocorrencia, numero_assento) -- [Q4] UNIQUE composta
);

-- Bagagem (fraca de Bilhete) --------------------------------------------------
CREATE TABLE bagagem (
    bilhete_id     INTEGER       NOT NULL,
    numero_volume  INTEGER       NOT NULL,
    peso_kg        NUMERIC(5,2)  NOT NULL CHECK (peso_kg > 0 AND peso_kg <= 32), -- [Q4] CHECK
    CONSTRAINT pk_bagagem PRIMARY KEY (bilhete_id, numero_volume),
    CONSTRAINT fk_bagagem_bilhete FOREIGN KEY (bilhete_id) REFERENCES bilhete(id)
);

-- Escalacao = Tripulante x OcorrenciaVoo (relacionamento COM ATRIBUTOS) --------
CREATE TABLE escalacao (
    tripulante_id      INTEGER     NOT NULL,
    voo_programado_id  INTEGER     NOT NULL,
    data_ocorrencia    DATE        NOT NULL,
    funcao_no_voo      VARCHAR(20) NOT NULL
                       CHECK (funcao_no_voo IN ('COMANDANTE','COPILOTO','COMISSARIO')), -- [Q4] CHECK em lista
    horario_apresentacao TIME      NOT NULL,
    CONSTRAINT pk_escalacao PRIMARY KEY (tripulante_id, voo_programado_id, data_ocorrencia),
    CONSTRAINT fk_escalacao_tripulante FOREIGN KEY (tripulante_id) REFERENCES tripulante(id),
    CONSTRAINT fk_escalacao_ocorrencia FOREIGN KEY (voo_programado_id, data_ocorrencia)
        REFERENCES ocorrencia_voo(voo_programado_id, data)
);

-- AtendimentoCia = CompanhiaAerea x Aeroporto ---------------------------------
CREATE TABLE atendimento_cia (
    companhia_id          INTEGER NOT NULL,
    aeroporto_iata        CHAR(3) NOT NULL,
    terminal_base         INTEGER NOT NULL DEFAULT 1,            -- [Q4] DEFAULT
    data_inicio_operacao  DATE    NOT NULL DEFAULT CURRENT_DATE, -- [Q4] DEFAULT
    CONSTRAINT pk_atendimento_cia PRIMARY KEY (companhia_id, aeroporto_iata),
    CONSTRAINT fk_atendimento_cia_companhia FOREIGN KEY (companhia_id) REFERENCES companhia_aerea(id),
    CONSTRAINT fk_atendimento_cia_aeroporto FOREIGN KEY (aeroporto_iata) REFERENCES aeroporto(codigo_iata)
);

