# Contexto Técnico: gbr_shared
Este repositório é o núcleo agnóstico da Gleam-BR. Toda lógica de negócio que deve rodar tanto em Erlang (BEAM) quanto em JavaScript (Browser/Node) reside aqui.

## Regras de Ouro
1. **Zero FFI:** Não utilize external functions diretamente aqui. Se uma função depende de plataforma, ela deve ser definida como um `Type` ou `Interface` aqui e implementada no `gbr_erl` ou `gbr_js`.
2. **Tipagem Opaca:** Utilize tipos opacos para garantir que estados internos de lógica compartilhada não sejam manipulados indevidamente.
3. **Pureza:** Funções devem ser puras sempre que possível para facilitar testes unitários em ambos os targets.

# Contexto: gbr_shared
Este repositório contém a lógica de negócio pura que deve ser idêntica em JavaScript e Erlang.

## Diretrizes para o Gemini CLI:
1. **Zero Efeitos Colaterais:** Não sugira funções que acessem o disco, rede ou APIs de browser aqui.
2. **Tipos de Dados:** Utilize tipos de dados que tenham representação simples em ambas as plataformas.
3. **Interoperabilidade:** Se uma funcionalidade precisar de implementação específica, defina o tipo opaco aqui e delegue a implementação para `gbr_js` ou `gbr_erl`.

# Contexto: gbr_shared
Este repositório é a "Single Source of Truth" para lógica de negócio e tipos da Gleam-BR.

## Regras de Ouro para o Gemini:
1. **Target Agnostic:** Nunca sugira bibliotecas que dependam de `erlang` ou `javascript`.
2. **Tipos de Dados:** Utilize tipos básicos do Gleam ou tipos definidos aqui.
3. **Contratos:** Se algo exige comportamento específico de plataforma, defina um `Type` (ex: `Config`) aqui que será preenchido pelas bibliotecas `gbr_erl` ou `gbr_js`.
4. **Foco:** Validações, transformações de dados de processos (BPM) e definições de chaves (KVM).
