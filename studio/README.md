# Keypad Studio

Interface gráfica (estilo Apple/Logitech) para configurar seu teclado macro
**ch57x — 12 teclas (3×4) + 2 knobs**, por cima da ferramenta oficial
[`ch57x-keyboard-tool`](https://github.com/kriomant/ch57x-keyboard-tool).

Tudo roda **localmente** no seu PC. Nada é enviado para a internet.

---

## Como usar (1 clique)

1. Conecte o teclado no PC por **cabo USB**.
2. (Só para *enviar* ao teclado) Instale o driver **USBDK**:
   <https://github.com/daynix/UsbDk/releases>
3. Dê **duplo clique** em **`Keypad Studio.bat`** (na pasta acima desta).
   - Abre uma janelinha preta (o *bridge*) — **deixe aberta**.
   - O navegador abre sozinho em `http://localhost:8787`.
4. Clique numa tecla ou knob, escolha a ação, e clique **Enviar p/ teclado**.

Para fechar, feche a janelinha preta.

---

## O que dá pra configurar

- **12 teclas + 2 knobs** (cada knob: girar ↺, apertar ●, girar ↻).
- **3 layers** (camadas) — troque pelo botão lateral do teclado.
- Ações:
  - **Tecla** única (letras, números, F1–F24, navegação, numpad, símbolos…)
  - **Atalho** (ex.: `ctrl-c`, `ctrl-shift-esc`)
  - **Macro / sequência** (até 5 passos, com `delay` opcional) — ex.: digitar "oi"
  - **Mouse** (clique, scroll, mover, arrastar — com modificadores)
  - **Mídia** (play, volume, brilho, bloquear tela, navegador…)
  - **Avançado** — digita a sintaxe crua do CLI, com validação ao vivo
- **Iluminação (LED)** — modos e cores (depende do modelo do seu teclado).
- **Importar / Exportar** o `.yaml`, e botão **Validar**.
- **Perfis** — salve/carregue configurações nomeadas (ficam no navegador),
  botão **Carregar exemplo** e **Começar do zero**.

---

## ⚠️ Sobre "ler" a config que já está no teclado

**Não é possível.** Esses teclados CH57x (e a ferramenta oficial) só sabem
**gravar** — a comunicação USB é de mão única (host → teclado). Não existe
comando de leitura/dump; o próprio software original também só escreve e nunca
lê de volta o que está no dispositivo.

Por isso a interface funciona como a sua *fonte da verdade*. Mas tem um atalho:

**Botão "Sincronizar"** — o bridge guarda uma cópia da **última config enviada**
por este app (`studio/.last-config.yaml`). Como o teclado só recebe config por
aqui, essa cópia é, na prática, **o que está no teclado**. Ao abrir uma sessão
nova sem nada salvo, o app já **sincroniza sozinho**; e o botão Sincronizar
traz essa config a qualquer momento.

Também dá pra **salvar num Perfil** (ou exportar o `.yaml`) e reenviar depois. Se
você já tinha um `.yaml` de antes, use **Importar**.

A barra de cima mostra o status: **Conectado** (verde) quando o teclado é
detectado, **Modo prévia** quando você abre o `index.html` sem o bridge.

## Orientação (importante!)

Em **Ajustes do teclado → Orientação**, escolha como você **segura** o teclado:

- **Vertical ↺ (knobs em cima)** — padrão, é como este teclado fica em pé na mesa.
  O editor desenha **3 colunas × 4 linhas** e o que você clica é exatamente a
  tecla que você aperta.
- **Normal (knobs à direita)** — se você usar deitado, knobs à direita.

Se as teclas saírem "embaralhadas" (você aperta uma e sai outra), é a orientação
errada — troque aqui e grave de novo.

---

## Modo prévia (sem enviar)

Você pode abrir `studio/index.html` direto no navegador para montar/exportar a
config, mas **Validar/Enviar/LED** só funcionam quando aberto pelo
`Keypad Studio.bat` (que sobe o bridge e fala com o `.exe`).

---

## Estrutura

```
ch57x-keyboard-tool/
├─ Keypad Studio.bat        ← clique aqui
├─ bin/
│  └─ ch57x-keyboard-tool.exe   (binário oficial v1.7.0)
└─ studio/
   ├─ index.html           ← a interface
   ├─ bridge.ps1           ← servidor local (PowerShell)
   └─ README.md
```

## Créditos

- CLI: **ch57x-keyboard-tool** © Mikhail Trishchenkov — licença MIT/Apache-2.0.
- Esta interface apenas gera a config e chama o CLI oficial.
