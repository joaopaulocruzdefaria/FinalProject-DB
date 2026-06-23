# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

Final project (35 pts) for the **Banco de Dados** course — Curso Técnico em Informática, CEFET-MG Campus Divinópolis (Prof. Raulivan Rodrigo). Due **25/06/2026**.

The only source-of-truth file currently present is `propostaDeTrabalhoDoProfessor.pdf` — the assignment spec, written in Portuguese. Everything to be produced is a single, self-contained relational database project: an ER model, its DER, the DDL, and a battery of DML/query scripts. There is no application code, build system, or test runner — deliverables are SQL scripts plus the diagrams.

Work and write code/comments in **Portuguese (pt-BR)** to match the course context unless asked otherwise.

## Deliverables (graded checklist)

The 15 questions decompose into these artifacts. Treat each as a requirement to satisfy, not a suggestion:

1. **MER** (Q1, 7 pts) — conceptual model with at minimum: **7 strong entities**, **5 weak entities**, **3 relationships that resolve to associative tables** (many-to-many), and **1 relationship carrying its own attributes**. These counts are hard minimums and are individually graded.
2. **DER** (Q2, 5 pts) — logical/physical diagram derived from the MER.
3. **DDL** (Q3, 5 pts) — `CREATE` statements implementing the DER exactly.
4. **Constraints** (Q4, 2 pts) — the schema must include at least one of each: `CHECK`, `DEFAULT`, list-based `CHECK` (e.g. `CHECK (col IN (...))`), and `UNIQUE`.
5. **Constraint-violation DML** (Q5, 2 pts) — scripts that deliberately violate each constraint from Q4, to demonstrate enforcement.
6. **Seed data** (Q6, 2 pts) — every table must hold **≥ 10 rows**, via DML scripts.
7. **Queries** (Q7–Q14, 1 pt each) — one practical example each of: `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `FULL JOIN`, `UNION`, `INTERSECT`, `EXCEPT`.
8. **Aggregation** (Q11, 2 pts) — `GROUP BY` + `HAVING` example.
9. **Normalization** (Q15, 3 pts) — schema must not violate normalization rules (target at least 3NF).

## Important consequences for design

- **DBMS choice matters**: `INTERSECT`, `EXCEPT`, and `FULL JOIN` (Q10/Q13/Q14) are **not supported by MySQL/MariaDB**. Use **PostgreSQL** (or another DBMS supporting all four) unless the user has chosen otherwise — confirm before generating DDL if it's unspecified.
- The MER entity counts and the query list are a coupled design problem: pick a domain rich enough that the 7+5 entities, 3 associative tables, and the attributed relationship all arise naturally, AND that the JOIN/set-operation queries have meaningful real-world phrasing. Design the schema with the query list in mind so Q7–Q14 aren't contrived.
- Keep the four Q4 constraint types traceable — note in the DDL which column satisfies which requirement, since each is graded separately.

## Chosen design (LOCKED with the user)

- **Domain:** air network / flight operations. **DBMS:** PostgreSQL. Work in pt-BR.
- **Flight modeling:** `Rota` → `VooProgramado` → `OcorrenciaVoo` (weak). A bilhete/escalação binds to the occurrence, not the schedule.
- **8 strong:** Aeroporto, CompanhiaAerea, ModeloAeronave, Aeronave, Rota, VooProgramado, Passageiro, Tripulante.
- **6 weak (owner · partial key):** OcorrenciaVoo (VooProgramado · data), Terminal (Aeroporto · numero), Portao (Terminal · numero — nested weak), Assento (Aeronave · numero), Dependente (Tripulante · nome), Bagagem (Bilhete · numero_volume).
- **3 associative N:N (all carry attributes):** Bilhete (Passageiro⨯OcorrenciaVoo), Escalacao (Tripulante⨯OcorrenciaVoo — the graded "relationship with attributes"), AtendimentoCia (CompanhiaAerea⨯Aeroporto).

## File layout (deliverables — all present)

- `00_modelo_MER_DER.md` — Q1 MER, Q2 DER (Mermaid erDiagram), Q15 normalization notes
- `01_ddl.sql` — Q3 schema + Q4 constraints (each constraint tagged `[Q4]` in comments)
- `02_seed.sql` — Q6, ≥10 rows/table; relies on SERIAL insertion order for FK ids
- `03_violacoes.sql` — Q5, one deliberately-failing statement per constraint type
- `04_consultas.sql` — Q7–Q14 (each query block headed by its question number)
- `README.md` — run order + question→file map

## Gotchas when editing the SQL

- Seed FKs reference auto-generated SERIAL ids by **insertion order** (companhia 1–10, modelo 1–10, rota 1–10, voo 1–10, etc.). Reordering or adding INSERTs mid-list shifts ids and breaks downstream FKs — append, don't insert.
- `ocorrencia_voo` and the associative tables use **composite FKs** (e.g. `(voo_programado_id, data)`); the gate is a 3-column nullable FK to `portao`.
- **Validated by real execution** on PostgreSQL 18 (local, db `rede_aerea`): `01_ddl.sql` and `02_seed.sql` run with exit 0, all 17 tables hold ≥10 rows, every query in `04_consultas.sql` runs, and each statement in `03_violacoes.sql` fails as intended (the DEFAULT block is a demo, not a violation). Re-validate with `psql` (full path `C:\Program Files\PostgreSQL\18\bin\psql.exe`; `PGPASSWORD=123456`) running 01→02→04→03 in order.
