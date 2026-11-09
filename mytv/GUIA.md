# Guia passo a passo (para quem nunca usou o terminal)

Calma, é mais fácil do que parece. Você só vai **copiar e colar** algumas linhas. Leva uns 20 minutos.

**O que você precisa:**
- Um computador (Windows, Mac ou Linux) **na mesma internet de casa que a TV** (mesmo roteador).
- A TV ligada e o controle remoto por perto.

---

## Parte 1: Preparar a TV (uma vez só)

1. Na TV: **Configurações → Preferências do dispositivo → Sobre**.
2. Desça até **Build** (ou "Versão") e aperte **OK 7 vezes seguidas**. Vai aparecer "Você agora é um desenvolvedor".
3. Volte uma tela e entre em **Opções do desenvolvedor**.
4. Ligue **Depuração USB** (e **Depuração de rede/ADB**, se aparecer).
5. Deixe a TV ligada.

---

## Parte 2: Baixar a pasta para o seu computador

1. Aqui no chat, use o botão **"Save to GitHub"** para mandar o projeto para a sua conta do GitHub.
2. No site do GitHub, abra o projeto, clique no botão verde **Code → Download ZIP**.
3. Abra o ZIP (clique duas vezes) e coloque a pasta na **Área de Trabalho**.
   Renomeie a pasta para **`cleanyourtv`** (sem espaços).

Dentro dela tem uma pasta **`mytv`**: é ali que está tudo que eu preparei para a sua TV.

---

## Parte 3: Instalar o Python e abrir o terminal

### Se você usa **Windows**
1. Baixe o **Python** em https://www.python.org/downloads/ e instale.
   ⚠️ Na primeira tela da instalação, **marque a caixinha "Add python.exe to PATH"**.
2. Baixe o **Git para Windows** em https://git-scm.com/download/win e instale (pode ir clicando "Next" em tudo).
3. Abra a pasta `cleanyourtv` na Área de Trabalho, clique com o **botão direito num espaço vazio** dentro dela e escolha
   **"Open Git Bash here"** (no Windows 11: "Mostrar mais opções" → "Open Git Bash here").
   Vai abrir uma janela preta: esse é o terminal.

### Se você usa **Mac**
1. O Python já costuma vir instalado. Se pedir para instalar as "ferramentas de linha de comando", aceite.
2. Abra o **Terminal** (aperte `Cmd + Espaço`, digite *Terminal* e aperte Enter).
3. Digite isto e aperte Enter:
   ```
   cd ~/Desktop/cleanyourtv
   ```

### Se você usa **Linux**
Abra o Terminal e digite `cd ~/Área\ de\ Trabalho/cleanyourtv` (ou `cd ~/Desktop/cleanyourtv`).

---

## Parte 4: Rodar, nesta ordem

Em cada passo: **copie a linha, cole no terminal** (no Git Bash: botão direito → Paste) **e aperte Enter**.

### Passo 1: limpeza + nova tela inicial (o principal)
```
bash mytv/run.sh
```
O que vai acontecer:
- Primeiro ele prepara as ferramentas (só na primeira vez, 1 a 2 minutos).
- **Na TV aparece "Permitir depuração USB?"** → marque **"Sempre permitir deste computador"** e aperte **OK** no controle.
- Ele faz o **backup** (cópia de tudo), depois a **limpeza** e instala a **nova tela inicial**.
- Entre uma etapa e outra ele para e escreve *"aperte Enter para continuar"*. Olhe a TV e aperte **Enter**.
- No final aparece **"Pronto!"** e uma lista de **gerenciadores de arquivos**: copie essas linhas para me mandar.

### Passo 2: o tema Aurora (opcional)
```
bash mytv/theme.sh
```
A tela inicial ganha o fundo de aurora boreal. Para voltar ao preto: `bash mytv/theme.sh --reset`

### Passo 3: a segunda limpeza (opcional)
```
bash mytv/round2.sh
```

### Quer desfazer tudo?
```
bash mytv/restore.sh
```
A TV volta exatamente como era antes.

---

## Parte 5: Me mandar as fotos

1. Abra a pasta `cleanyourtv` → `mytv` → **`shots`**. As fotos da tela da TV estão lá (`1-before.png`, `2-after-debloat.png`, `3-new-home.png`...).
2. Aqui no chat, clique no **clipe/anexo** e envie essas fotos.
3. Cole também as linhas dos **gerenciadores de arquivos** que apareceram no final do Passo 1.

Com isso eu confiro se tudo ficou certo e coloco o seu gerenciador de arquivos na 7ª posição da barra.

---

## Deu algum problema?

| Mensagem | O que fazer |
|---|---|
| `could not reach 192.168.1.151` | A TV está desligada, ou o computador não está na mesma internet de casa. Confira e rode de novo. Se o IP da TV mudou (Configurações → Rede), coloque o IP no final do comando: `bash mytv/run.sh 192.168.1.XXX` (vale para todos: `theme.sh`, `round2.sh`, `restore.sh`) |
| `python: command not found` | (Windows) Reinstale o Python marcando **"Add python.exe to PATH"** e abra o Git Bash de novo. |
| O aviso na TV não apareceu | Desligue e ligue de novo a **Depuração USB** na TV e rode o comando outra vez. |
| O botão Home abre a tela antiga do Google TV | Na TV: Configurações → Sistema → Acessibilidade → **CleanYourTV Home button → Ativar**. |
| Qualquer outra coisa | Tire uma foto da janela preta (ou copie o texto) e me mande aqui. |

**No final de tudo:** desligue a **Depuração USB** nas Opções do desenvolvedor da TV, por segurança.
