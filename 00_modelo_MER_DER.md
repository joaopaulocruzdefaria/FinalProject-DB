# Modelo do Banco de Dados — Rede Aérea

Projeto Final de Banco de Dados — CEFET-MG Divinópolis
SGBD alvo: **PostgreSQL**

Este documento responde às **Questões 01 (MER)** e **02 (DER)**.

---

## Questão 01 — MER (Modelo Entidade-Relacionamento)

### Resumo dos requisitos atendidos

| Requisito                                   | Mínimo | No modelo | Itens |
|---------------------------------------------|:------:|:---------:|-------|
| Entidades fortes                            |   7    |   **8**   | Aeroporto, CompanhiaAerea, ModeloAeronave, Aeronave, Rota, VooProgramado, Passageiro, Tripulante |
| Entidades fracas                            |   5    |   **6**   | OcorrenciaVoo, Terminal, Portao, Assento, Dependente, Bagagem |
| Relacionamentos que geram tabela associativa (N:N) | 3 | **3** | Bilhete, Escalacao, AtendimentoCia |
| Relacionamento com atributos                |   1    |   **2**   | Escalacao (função/horário), Bilhete (preço/classe/assento) |

### Diagrama Conceitual (MER)

```mermaid
graph TD
    %% Classes for styling
    classDef strongEntity fill:#e3f2fd,stroke:#1565c0,stroke-width:2px,color:#0d47a1,font-weight:bold;
    classDef weakEntity fill:#ede7f6,stroke:#5e35b1,stroke-width:2px,color:#4a148c,font-weight:bold;
    classDef relationship fill:#f1f8e9,stroke:#558b2f,stroke-width:2px,color:#1b5e20;
    classDef associative fill:#fff3e0,stroke:#ef6c00,stroke-width:2px,color:#e65100,font-weight:bold;

    %% Nodes
    AEROPORTO["Aeroporto"]:::strongEntity
    COMPANHIA["Companhia Aérea"]:::strongEntity
    MODELO["Modelo Aeronave"]:::strongEntity
    AERONAVE["Aeronave"]:::strongEntity
    ROTA["Rota"]:::strongEntity
    VOO_PROG["Voo Programado"]:::strongEntity
    PASSAGEIRO["Passageiro"]:::strongEntity
    TRIPULANTE["Tripulante"]:::strongEntity

    TERMINAL[["Terminal"]]:::weakEntity
    PORTAO[["Portão"]]:::weakEntity
    ASSENTO[["Assento"]]:::weakEntity
    DEPENDENTE[["Dependente"]]:::weakEntity
    OCORRENCIA[["Ocorrência Voo"]]:::weakEntity
    BAGAGEM[["Bagagem"]]:::weakEntity

    %% Relationships (Diamonds)
    R_ATEND{"AtendimentoCia"}:::associative
    R_ESC{"Escalação"}:::associative
    R_BIL{"Bilhete"}:::associative
    
    R_ORIG{"Origem"}:::relationship
    R_DEST{"Destino"}:::relationship
    R_POSS_TERM{"Possui"}:::relationship
    R_CONT_PORT{"Contém"}:::relationship
    R_OPERA_VOO{"Opera"}:::relationship
    R_EMP_TRIP{"Emprega"}:::relationship
    R_POSS_AERO{"Possui"}:::relationship
    R_TIPO_AERO{"É do tipo"}:::relationship
    R_TEM_ASS{"Tem"}:::relationship
    R_SEG_ROTA{"Segue"}:::relationship
    R_INST_VOO{"Instancia"}:::relationship
    R_EXEC_AERO{"Executa"}:::relationship
    R_EMB_PORT{"Embarca em"}:::relationship
    R_TEM_DEP{"Tem"}:::relationship
    R_DESP_BAG{"Despacha"}:::relationship

    %% Connections
    AEROPORTO ---|1..N| R_ATEND
    COMPANHIA ---|1..N| R_ATEND
    
    AEROPORTO ---|1| R_POSS_TERM
    R_POSS_TERM ---|N| TERMINAL
    
    TERMINAL ---|1| R_CONT_PORT
    R_CONT_PORT ---|N| PORTAO
    
    AEROPORTO ---|"1 (origem)"| R_ORIG
    R_ORIG ---|N| ROTA
    AEROPORTO ---|"1 (destino)"| R_DEST
    R_DEST ---|N| ROTA
    
    ROTA ---|1| R_SEG_ROTA
    R_SEG_ROTA ---|N| VOO_PROG
    
    COMPANHIA ---|1| R_OPERA_VOO
    R_OPERA_VOO ---|N| VOO_PROG
    
    COMPANHIA ---|1| R_EMP_TRIP
    R_EMP_TRIP ---|N| TRIPULANTE
    
    COMPANHIA ---|1| R_POSS_AERO
    R_POSS_AERO ---|N| AERONAVE
    
    MODELO ---|1| R_TIPO_AERO
    R_TIPO_AERO ---|N| AERONAVE
    
    AERONAVE ---|1| R_TEM_ASS
    R_TEM_ASS ---|N| ASSENTO
    
    VOO_PROG ---|1| R_INST_VOO
    R_INST_VOO ---|N| OCORRENCIA
    
    AERONAVE ---|N| R_EXEC_AERO
    R_EXEC_AERO ---|1| OCORRENCIA
    
    PORTAO ---|N| R_EMB_PORT
    R_EMB_PORT ---|1| OCORRENCIA
    
    TRIPULANTE ---|1| R_TEM_DEP
    R_TEM_DEP ---|N| DEPENDENTE
    
    TRIPULANTE ---|1..N| R_ESC
    OCORRENCIA ---|1..N| R_ESC
    
    PASSAGEIRO ---|1..N| R_BIL
    OCORRENCIA ---|1..N| R_BIL
    
    R_BIL ---|1| R_DESP_BAG
    R_DESP_BAG ---|N| BAGAGEM

### Entidades fortes

1. **Aeroporto** — `codigo_iata` (PK), nome, cidade, pais, fuso_horario
2. **CompanhiaAerea** — `id` (PK), nome, codigo_iata (UNIQUE), pais
3. **ModeloAeronave** — `id` (PK), fabricante, modelo, capacidade
4. **Aeronave** — `prefixo` (PK), modelo_id (FK), companhia_id (FK), ano_fabricacao
5. **Rota** — `id` (PK), aeroporto_origem (FK), aeroporto_destino (FK), distancia_km
6. **VooProgramado** — `id` (PK), numero_voo, rota_id (FK), companhia_id (FK), hora_partida, hora_chegada
7. **Passageiro** — `id` (PK), cpf (UNIQUE), nome, data_nascimento
8. **Tripulante** — `id` (PK), nome, cargo, num_licenca (UNIQUE), companhia_id (FK)

### Entidades fracas (chave parcial sublinhada na descrição)

1. **OcorrenciaVoo** — dona: *VooProgramado* · chave parcial: **data** · atributos: aeronave (FK), portão (FK), status
2. **Terminal** — dona: *Aeroporto* · chave parcial: **numero_terminal** · atributo: nome
3. **Portao** — dona: *Terminal* (fraca aninhada) · chave parcial: **numero_portao**
4. **Assento** — dona: *Aeronave* · chave parcial: **numero_assento** · atributo: classe
5. **Dependente** — dona: *Tripulante* · chave parcial: **nome** · atributos: parentesco, data_nascimento
6. **Bagagem** — dona: *Bilhete* · chave parcial: **numero_volume** · atributo: peso_kg

### Tabelas associativas (relacionamentos N:N) — todas com atributos

1. **Bilhete** = `Passageiro` ⨯ `OcorrenciaVoo`
   atributos: numero_assento, classe, preco, status_checkin
2. **Escalacao** = `Tripulante` ⨯ `OcorrenciaVoo`  ← *relacionamento com atributos (Q1)*
   atributos: funcao_no_voo, horario_apresentacao
3. **AtendimentoCia** = `CompanhiaAerea` ⨯ `Aeroporto`
   atributos: terminal_base, data_inicio_operacao

---

## Questão 02 — DER (Diagrama Entidade-Relacionamento)

Diagrama lógico (renderiza no GitHub/VS Code via Mermaid). Entidades fracas e
associativas estão comentadas. Cardinalidades em notação "crow's foot".

```mermaid
erDiagram
    AEROPORTO ||--o{ ROTA : "origem"
    AEROPORTO ||--o{ ROTA : "destino"
    AEROPORTO ||--o{ TERMINAL : possui
    TERMINAL  ||--o{ PORTAO : contem
    AEROPORTO ||--o{ ATENDIMENTO_CIA : atendido
    COMPANHIA_AEREA ||--o{ ATENDIMENTO_CIA : opera

    COMPANHIA_AEREA ||--o{ AERONAVE : possui
    COMPANHIA_AEREA ||--o{ VOO_PROGRAMADO : opera
    COMPANHIA_AEREA ||--o{ TRIPULANTE : emprega
    MODELO_AERONAVE ||--o{ AERONAVE : "e do tipo"
    AERONAVE ||--o{ ASSENTO : tem

    ROTA ||--o{ VOO_PROGRAMADO : segue
    VOO_PROGRAMADO ||--o{ OCORRENCIA_VOO : "instancia (fraca)"
    AERONAVE ||--o{ OCORRENCIA_VOO : "executa"
    PORTAO ||--o{ OCORRENCIA_VOO : "embarca em"

    PASSAGEIRO ||--o{ BILHETE : compra
    OCORRENCIA_VOO ||--o{ BILHETE : "vendido em"
    BILHETE ||--o{ BAGAGEM : "despacha (fraca)"

    TRIPULANTE ||--o{ ESCALACAO : escalado
    OCORRENCIA_VOO ||--o{ ESCALACAO : "tripulado por"
    TRIPULANTE ||--o{ DEPENDENTE : "tem (fraca)"

    AEROPORTO {
        char codigo_iata PK
        varchar nome
        varchar cidade
        varchar pais
        varchar fuso_horario
    }
    COMPANHIA_AEREA {
        serial id PK
        varchar nome
        char codigo_iata UK
        varchar pais
    }
    MODELO_AERONAVE {
        serial id PK
        varchar fabricante
        varchar modelo
        int capacidade
    }
    AERONAVE {
        varchar prefixo PK
        int modelo_id FK
        int companhia_id FK
        int ano_fabricacao
    }
    ROTA {
        serial id PK
        char aeroporto_origem FK
        char aeroporto_destino FK
        int distancia_km
    }
    VOO_PROGRAMADO {
        serial id PK
        varchar numero_voo
        int rota_id FK
        int companhia_id FK
        time hora_partida
        time hora_chegada
    }
    PASSAGEIRO {
        serial id PK
        char cpf UK
        varchar nome
        date data_nascimento
    }
    TRIPULANTE {
        serial id PK
        varchar nome
        varchar cargo
        varchar num_licenca UK
        int companhia_id FK
    }
    OCORRENCIA_VOO {
        int voo_programado_id PK,FK
        date data PK
        varchar aeronave_prefixo FK
        varchar status
    }
    TERMINAL {
        char aeroporto_iata PK,FK
        int numero_terminal PK
        varchar nome
    }
    PORTAO {
        char aeroporto_iata PK,FK
        int numero_terminal PK,FK
        int numero_portao PK
    }
    ASSENTO {
        varchar aeronave_prefixo PK,FK
        varchar numero_assento PK
        varchar classe
    }
    DEPENDENTE {
        int tripulante_id PK,FK
        varchar nome PK
        varchar parentesco
        date data_nascimento
    }
    BILHETE {
        serial id PK
        int passageiro_id FK
        int voo_programado_id FK
        date data_ocorrencia FK
        varchar numero_assento
        varchar classe
        numeric preco
        boolean status_checkin
    }
    BAGAGEM {
        int bilhete_id PK,FK
        int numero_volume PK
        numeric peso_kg
    }
    ESCALACAO {
        int tripulante_id PK,FK
        int voo_programado_id PK,FK
        date data_ocorrencia PK,FK
        varchar funcao_no_voo
        time horario_apresentacao
    }
    ATENDIMENTO_CIA {
        int companhia_id PK,FK
        char aeroporto_iata PK,FK
        int terminal_base
        date data_inicio_operacao
    }
```

---

## Questão 15 — Normalização

O modelo está em **3FN (Terceira Forma Normal)**:

- **1FN:** todos os atributos são atômicos; não há grupos repetitivos. Itens
  multivalorados/repetitivos foram extraídos para tabelas próprias
  (Assento, Bagagem, Dependente, Portao).
- **2FN:** toda tabela com chave composta tem os atributos não-chave dependendo
  da chave **inteira**. Ex.: em `escalacao`, `funcao_no_voo` depende do par
  (tripulante, ocorrência), não de parte dele.
- **3FN:** não há dependências transitivas. `ModeloAeronave` foi separado de
  `Aeronave` justamente para evitar que (fabricante, capacidade) dependessem
  transitivamente do prefixo via modelo. Cidade/país do aeroporto ficam em
  `Aeroporto`, e o voo só referencia o `codigo_iata`.

> **Nota sobre `bilhete.classe` / `bilhete.numero_assento`:** embora `assento`
> também tenha uma coluna `classe`, não há redundância que viole a 3FN. Em
> `assento`, `classe` é a categoria **física** da poltrona na aeronave; em
> `bilhete`, `classe` é a **tarifa vendida** ao passageiro, que pode diferir
> (ex.: poltrona executiva comercializada em promoção econômica). São fatos
> distintos, cada um dependente apenas da chave da sua própria tabela — não é
> uma dependência transitiva.
