# Conteúdo do install.sh 
# -------------------------------------------------------------

#!/bin/bash

XCOMPOSE_FILE=".XCompose"
XCOMPOSE_PATH="$HOME/$XCOMPOSE_FILE"
ETC_ENV="/etc/environment"
PROFILE_FILE="$HOME/.profile"

echo "==================================================="
echo "Instalador de Teclado US Intl (Windows) para Linux"
echo "==================================================="

# --- Funções de Segurança ---

# Função de backup que CRIA um arquivo .bak se ele não existir
backup_file() {
    FILE=$1
    BACKUP_FILE="${FILE}.bak"

    # Verifica se o backup já existe. Se existir, não sobrescreve.
    if [ ! -f "$BACKUP_FILE" ]; then
        # O sudo é usado para o caso de arquivos de sistema como /etc/environment
        sudo cp "$FILE" "$BACKUP_FILE"
        echo "   [Backup] Criado backup de $FILE em $BACKUP_FILE"
    else
        echo "   [Backup] Backup de $FILE já existe ($BACKUP_FILE). Pulando a criação."
    fi
}

update_env_var() {
    FILE=$1
    VAR_NAME=$2
    NEW_VALUE=$3
    EXPORT_PREFIX=$4 # Ex: 'export' para .profile ou vazio para /etc/environment

    # Formato da linha que queremos no arquivo (COM aspas duplas)
    TARGET_LINE="${EXPORT_PREFIX} ${VAR_NAME}=\"${NEW_VALUE}\""
    
    # Remove espaços iniciais/finais e checa se a linha de destino já existe (Idempotência)
    if grep -q "^[[:space:]]*${TARGET_LINE}[[:space:]]*$" "$FILE"; then
        echo "-> ${VAR_NAME} já existe e está formatada corretamente. Pulando a edição."
        return 0
    fi
    
    # 1. Checa se a variável já existe (independente do valor/formato)
    if grep -q "^[[:space:]]*${EXPORT_PREFIX}[[:space:]]*${VAR_NAME}=" "$FILE"; then
        # 2. Se existe, substitui o valor e o formato
        echo "-> Atualizando e formatando ${VAR_NAME} em $FILE..."
        # Substitui qualquer linha existente com o nome da variável pela TARGET_LINE formatada
        sudo sed -i "s|^[[:space:]]*${EXPORT_PREFIX}[[:space:]]*${VAR_NAME}=.*|${TARGET_LINE}|" "$FILE"
    else
        # 3. Se não existe, adiciona no final
        echo "-> Adicionando ${VAR_NAME} em $FILE..."
        echo "$TARGET_LINE" | sudo tee -a "$FILE" > /dev/null
    fi
    
    # Remove linhas vazias ou redundantes que possam ter sido criadas
    sudo sed -i '/^[[:space:]]*$/d' "$FILE"
}

# --- Início da Execução do Script ---

# 1. Copiar o arquivo .XCompose para o diretório HOME
echo "-> Copiando o arquivo $XCOMPOSE_FILE do diretório atual para $HOME/..."

if [ ! -f "$XCOMPOSE_FILE" ]; then
    echo "   [ERRO] O arquivo $XCOMPOSE_FILE não foi encontrado no diretório atual. Abortando."
    echo "   Certifique-se de que o arquivo .XCompose está presente e tente novamente."
    exit 1
fi

# Antes de COPIAR/SUBSTITUIR, fazemos o backup do .XCompose existente
if [ -f "$XCOMPOSE_PATH" ]; then
    backup_file "$XCOMPOSE_PATH"
fi

cp "$XCOMPOSE_FILE" "$HOME/"

if [ $? -eq 0 ]; then
    echo "   [OK] Arquivo .XCompose copiado e salvo em $HOME/."
else
    echo "   [ERRO] Falha ao copiar o arquivo .XCompose. Abortando."
    exit 1
fi
echo ""

# 2. Configurar o ambiente do sistema (/etc/environment) - Requer sudo
echo "--- CONFIGURANDO VARIÁVEIS GLOBAIS (/etc/environment) ---"
if [ ! -w /etc/environment ]; then
    echo "   [AVISO] O script precisa de permissão de escrita em $ETC_ENV para continuar."
fi

# Cria backup do arquivo de ambiente global
backup_file "$ETC_ENV" 

# Variáveis globais (/etc/environment) são definidas SEM aspas duplas no valor
update_env_var "$ETC_ENV" "GTK_IM_MODULE" "xim" ""
update_env_var "$ETC_ENV" "QT_IM_MODULE" "xim" ""
echo "   [OK] Variáveis globais (GTK/QT) configuradas para XIM."
echo ""

# 3. Configurar o perfil do usuário (~/.profile)
echo "--- CONFIGURANDO VARIÁVEIS DE USUÁRIO (~/.profile) ---"

# Garante que o arquivo .profile exista
touch "$PROFILE_FILE"

# Cria backup do arquivo de perfil do usuário
backup_file "$PROFILE_FILE" 

# Configura o XMODIFIERS e XIM (COM aspas duplas)
update_env_var "$PROFILE_FILE" "XMODIFIERS" "@im=xim" "export"
update_env_var "$PROFILE_FILE" "XIM" "xim" "export"
echo "   [OK] Variáveis de sessão (XMODIFIERS/XIM) configuradas com aspas."
echo ""

echo "==================================================="
echo "✅ INSTALAÇÃO CONCLUÍDA!"
echo "==================================================="
echo "🚨 Ação Necessária:"
echo "As mudanças só serão aplicadas após o reinício da sessão."
echo "Por favor, faça LOGOUT (Sair) ou REINICIE o seu computador agora."