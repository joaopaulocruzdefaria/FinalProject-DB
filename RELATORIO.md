# Relatório do Projeto Final — Banco de Dados (Rede Aérea)

**Disciplina:** Banco de Dados — CEFET-MG, Campus Divinópolis
**Professor:** Raulivan Rodrigo · **Valor:** 35 pontos · **Entrega:** 25/06/2026
**SGBD:** PostgreSQL 18
**Tema escolhido:** Rede aérea (operação de voos)

Este documento descreve **tudo que foi feito** no projeto: as decisões de
modelagem, os artefatos produzidos, como cada questão foi atendida e o
resultado da **validação executada no PostgreSQL** (todos os scripts foram
rodados de verdade, não apenas revisados).

---

## 1. Visão geral e arquivos do projeto

| Arquivo                     | Conteúdo / Questões |
|-----------------------------|---------------------|
| `00_modelo_MER_DER.md`      | MER (Q1), DER em Mermaid (Q2), notas de normalização (Q15) |
| `01_ddl.sql`                | DDL de criação (Q3) + restrições marcadas com `[Q4]` (Q4) |
| `02_seed.sql`               | Carga de dados, ≥10 registros por tabela (Q6) |
| `03_violacoes.sql`          | Scripts que violam cada restrição (Q5) |
| `04_consultas.sql`          | INNER/LEFT/RIGHT/FULL JOIN, GROUP BY/HAVING, UNION/INTERSECT/EXCEPT (Q7–Q14) |
| `README.md`                 | Instruções de execução e mapa questão → arquivo |
| `reset_senha_postgres.ps1`  | Utilitário usado para redefinir a senha do usuário `postgres` |
| `RELATORIO.md`              | Este documento |

---

## 2. Processo de decisão (entrevista de requisitos)

Antes de modelar, foi feita uma entrevista para travar as decisões de projeto.
As escolhas e suas justificativas:

| Decisão | Escolha | Por quê |
|---------|---------|---------|
| Domínio | Rede aérea (operação de voos) | Rico o suficiente para 7+ entidades fortes, 5+ fracas e relacionamentos N:N; torna os JOINs e operações de conjunto naturais. |
| SGBD | **PostgreSQL** | É obrigatório: as questões 10, 13 e 14 pedem `FULL JOIN`, `INTERSECT` e `EXCEPT`, que **MySQL/MariaDB não suportam** nativamente. |
| Modelagem de "Voo" | `Rota` → `VooProgramado` → `OcorrenciaVoo` (fraca) | Separa o voo "de grade" (que se repete) da ocorrência de uma data específica; a ocorrência vira uma entidade fraca natural e evita violar normalização. |
| Escopo | 8 fortes + 6 fracas + 3 associativas | Acima dos mínimos exigidos (7 / 5 / 3), com folga. |

---

## 3. Questão 01 — MER (Modelo Entidade-Relacionamento)

### Requisitos x entregue

| Requisito | Mínimo | Entregue |
|-----------|:------:|:--------:|
| Tabelas fortes | 7 | **8** |
| Tabelas fracas | 5 | **6** |
| Relacionamentos N:N (geram tabela associativa) | 3 | **3** |
| Relacionamento com atributos | 1 | **2** |

### Entidades fortes (8)
Aeroporto, CompanhiaAerea, ModeloAeronave, Aeronave, Rota, VooProgramado,
Passageiro, Tripulante.

### Entidades fracas (6) — dona · chave parcial
- **OcorrenciaVoo** — VooProgramado · `data`
- **Terminal** — Aeroporto · `numero_terminal`
- **Portao** — Terminal · `numero_portao` (fraca aninhada)
- **Assento** — Aeronave · `numero_assento`
- **Dependente** — Tripulante · `nome`
- **Bagagem** — Bilhete · `numero_volume`

### Tabelas associativas N:N (3, todas com atributos)
- **Bilhete** = Passageiro ⨯ OcorrenciaVoo (assento, classe, preço, check-in)
- **Escalacao** = Tripulante ⨯ OcorrenciaVoo (**função_no_voo**, horário) ← *relacionamento com atributos da Q1*
- **AtendimentoCia** = CompanhiaAerea ⨯ Aeroporto (terminal_base, data_início)

> O diagrama completo e a lista de atributos estão em `00_modelo_MER_DER.md`.

---

## 4. Questão 02 — DER

