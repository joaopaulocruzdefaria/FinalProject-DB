-- =============================================================================
-- Questões 07 a 14: consultas de aplicação prática.
-- Rode DEPOIS de 01_ddl.sql e 02_seed.sql.
-- Cada bloco está identificado pela questão correspondente.
-- =============================================================================


-- =============================================================================
-- QUESTÃO 07 — INNER JOIN
-- "Quem voou, em qual voo e em qual trecho." Só traz passageiros que de fato
-- têm bilhete em uma ocorrência (interseção das tabelas).
-- =============================================================================
SELECT p.nome              AS passageiro,
       vp.numero_voo,
       o.codigo_iata || ' -> ' || d.codigo_iata AS trecho,
       b.data_ocorrencia,
       b.classe,
       b.preco
FROM bilhete b
INNER JOIN passageiro     p  ON p.id  = b.passageiro_id
INNER JOIN voo_programado vp ON vp.id = b.voo_programado_id
INNER JOIN rota           r  ON r.id  = vp.rota_id
INNER JOIN aeroporto      o  ON o.codigo_iata = r.aeroporto_origem
INNER JOIN aeroporto      d  ON d.codigo_iata = r.aeroporto_destino
ORDER BY b.data_ocorrencia, vp.numero_voo;


-- =============================================================================
-- QUESTÃO 08 — LEFT JOIN
-- Todos os modelos de aeronave e, quando houver, as aeronaves daquele modelo.
-- Modelos SEM aeronave cadastrada aparecem com NULL (não some da listagem).
-- =============================================================================
SELECT m.fabricante,
       m.modelo,
       m.capacidade,
       a.prefixo            AS aeronave   -- NULL quando o modelo não tem aeronave
FROM modelo_aeronave m
LEFT JOIN aeronave a ON a.modelo_id = m.id
ORDER BY m.fabricante, m.modelo;


-- =============================================================================
-- QUESTÃO 09 — RIGHT JOIN
-- Mesma ideia da Q08, mas pela ótica da aeronave: toda linha de modelo é
-- preservada à direita do JOIN. Modelos sem aeronave aparecem com prefixo NULL.
-- =============================================================================
SELECT a.prefixo            AS aeronave,  -- NULL quando o modelo não tem aeronave
       m.fabricante,
       m.modelo
FROM aeronave a
RIGHT JOIN modelo_aeronave m ON a.modelo_id = m.id
ORDER BY m.fabricante, m.modelo;


-- =============================================================================
-- QUESTÃO 10 — FULL JOIN (FULL OUTER JOIN)
-- Compara os aeroportos usados como ORIGEM com os usados como DESTINO de rotas.
-- - linha só com origem  -> aeroporto que só manda voos (nunca recebe)
-- - linha só com destino -> aeroporto que só recebe voos (nunca origina)
-- - ambos preenchidos     -> aeroporto servido nos dois sentidos
-- Demonstra NULL nos DOIS lados do JOIN.
-- =============================================================================
SELECT o.cod  AS so_origem_ou_ambos,
       d.cod  AS so_destino_ou_ambos
FROM (SELECT DISTINCT aeroporto_origem  AS cod FROM rota) o
FULL OUTER JOIN
     (SELECT DISTINCT aeroporto_destino AS cod FROM rota) d
  ON o.cod = d.cod
ORDER BY o.cod NULLS LAST, d.cod NULLS LAST;


-- =============================================================================
-- QUESTÃO 11 — GROUP BY + HAVING
-- Faturamento e quantidade de passagens por voo, considerando apenas os voos
-- que venderam 2 ou mais passagens (filtro de grupo com HAVING).
-- =============================================================================
SELECT vp.numero_voo,
       COUNT(b.id)   AS qtd_passagens,
       SUM(b.preco)  AS receita_total,
       ROUND(AVG(b.preco), 2) AS ticket_medio
FROM bilhete b
JOIN voo_programado vp ON vp.id = b.voo_programado_id
GROUP BY vp.numero_voo
HAVING COUNT(b.id) >= 2
ORDER BY receita_total DESC;


-- =============================================================================
-- QUESTÃO 12 — UNION
-- Lista unificada de pessoas ligadas à operação (passageiros + tripulantes)
-- num único resultado. UNION remove duplicatas automaticamente.
-- =============================================================================
SELECT nome, 'PASSAGEIRO' AS tipo FROM passageiro
UNION
SELECT nome, 'TRIPULANTE' AS tipo FROM tripulante
ORDER BY nome;


-- =============================================================================
-- QUESTÃO 13 — INTERSECT
-- Aeroportos que aparecem TANTO como origem QUANTO como destino de alguma rota
-- (ou seja, são servidos nos dois sentidos).
-- =============================================================================
SELECT aeroporto_origem  AS aeroporto FROM rota
INTERSECT
SELECT aeroporto_destino AS aeroporto FROM rota
ORDER BY aeroporto;


-- =============================================================================
-- QUESTÃO 14 — EXCEPT
-- Aeroportos cadastrados que NUNCA são origem de uma rota (estão no cadastro,
-- mas nenhuma rota parte deles).
-- =============================================================================
SELECT codigo_iata AS aeroporto FROM aeroporto
EXCEPT
SELECT aeroporto_origem FROM rota
ORDER BY aeroporto;
