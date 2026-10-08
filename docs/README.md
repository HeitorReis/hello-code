# Configuração e publicação

O projeto usa dois HTMLs, uma configuração pública compartilhada e um banco Supabase. O frontend é publicado no repositório [HeitorReis/hello-code](https://github.com/HeitorReis/hello-code) pelo GitHub Actions.

## Supabase

O projeto configurado é `jjqamsjvctuiiwstoafm` (Hello code). A chave pública está configurada e os RPCs responderam aos testes de integração. Os passos abaixo servem para configurar outro projeto ou atualizar a conexão existente.

1. Com acesso ao projeto, execute [supabase_hello_code.sql](../supabase_hello_code.sql) no SQL Editor ou por uma conexão administrativa autorizada.
2. Configure [supabase-config.js](../supabase-config.js) com a URL do projeto e sua chave pública.
3. Publique a alteração e confira envio, consulta, edição e leitura no dashboard.

```js
window.HELLO_CODE_SUPABASE_CONFIG = {
  url: 'https://jjqamsjvctuiiwstoafm.supabase.co',
  anonKey: 'SUA_PUBLISHABLE_KEY'
};
```

O campo `anonKey` aceita a chave pública usada pelo cliente. Nunca coloque senha do banco, token administrativo, chave secreta ou `service_role` nesse arquivo.

A jurada é identificada pelo nome normalizado no banco. Não há conta ou login de jurada. O campo de código administrativo foi preservado na interface, mas não é validado pelas funções RPC. As políticas permitem acesso público ao banco conforme o modelo simples escolhido para o evento.

## GitHub Pages

Em Settings > Pages, a origem deve ser GitHub Actions. O [workflow](../.github/workflows/pages.yml) executa a cada push em `main` e também pode ser iniciado manualmente.

Ele monta `_site` com a avaliação como `index.html`, o painel como `dashboard.html`, os dois HTMLs com seus nomes originais e `supabase-config.js`. SQL, documentação e instruções de agentes não são incluídos no artefato do Pages.

- [Juradas](https://heitorreis.github.io/hello-code/)
- [Organização](https://heitorreis.github.io/hello-code/dashboard.html)
- [Execuções da publicação](https://github.com/HeitorReis/hello-code/actions)

Não existe build de aplicação, pacote npm ou servidor próprio. A biblioteca `supabase-js` é carregada pelo CDN na versão fixada nos HTMLs.

## Prévia local

Abrir os HTMLs diretamente (`file:`), sem chave pública configurada, ativa os mocks locais. Cada página usa um armazenamento próprio, e o dashboard local não lê as avaliações da outra página. Esse modo serve apenas para explorar a interface.

Em HTTP/HTTPS, os mocks ficam desativados mesmo sem configuração válida. Envios e acesso ao painel retornam erro quando não conseguem conectar ao banco. A consulta "Minhas avaliações" ainda não verifica o status HTTP antes de interpretar a resposta e pode mostrar uma lista vazia em caso de erro.

## Verificação da integração

Antes de distribuir a aplicação para o evento:

1. Envie uma avaliação de teste e confirme sua persistência no Supabase.
2. Consulte pelo mesmo nome em outro navegador e edite a avaliação; confira que o registro é atualizado em vez de duplicado.
3. Verifique notas, total e ranking no painel para equipes de `1` a `9`. A equipe `test-team` não participa desse agregado.
4. Verifique a rejeição de notas fora dos limites e o cálculo do total no banco.
5. Confira que simulação e reset afetam apenas o modo `test`, preservando dados oficiais.

Os RPCs foram verificados no projeto remoto com a chave pública: gravação, edição sem duplicação, total calculado, consulta por nome, rejeição de nota acima do máximo, isolamento entre teste e oficial e leitura do agregado oficial. O registro temporário foi removido por exclusão restrita ao seu nome, equipe e modo de teste. Simulação e reset completos não foram executados nessa verificação. A publicação do frontend, a sintaxe dos scripts, o mapeamento dos adaptadores e o bloqueio de operações de teste no modo oficial também foram verificados.

## Contexto técnico

- [Regras e arquitetura](contexto/README.md)
- [Persistência e contratos RPC](contexto/backend/README.md)
- [Interfaces e navegador](contexto/frontend/README.md)

As skills locais ficam em `.agents/skills/` e orientam mudanças de domínio, backend e frontend. Consulte [AGENTS.md](../AGENTS.md) antes de alterar o projeto.