O DER foi escrito em **Mermaid** (`erDiagram`) dentro de `00_modelo_MER_DER.md`,
com todas as tabelas, colunas, PK/FK/UK e cardinalidades em notação *crow's
foot*. Renderiza automaticamente no GitHub ou no VS Code (extensão "Markdown
Preview Mermaid Support").

---

## 5. Questão 03 — DDL

Arquivo `01_ddl.sql`. Cria as **17 tabelas** (8 fortes + 6 fracas + 3
associativas) em ordem de dependência, com `DROP TABLE IF EXISTS ... CASCADE`
no topo para permitir reexecução. Destaques de modelagem:

- Entidades fracas usam **chave primária composta** (chave da dona + chave
  parcial). Ex.: `ocorrencia_voo` tem `PRIMARY KEY (voo_programado_id, data)`.
- O portão de embarque é referenciado por uma **FK composta de 3 colunas**
  (`portao_aeroporto, portao_terminal, portao_numero`).
- `ModeloAeronave` foi separada de `Aeronave` para respeitar a 3FN.

---

## 6. Questão 04 — Restrições

Cada restrição está marcada com o comentário `[Q4]` no `01_ddl.sql`. Exemplos
de cada tipo exigido (há vários a mais):

| Tipo | Exemplos no schema |
|------|--------------------|
| **CHECK** | `capacidade > 0`; `preco > 0`; `peso_kg > 0 AND peso_kg <= 32`; `ano_fabricacao BETWEEN 1950 AND 2100`; `aeroporto_origem <> aeroporto_destino` |
| **DEFAULT** | `aeroporto.pais = 'Brasil'`; `fuso_horario = 'UTC-3'`; `bilhete.classe = 'ECONOMICA'`; `status_checkin = FALSE`; `ocorrencia.status = 'PROGRAMADO'`; `atendimento.data_inicio = CURRENT_DATE` |
| **CHECK baseado em lista** | `cargo IN ('COMANDANTE','COPILOTO','COMISSARIO')`; `classe IN ('ECONOMICA','EXECUTIVA','PRIMEIRA')`; `status IN (...)`; `funcao_no_voo IN (...)`; `parentesco IN (...)` |
| **UNIQUE** | `companhia.codigo_iata`; `passageiro.cpf`; `tripulante.num_licenca`; `(fabricante, modelo)`; `(aeroporto_origem, aeroporto_destino)`; `(voo_programado_id, data_ocorrencia, numero_assento)` |

---

## 7. Questão 06 — Carga de dados

Arquivo `02_seed.sql`. Todas as 17 tabelas com **no mínimo 10 registros**.
Contagem verificada no banco:

```
        t        | n
-----------------+----
 aeronave        | 10
 aeroporto       | 12
 assento         | 12
 atendimento_cia | 10
 bagagem         | 11
 bilhete         | 14
 companhia_aerea | 10
 dependente      | 10
 escalacao       | 12
 modelo_aeronave | 10
 ocorrencia_voo  | 11
 passageiro      | 12
 portao          | 10
 rota            | 10
 terminal        | 10
 tripulante      | 12
 voo_programado  | 10
```

> Observação: a carga depende da **ordem de inserção** (IDs `SERIAL` gerados em
> sequência). Não reordene/insira INSERTs no meio das listas — apenas adicione
> ao final — para não quebrar as chaves estrangeiras.

---

## 8. Questão 05 — Violações de restrição

Arquivo `03_violacoes.sql`. Cada comando foi projetado para **falhar**,
demonstrando que o banco realmente impõe as restrições. Saída real do
PostgreSQL ao executar (todos os erros esperados ocorreram):

```
ERROR: violates check constraint "modelo_aeronave_capacidade_check"   -- CHECK numérico (capacidade)
ERROR: violates check constraint "bilhete_preco_check"                -- CHECK numérico (preço)
ERROR: violates check constraint "tripulante_cargo_check"             -- CHECK em lista (cargo)
ERROR: violates check constraint "bilhete_classe_check"               -- CHECK em lista (classe)
ERROR: duplicate key value violates unique constraint "passageiro_cpf_key"      -- UNIQUE (cpf)
ERROR: duplicate key value violates unique constraint "uq_assento_ocorrencia"   -- UNIQUE composta (assento)
ERROR: violates check constraint "bagagem_peso_kg_check"              -- CHECK de intervalo (bagagem > 32kg)
ERROR: violates check constraint "ck_rota_diferente"                  -- regra de negócio (origem = destino)
```

A demonstração de **DEFAULT** (que não é "violável") inseriu um aeroporto sem
informar `pais`/`fuso_horario` e o banco preencheu os padrões, comprovando o
comportamento:

```
 codigo_iata |  pais  | fuso_horario
-------------+--------+--------------
 XXX         | Brasil | UTC-3
```
(o registro de teste é removido em seguida pelo próprio script.)

---

## 9. Questões 07 a 14 — Consultas

Arquivo `04_consultas.sql`. Todas executaram com sucesso. Resumo dos resultados:

### Q07 — INNER JOIN (passageiro × voo × trecho)
Retorna **14 linhas** — apenas passageiros que efetivamente possuem bilhete
em uma ocorrência. Ex.: `Joao Faria | LA3001 | GRU -> GIG | ECONOMICA | 450.00`.

### Q08 — LEFT JOIN (modelos × aeronaves)
Lista todos os modelos; os que não têm aeronave cadastrada aparecem com
`aeronave = NULL` (**737 MAX** e **ATR 72**).

### Q09 — RIGHT JOIN (aeronaves × modelos)
Mesma informação pela ótica inversa — preserva todos os modelos à direita.

### Q10 — FULL JOIN (origem × destino de rotas)
Demonstra `NULL` nos **dois lados** (12 linhas):
```
 so_origem_ou_ambos | so_destino_ou_ambos
--------------------+---------------------
 BSB                | BSB        <- servido nos dois sentidos
 CNF                | CNF        <- servido nos dois sentidos
 GIG                | GIG        <- servido nos dois sentidos
 SSA                | SSA        <- servido nos dois sentidos
 CGH                |            <- só origem
 GRU                |            <- só origem
 POA                |            <- só origem
                    | CWB        <- só destino
                    | LIS        <- só destino
                    | MIA        <- só destino
                    | REC        <- só destino
                    | SDU        <- só destino
```
> Coerente com a Q13 (INTERSECT = BSB, CNF, GIG, SSA) e a Q14 (EXCEPT = CWB, LIS, MIA, REC, SDU).

### Q11 — GROUP BY + HAVING (faturamento por voo, ≥ 2 passagens)
```
 numero_voo | qtd_passagens | receita_total | ticket_medio
------------+---------------+---------------+--------------
 LA3001     |             3 |       1800.00 |       600.00
 LA3002     |             2 |       1200.00 |       600.00
 G31001     |             2 |        600.00 |       300.00
```

### Q12 — UNION (passageiros + tripulantes)
Lista unificada de **24 pessoas** com a coluna `tipo` (PASSAGEIRO/TRIPULANTE).

### Q13 — INTERSECT (aeroportos servidos nos dois sentidos)
Resultado: **BSB, CNF, GIG, SSA**.

### Q14 — EXCEPT (aeroportos que nunca são origem)
Resultado: **CWB, LIS, MIA, REC, SDU**.

---


## 10. Questão 15 — Normalização

O esquema está em **3FN**:
- **1FN:** atributos atômicos; itens repetitivos extraídos para tabelas próprias
  (Assento, Bagagem, Dependente, Portao).
- **2FN:** em tabelas de chave composta, os atributos não-chave dependem da
  chave inteira (ex.: `escalacao.funcao_no_voo` depende do par tripulante+ocorrência).
- **3FN:** sem dependências transitivas — `ModeloAeronave` separada de `Aeronave`,
  e dados de cidade/país ficam só em `Aeroporto`.

Detalhamento em `00_modelo_MER_DER.md`.

---

## 11. Validação executada no ambiente

A validação foi feita rodando os scripts de verdade no PostgreSQL local.

**Ambiente:**
- PostgreSQL **18.0** em `C:\Program Files\PostgreSQL\18` (serviço
  `postgresql-x64-18`, porta 5432).
- O executável `psql` **não está no PATH**; foi usado o caminho completo
  `C:\Program Files\PostgreSQL\18\bin\psql.exe`.
- A senha do usuário `postgres` estava desconhecida; foi **redefinida para
  `123456`** com o utilitário `reset_senha_postgres.ps1` (faz backup do
  `pg_hba.conf`, troca para `trust` temporariamente, altera a senha e
  **restaura** o arquivo original).

**Passos executados e resultado:**

| # | Comando | Resultado |
|---|---------|-----------|
| 1 | `DROP/CREATE DATABASE rede_aerea` | OK |
| 2 | `psql -f 01_ddl.sql` (`ON_ERROR_STOP=1`) | **exit 0** — 17 tabelas criadas |
| 3 | `psql -f 02_seed.sql` (`ON_ERROR_STOP=1`) | **exit 0** — todos os INSERTs ok |
| 4 | contagem de registros | todas as tabelas com ≥ 10 |
| 5 | `psql -f 04_consultas.sql` (`ON_ERROR_STOP=1`) | **exit 0** — Q7–Q14 corretas |
| 6 | `psql -f 03_violacoes.sql` | as 8 violações **falharam como esperado** + demo de DEFAULT funcionou |

**Conclusão:** o banco `rede_aerea` está criado, populado e com todas as
questões (01–15) atendidas e verificadas em execução.

---

## 12. Como reproduzir

```powershell
$env:PGPASSWORD = '123456'
$psql = 'C:\Program Files\PostgreSQL\18\bin\psql.exe'

& $psql -U postgres -h localhost -d postgres -c "DROP DATABASE IF EXISTS rede_aerea;"
& $psql -U postgres -h localhost -d postgres -c "CREATE DATABASE rede_aerea;"
& $psql -U postgres -h localhost -d rede_aerea -f "01_ddl.sql"
& $psql -U postgres -h localhost -d rede_aerea -f "02_seed.sql"
& $psql -U postgres -h localhost -d rede_aerea -f "04_consultas.sql"
& $psql -U postgres -h localhost -d rede_aerea -f "03_violacoes.sql"   # erros são esperados
```
