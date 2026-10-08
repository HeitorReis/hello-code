# Configuração rápida do Supabase

Esta versão continua sendo composta por dois arquivos HTML. Para usar com banco real:

1. Crie ou abra um projeto no Supabase.
2. No SQL Editor, execute o arquivo [`../supabase_hello_code.sql`](../supabase_hello_code.sql).
3. No painel do Supabase, copie a Project URL e a chave publica (publishable key).
4. No arquivo `supabase-config.js`, preencha:

```js
window.HELLO_CODE_SUPABASE_CONFIG = {
  url: 'https://SEU-PROJETO.supabase.co',
  anonKey: 'SUA_PUBLISHABLE_KEY'
};
```

Não use a `service_role` key nos HTMLs.

## Publicacao no GitHub Pages

O workflow `.github/workflows/pages.yml` publica apenas os HTMLs e a configuracao publica a cada push na branch `main`. No GitHub, a origem do Pages deve ser GitHub Actions.

- Juradas: `https://heitorreis.github.io/hello-code/`
- Organizacao: `https://heitorreis.github.io/hello-code/dashboard.html`

O endereco raiz abre diretamente a avaliacao, com a mesma interface. As paginas hospedadas exibem erro quando o banco esta indisponivel; nunca confirmam um envio salvo apenas no navegador. A previa local permanece disponivel ao abrir os arquivos diretamente, quando a chave publica ainda nao foi configurada.

## Como ficou simples

- A jurada informa apenas o nome.
- O nome normalizado é usado como identificador da jurada.
- Um novo envio para a mesma jurada, equipe e modo substitui a avaliação anterior.
- O dashboard lê as avaliações oficiais e de teste do mesmo banco.
- Simulação e reset continuam restritos ao modo de teste.

As políticas do banco estão propositalmente permissivas para permitir o uso direto via HTML e chave pública. Isso é suficiente para lançamento simples, mas não é uma proteção forte contra manipulação manual por alguém técnico.
