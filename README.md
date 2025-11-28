# ⌨️ Teclado US International com Comportamento Windows no Linux

Este projeto oferece uma configuração customizada para o arquivo **`.XCompose`**, corrigindo o comportamento das teclas mortas no Linux (especialmente em ambientes GNOME/Fedora) para replicar a experiência exata do teclado **"United States-International"** do Windows/macOS.

## 🎯 O Problema Resolvido

No Linux, ao usar o layout **"Inglês (EUA, intl., com teclas mortas)"**, o sistema de composição padrão (Compose) geralmente falha nos seguintes cenários:

1.  **A Cedilha Errada:** Pressionar `'` + `c` resulta em `ć` (c com acento agudo) em vez de **`ç`**.
2.  **Aspas "Grudentas" Estritas:** Pressionar `'` seguido de uma consoante (ex: `t`) resulta em um caractere inválido ou exige que se pressione `Espaço` antes da consoante.
3.  **Aspas Literais com Espaço:** Pressionar a tecla morta (`'`, `"`, `~`) seguida de **Espaço** não resulta no caractere literal, o que impede a digitação rápida de aspas ou apóstrofos.

---

## ✨ Características da Configuração

Com este **`.XCompose`** e a configuração do ambiente, o seu teclado passará a ter o seguinte comportamento:

| Sequência de Teclas | Caractere Resultante | Comportamento |
| :--- | :--- | :--- |
| **'** + **c** | **ç** | **Cedilha** (Comportamento Windows) |
| **'** + **t** | **'t** | **Aspas "Inteligentes"** (Não exige Espaço para consoantes) |
| **'** + **Espaço** | **'** | **Apóstrofo literal** (Funcionamento Corrigido) |
| **~** + **a** | **ã** | Mantém os acentos padrão |

---

## 🚀 Instalação e Configuração

### Pré-requisitos

1.  Seu sistema deve estar usando o layout **"Inglês (EUA, Internacional, com teclas mortas)"** (Configurações > Teclado).
2.  Instale os pacotes necessários:
    ```bash
    sudo dnf install wget uim uim-gtk3 uim-qt -y
    ```

### 1. Método Automático (Recomendado)

O script `install.sh` automatiza o download do `.XCompose`, a cópia para o seu diretório pessoal e a configuração das variáveis de ambiente.

1.  **Clonar e Acessar o Repositório**
    ```bash
    git clone https://github.com/Wanderson98/xcompose-fedora.git
    cd xcompose-fedora
    ```

2.  **Executar o Script**
    ```bash
    chmod +x install.sh
    ./install.sh
    ```
    *O script fará o download e configurará as variáveis `GTK_IM_MODULE=xim`, `QT_IM_MODULE=xim`, `XMODIFIERS=@im=xim` e `XIM=xim`.*

3.  **Reiniciar**
    Após a execução, é **obrigatório** reiniciar o seu computador:
    ```bash
    reboot
    ```

---

### 2. Instalação Manual (Alternativa)

Se você preferir aplicar as mudanças diretamente nos arquivos de configuração do sistema, siga estes passos:

#### Passo 1: Copiar o Arquivo de Regras

Copie o arquivo `.XCompose` para o seu diretório pessoal (`$HOME`):

```bash
cp .XCompose ~/.XCompose
```

Passo 2: Configurar Variáveis de Ambiente Globais

Defina o método de entrada para todos os programas (GTK e QT), forçando o uso do XIM. Isso requer permissões de administrador.


```bash
sudo nano /etc/environment
```

Adicione ou ajuste as seguintes linhas:

```plaintext
GTK_IM_MODULE=xim
QT_IM_MODULE=xim
```

Passo 3: Configurar Variáveis de Sessão

Garanta que o seu usuário carregue o Input Method (XIM) na sessão gráfica, definindo a variável XMODIFIERS que indica ao sistema para onde procurar as regras.

```bash
nano ~/.profile
```

Adicione as seguintes linhas no final do arquivo:

```bash
export XMODIFIERS="@im=xim"
export XIM="xim"
```

Passo 4: Reiniciar o Sistema

Para que as alterações nos arquivos /etc/environment e ~/.profile sejam aplicadas, é necessário recarregar completamente a sessão.

```bash
reboot
```

# 🗑️ Como Desfazer as Alterações (Rollback)

Este guia explica como usar o script `uninstall.sh` para reverter todas as configurações feitas pelo script `install.sh` no seu sistema, restaurando os arquivos originais.

---

## 🛑 O Que o Script `uninstall.sh` Faz?

O script de desinstalação garante uma reversão limpa e segura, utilizando os arquivos de *backup* criados durante a instalação.

1.  **Restauração de Arquivos:** Restaura os arquivos originais (deletando o conteúdo modificado) dos backups (`.bak`):
    * `/etc/environment`
    * `~/.profile`
    * `~/.XCompose` (se um backup original existia).
2.  **Limpeza:** Remove permanentemente todos os arquivos de *backup* (`.bak`) após a restauração.
3.  **Remoção de Arquivo Customizado:** Se nenhum backup original de `.XCompose` existia, ele remove o arquivo `.XCompose` customizado que foi copiado para a sua `$HOME`.

---

## ⚙️ Passo a Passo para a Reversão

Para executar o script de desinstalação, certifique-se de estar no diretório do projeto (`xcompose-fedora`).

### 1. Acessar o Diretório do Projeto

Se você não estiver no diretório onde o `uninstall.sh` está salvo, navegue até ele e abra uma janela do terminal:

2. Dar Permissão de Execução ao Script

Garanta que o script possa ser executado.

```bash
chmod +x uninstall.sh
```

3. Executar o Script de Desinstalação

Execute o script. Ele pedirá sua senha de sudo para restaurar o arquivo /etc/environment.

```bash
./uninstall.sh
```

4. Reiniciar o Sistema (Obrigatório)

Assim como na instalação, você deve reiniciar a sessão ou o computador para que o sistema carregue novamente os arquivos de configuração originais, sem as variáveis do XIM.

```bash
reboot
```