# Contexto de frontend — Hello Code 2026

## Arquivos e dependências

As interfaces usam HTML5, CSS e JavaScript puro, sem framework ou build de aplicação:

- `Hello_Code_Avaliacao_2026_PREVIA.html`: avaliação mobile-first.
- `Hello_Code_Dashboard_2026_PREVIA.html`: painel da organização.
- `supabase-config.js`: URL e chave pública compartilhadas.

CSS, imagens de marca em base64, markup e lógica estão nos HTMLs. Ambos carregam `supabase-js@2.117.3` pelo CDN e a configuração pelo caminho relativo `./supabase-config.js`, compatível com o subdiretório do GitHub Pages.

O workflow publica cópias como `index.html` e `dashboard.html`, preservando os arquivos de origem e suas interfaces. Consulte [configuração e publicação](../../README.md).

## Jornada da jurada

A navegação inferior alterna **Avaliar**, **Critérios** e **Minhas avaliações**. A avaliação percorre `setupScreen`, `scoreScreen`, `reviewScreen` e `successScreen`.

O objeto `state` guarda nome, equipe, etapa, sete notas, comentários e estado de edição. O array `CRITERIA` contém descrições e faixas dos critérios, na ordem definida no [contexto geral](../README.md). Notas são ajustadas por botões e slider; o total é calculado para feedback e recalculado no banco.

"Minhas avaliações" consulta os modos oficial e teste enviando `jurorName` e o UUID local. O Supabase prioriza o nome normalizado. A interface ainda filtra os registros pelo nome em minúsculas, sem a mesma normalização de espaços do banco. A edição carrega o registro no estado e reutiliza o fluxo de avaliação.

## Painel da organização

O painel mantém a tela de código administrativo. O campo é visual: o cabeçalho `x-admin-key` não é validado pelos RPCs. Após carregar, o painel mostra indicadores, ranking, somas dos critérios e tabela de notas por jurada.

O estado começa em `mode = 'test'`. A alternância permite consultar resultados oficiais. Os controles de simulação são ocultados no modo oficial; o botão de reset permanece visível, mas o adaptador bloqueia POST nesse modo. A simulação e o reset solicitam confirmação e operam somente em teste.

Textos de equipes e juradas retornados pelo banco são escapados por `esc()` na renderização do dashboard. Valores numéricos são convertidos antes de serem inseridos nos templates.

## Adaptadores e armazenamento local

Cada HTML intercepta apenas sua rota interna: `/api/evaluations` ou `/api/admin`. O adaptador chama as funções Supabase descritas no [contrato de backend](../backend/README.md). Outras requisições continuam usando o `fetch` nativo.

Em HTTP/HTTPS, o adaptador é instalado mesmo quando falta a chave pública ou a biblioteca do CDN. Ele retorna erro `503` nesse caso e impede que os mocks substituam o banco. `HELLO_CODE_SUPABASE_READY` indica que o adaptador foi instalado, não que uma conexão foi comprovada.

Ao abrir por `file:` sem URL ou chave configurada, os mocks locais são ativados. As chaves existentes são:

| Chave | Uso |
| --- | --- |
| `helloCodeEvaluatorId` | UUID do navegador, mantido por compatibilidade |
| `helloCodeJurorName` | Último nome informado |
| `helloCodePreviewEvaluationsV1` | Avaliações do mock da jurada |
| `helloCodeAdminPreviewV1` | Dados do mock do dashboard |

Os dois mocks não compartilham registros, e o dashboard local não representa as avaliações oficiais do Supabase. Dados locais não são migrados automaticamente para o banco.

## Aparência e responsividade

Preservar português do Brasil, rosa `#ff4f93`, verde `#19c864`, fontes do sistema e marca existente. A avaliação tem largura máxima aproximada de 760 px; o painel, de 1180 px. A avaliação usa duas colunas a partir de 700 px. O painel adapta indicadores e barras abaixo de 720 px, e sua tabela permite rolagem horizontal.

Ao alterar layout, conferir telas de 320/360 px, tablet, desktop, zoom de 200%, navegação por teclado e área segura inferior. Não introduzir redesign ou reorganização em módulos sem necessidade para o pedido.

## Limitações atuais

- "Minhas avaliações" não verifica `response.ok`; um erro RPC pode aparecer como lista vazia.
- O filtro de nome da interface pode esconder resultados quando a consulta varia os espaços internos.
- Alguns templates da avaliação ainda interpolam dados externos e mensagens de erro em `innerHTML`; novas alterações devem usar texto seguro.
- Após abrir o dashboard, erros de atualização são escritos em `#err`, que fica na seção de acesso oculta. As ações de simulação e reset não têm tratamento próprio de rejeições.
- O dashboard ainda não tem texto alternativo na imagem da marca; foco, rótulos dos controles e anúncios de estado precisam ser verificados quando houver alterações nesses fluxos.

Esses pontos descrevem o código atual e não representam funcionalidades já corrigidas.
