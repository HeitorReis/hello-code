# Orientação do repositório

Este repositório contém as interfaces estáticas e o SQL Supabase do sistema de avaliação Hello Code 2026, publicado no GitHub Pages.

Antes de alterar o projeto, consulte [o índice de contexto](docs/contexto/README.md). Use a skill local correspondente ao escopo:

- `.agents/skills/hello-code-context`: mudanças de domínio, regras compartilhadas ou que afetam mais de uma área.
- `.agents/skills/hello-code-backend`: SQL Supabase, contratos RPC, persistência, agregação e operações de teste.
- `.agents/skills/hello-code-frontend`: HTML, CSS, JavaScript, fluxos, responsividade e acessibilidade.

As páginas usam adaptadores de `window.fetch` para acessar RPCs do Supabase. Os mocks e o armazenamento de avaliações em `localStorage` servem somente à prévia aberta por `file:` sem configuração completa; não são infraestrutura de produção. A identificação da jurada é apenas pelo nome, conforme o escopo escolhido. Confira a configuração e a verificação do banco antes de afirmar que a integração está operacional.
