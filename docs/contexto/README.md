# Contexto geral — Hello Code 2026

## Objetivo e arquitetura

O sistema atende juradas que avaliam equipes e a organização que acompanha resultados do Hello Code 2026. A identificação da jurada é apenas pelo nome, sem cadastro ou autenticação, conforme o escopo escolhido para o evento.

As duas interfaces permanecem em HTML, CSS e JavaScript puro. O GitHub Pages publica os arquivos estáticos. Adaptadores de `window.fetch` convertem chamadas internas `/api/evaluations` e `/api/admin` em RPCs do Supabase; essas rotas não correspondem a um servidor HTTP próprio.

- `Hello_Code_Avaliacao_2026_PREVIA.html`: jornada da jurada.
- `Hello_Code_Dashboard_2026_PREVIA.html`: painel e simulador.
- `supabase-config.js`: configuração pública compartilhada.
- `supabase_hello_code.sql`: persistência, validação e agregação.
- `.github/workflows/pages.yml`: publicação como `index.html` e `dashboard.html`.

O frontend está publicado e a chave pública está configurada. A integração com o projeto remoto foi verificada para gravação, edição, consulta, validação de notas e leitura do agregado oficial. Consulte [configuração e publicação](../README.md).

## Pontuação e equipes

Os arrays de notas e comentários seguem esta ordem:

| Índice | Critério | Máximo |
| --- | --- | ---: |
| 0 | Problema e relevância | 15 |
| 1 | Criatividade e inovação | 15 |
| 2 | Solução e tecnologia | 20 |
| 3 | Impacto e aplicabilidade | 15 |
| 4 | Protótipo e validação | 10 |
| 5 | Performance nas perguntas | 15 |
| 6 | Pitch | 10 |
| | **Total** | **100** |

Cada critério possui cinco faixas descritivas no array `CRITERIA` da avaliação. O dashboard usa os nomes curtos. Os limites também estão no SQL e devem permanecer alinhados.

As nove equipes oficiais têm IDs de `"1"` a `"9"`. A equipe especial `"test-team"` força o modo de teste e não aparece no agregado do painel. Os nomes das equipes existem nos HTMLs e no SQL.

## Fluxos e identidade

A jurada informa o nome, escolhe a equipe, preenche sete notas e comentários opcionais, revisa e envia. "Minhas avaliações" consulta os modos oficial e teste pelo nome e permite carregar um registro para edição.

No Supabase, `evaluator_id` é o nome com espaços externos removidos, espaços consecutivos reduzidos e letras convertidas para minúsculas. Uma nova avaliação da mesma jurada, equipe e modo atualiza o registro existente. Pessoas com o mesmo nome normalizado compartilham esse identificador.

A organização entra no painel, alterna entre teste e oficial e consulta indicadores, ranking, somas por critério e notas por jurada. O código administrativo permanece visual; os RPCs não o validam. Simulação e reset trabalham somente com registros de teste.

## Modos de execução

Em HTTP/HTTPS, as páginas usam o adaptador Supabase e não ativam armazenamento local como substituto do banco. Ao abrir os arquivos diretamente (`file:`) sem configuração completa, os mocks permitem explorar as interfaces. Os armazenamentos locais das duas páginas são independentes e não compartilham avaliações.

O UUID `helloCodeEvaluatorId` e o último nome `helloCodeJurorName` permanecem no navegador por compatibilidade. A identidade usada no banco é derivada do nome.

## Convenções

- Preservar conteúdo em português do Brasil e a identidade rosa `#ff4f93` / verde `#19c864`.
- Manter as interfaces existentes e o fluxo mobile-first da avaliação.
- Preservar a ordem dos sete critérios e o máximo de 100 pontos.
- Coordenar alterações de equipes, contratos e limites entre HTMLs e SQL.
- Calcular e validar notas no banco; o total no cliente serve como feedback.
- Manter teste e oficial isolados nas consultas e operações de simulação/reset.
- Não adicionar autenticação, servidor próprio ou refatorações estruturais sem mudança de escopo.

Para contratos e limites efetivamente implementados, consulte o [backend](backend/README.md). Para navegação, adaptadores e pontos pendentes da interface, consulte o [frontend](frontend/README.md).
