# Projeto Final — Banco de Dados (Rede Aérea)

Banco de dados de uma rede aérea (voos, companhias, aeronaves, tripulação,
passageiros, bilhetes, bagagem). SGBD: **PostgreSQL**.

## Arquivos e mapa das questões

| Arquivo                 | Questões atendidas |
|-------------------------|--------------------|
| `00_modelo_MER_DER.md`  | Q01 (MER), Q02 (DER), Q15 (normalização) |
| `01_ddl.sql`            | Q03 (DDL), Q04 (restrições CHECK / DEFAULT / CHECK em lista / UNIQUE) |
| `02_seed.sql`           | Q06 (≥10 registros por tabela) |
| `03_violacoes.sql`      | Q05 (violações de cada restrição) |
| `04_consultas.sql`      | Q07 INNER, Q08 LEFT, Q09 RIGHT, Q10 FULL JOIN, Q11 GROUP BY/HAVING, Q12 UNION, Q13 INTERSECT, Q14 EXCEPT |

## Como rodar

Ordem obrigatória: DDL → seed → (consultas | violações).

```bash
# criar um banco
createdb rede_aerea

# 1. estrutura + restrições
psql -d rede_aerea -f 01_ddl.sql
# 2. dados
psql -d rede_aerea -f 02_seed.sql
# 3. consultas (Q07-Q14)
psql -d rede_aerea -f 04_consultas.sql

# 4. violações (Q05) — rode UMA por vez para ver cada erro
#    (cada comando do arquivo é projetado para FALHAR, exceto a demo de DEFAULT)
psql -d rede_aerea -f 03_violacoes.sql
```

> O `01_ddl.sql` faz `DROP TABLE IF EXISTS` no início, então pode ser
> reexecutado do zero quantas vezes quiser.

## Visualizar o diagrama (DER)

O `00_modelo_MER_DER.md` contém o DER em **Mermaid**. Ele renderiza
automaticamente no GitHub ou no VS Code (extensão "Markdown Preview Mermaid
Support").

## Resumo do modelo

- **8 entidades fortes:** Aeroporto, CompanhiaAerea, ModeloAeronave, Aeronave,
  Rota, VooProgramado, Passageiro, Tripulante
- **6 entidades fracas:** OcorrenciaVoo, Terminal, Portao, Assento, Dependente,
  Bagagem
- **3 tabelas associativas (N:N, todas com atributos):** Bilhete, Escalacao,
  AtendimentoCia
- **Relacionamento com atributos:** Escalacao (`funcao_no_voo`,
  `horario_apresentacao`)
