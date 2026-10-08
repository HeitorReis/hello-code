# Contexto de backend — Hello Code 2026

## Persistência

O backend é o Supabase Postgres, definido em [supabase_hello_code.sql](../../../supabase_hello_code.sql). Não há servidor próprio, Edge Function ou sistema de usuários. A chave pública está configurada; os RPCs foram verificados no projeto remoto para gravação, edição, consulta, validação, totais e isolamento entre modos.

A tabela `public.hello_code_evaluations` contém:

| Campo | Comportamento |
| --- | --- |
| `id` | UUID gerado pelo banco |
| `evaluator_id` | Nome normalizado da jurada |
| `juror_name` | Nome de exibição |
| `team_id` | ID da equipe |
| `mode` | `test` ou `official` |
| `scores` | Sete inteiros, com máximos `[15,15,20,15,10,15,10]` |
| `comments` | Array com sete comentários |
| `total` | Coluna gerada pela soma das notas |
| `created_at`, `updated_at` | Datas geradas no banco; o RPC atualiza `updated_at` na edição |

A restrição única é `(evaluator_id, team_id, mode)`. O RPC de gravação faz upsert, preservando a data de criação. O nome normalizado remove espaços externos, reduz espaços consecutivos e converte para minúsculas. Não existe separação entre pessoas com o mesmo nome normalizado.

## Funções RPC

| Função | Parâmetros | Resposta |
| --- | --- | --- |
| `hello_code_save_evaluation` | `p_juror_name`, `p_team_id`, `p_mode`, `p_scores`, `p_comments` | `{ok, edited, record}` |
| `hello_code_list_evaluations` | `p_juror_name`, `p_evaluator_id`, `p_mode` | `{items}` |
| `hello_code_admin` | `p_mode` | `{mode, teams, grandTotal, evaluations, uniqueJurors}` |
| `hello_code_seed_test` | `p_juror_count`, `p_profile` | `{ok, message}` |
| `hello_code_reset_test` | Nenhum | `{ok, message}` |

`hello_code_normalize_juror_name`, `hello_code_scores_valid` e `hello_code_evaluation_json` são funções auxiliares.

### Gravação e consulta

O RPC de gravação exige nome não vazio, equipe válida e sete notas dentro dos limites. Preenche comentários ausentes, limita cada um a 2.000 caracteres e mantém sete posições. A tabela valida notas e tamanho do array de comentários; o total nunca depende do valor enviado pelo cliente.

A gravação usa `test` quando `p_mode = 'test'` ou a equipe é `test-team`; nos demais casos usa `official`. Equipes `1` a `9` são válidas nos dois modos; `test-team` é válida apenas em teste. Valores de modo desconhecidos são normalizados pelo código, não rejeitados explicitamente.

A consulta prioriza o nome normalizado. Na ausência de nome, usa `p_evaluator_id`. Retorna registros do modo escolhido em ordem de atualização decrescente. A consulta considera `test` somente quando esse valor é informado; caso contrário considera `official`.

Os registros retornados usam os campos camelCase `evaluatorId`, `jurorName`, `teamId`, `mode`, `scores`, `comments`, `total`, `createdAt` e `updatedAt`.

### Agregação e testes

O agregado considera as equipes `1` a `9` no modo solicitado. Retorna nove equipes, inclusive as sem avaliações. Cada item inclui `teamId`, `teamName`, `jurors`, `criterionSums`, `total`, `count` e `rank`. A classificação usa soma total decrescente, quantidade de avaliações decrescente e nome da equipe crescente. Não usa média.

A simulação limita a quantidade de juradas a `1..10`, gera notas para nove equipes e substitui registros de teste cujo identificador começa com `jurada simulada `. Perfis implementados: `balanced`, `wide` e `high`; outros valores usam a faixa padrão. O reset exclui todos os registros com `mode = 'test'`. Nenhuma dessas funções recebe modo oficial como argumento ou exclui avaliações oficiais.

## Compatibilidade com os HTMLs

As rotas abaixo são interceptadas no navegador e convertidas para RPC. Não precisam de endpoints no GitHub Pages.

| Chamada interna | RPC |
| --- | --- |
| `GET /api/evaluations?jurorName=...&evaluatorId=...&mode=...` | `hello_code_list_evaluations` |
| `POST /api/evaluations` | `hello_code_save_evaluation` |
| `GET /api/admin?mode=...` | `hello_code_admin` |
| `POST /api/admin?mode=test`, ação `seed-test` | `hello_code_seed_test` |
| `POST /api/admin?mode=test`, ação `reset-test` | `hello_code_reset_test` |

O POST de avaliação envia nome, equipe, modo, notas e comentários. O UUID do navegador continua no payload interno, mas o adaptador não o usa para gravar no Supabase. O adaptador do painel rejeita POST em modo oficial.

Os adaptadores retornam status `200` quando o RPC tem sucesso, `400` quando o Supabase informa erro, `503` quando o cliente não pode ser criado e `405` para métodos não suportados. Erros de rede podem rejeitar a chamada `fetch`.

## Modelo de acesso

RLS está habilitado na tabela. O SQL concede ao papel `anon` leitura, inserção e atualização públicas; a política de exclusão permite somente linhas de teste. As funções usam o contexto do chamador, sem `SECURITY DEFINER`.

O nome não autentica a jurada, e `x-admin-key` não é validado pelo adaptador ou pelo banco. A chave usada nos HTMLs é pública. Não incluir credenciais administrativas no frontend.

As validações de nome, equipe, limite de comentários e atualização de datas acontecem no RPC. Os grants também permitem acesso direto à tabela, sujeito às constraints e políticas. Essa diferença faz parte do modelo simples escolhido para o evento.

## Verificação

Ao alterar o SQL, verificar no projeto autorizado: gravação e edição sem duplicação, rejeição de notas inválidas, total gerado, consulta por nome, agregação e isolamento entre teste e oficial. Os testes dos adaptadores no navegador não substituem a execução desses fluxos no banco.

Consulte [configuração e publicação](../../README.md) para os passos operacionais.
