# Hello Code 2026

Sistema de avaliação do Hello Code 2026. As juradas informam apenas o nome, escolhem uma equipe e atribuem notas em sete critérios, com total máximo de 100 pontos. A organização acompanha resultados, ranking e notas por jurada.

## Aplicações

- [Avaliação das juradas](https://heitorreis.github.io/hello-code/)
- [Painel da organização](https://heitorreis.github.io/hello-code/dashboard.html)

As interfaces usam HTML, CSS e JavaScript puro. O GitHub Pages publica os arquivos estáticos; o navegador acessa o Supabase diretamente por RPC, sem servidor próprio ou cadastro de usuários.

## Estado da integração

O frontend é publicado pelo GitHub Actions e usa o projeto Supabase `jjqamsjvctuiiwstoafm`, com chave pública configurada em `supabase-config.js`. A integração foi verificada com gravação, edição sem duplicação, consulta por nome, total calculado no banco, rejeição de nota inválida e isolamento entre teste e oficial. O registro temporário de verificação foi removido sem alterar avaliações oficiais.

## Arquivos principais

| Arquivo | Responsabilidade |
| --- | --- |
| `Hello_Code_Avaliacao_2026_PREVIA.html` | Identificação, notas, envio e edição |
| `Hello_Code_Dashboard_2026_PREVIA.html` | Resultados, ranking e simulação |
| `supabase-config.js` | URL e chave pública compartilhadas |
| `supabase_hello_code.sql` | Tabela, validação, políticas e funções |
| `.github/workflows/pages.yml` | Publicação automática da branch `main` |

Os nomes dos HTMLs mantêm o sufixo `PREVIA` para compatibilidade. O workflow publica a avaliação como `index.html` e o painel como `dashboard.html`.

## Documentação

- [Configuração e publicação](docs/README.md)
- [Regras e arquitetura](docs/contexto/README.md)
- [Persistência e contratos RPC](docs/contexto/backend/README.md)
- [Interfaces e navegador](docs/contexto/frontend/README.md)

Para trabalhar no projeto, consulte também [AGENTS.md](AGENTS.md).
