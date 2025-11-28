# Conteúdo do install.sh (Versão Final Corrigida)
# -------------------------------------------------------------

#!/bin/bash

XCOMPOSE_FILE=".XCompose"
XCOMPOSE_PATH="$HOME/$XCOMPOSE_FILE"
ETC_ENV="/etc/environment"
PROFILE_FILE="$HOME/.profile"

echo "==================================================="
echo "Instalador de Teclado US Intl (Windows) para Linux"
echo "==================================================="

# 1. Copiar o arquivo .XCompose para o diretório HOME
echo "-> Copiando o arquivo $XCOMPOSE_FILE do diretório atual para $HOME/..."

# Verifica se o arquivo está presente no diretório atual antes de copiar
if [ ! -f "$XCOMPOSE_FILE" ]; then
    echo "   [ERRO] O arquivo $XCOMPOSE_FILE não foi encontrado no diretório atual. Abortando."
    echo "   Certifique-se de que o arquivo .XCompose está presente e tente novamente."
    exit 1
fi

cp "$XCOMPOSE_FILE" "$HOME/"

if [ $? -eq 0 ]; then
    echo "   [OK] Arquivo .XCompose copiado e salvo em $HOME/."
else
    echo "   [ERRO] Falha ao copiar o arquivo .XCompose. Abortando."
    exit 1
fi
echo ""

# --- Funções Auxiliares para Manipulação de Variáveis (CORRIGIDA) ---

update_env_var() {
    FILE=$1
    VAR_NAME=$2
    NEW_VALUE=$3
    EXPORT_PREFIX=$4 # Pode ser 'export' para .profile ou vazio para /etc/environment

    # 1. Checa se a variável já existe
    if grep -q "^[[:space:]]*${EXPORT_PREFIX}[[:space:]]*${VAR_NAME}=" "$FILE"; then
        # 2. Se existe, substitui o valor, INCLUINDO AS ASPAS DUPLAS
        echo "-> Atualizando ${VAR_NAME} em $FILE..."
        # Adiciona \" para incluir as aspas duplas no valor
        sudo sed -i "s|^[[:space:]]*${EXPORT_PREFIX}[[:space:]]*${VAR_NAME}=.*|${EXPORT_PREFIX} ${VAR_NAME}=\"${NEW_VALUE}\"|" "$FILE"
    else
        # 3. Se não existe, adiciona no final, INCLUINDO AS ASPAS DUPLAS
        echo "-> Adicionando ${VAR_NAME} em $FILE..."
        # Adiciona \" para incluir as aspas duplas no valor
        echo "${EXPORT_PREFIX} ${VAR_NAME}=\"${NEW_VALUE}\"" | sudo tee -a "$FILE" > /dev/null
    fi
    # Remove linhas vazias ou redundantes que possam ter sido criadas
    sudo sed -i '/^[[:space:]]*$/d' "$FILE"
}

# 2. Configurar o ambiente do sistema (/etc/environment) - Requer sudo
echo "--- CONFIGURANDO VARIÁVEIS GLOBAIS (/etc/environment) ---"
if [ ! -w /etc/environment ]; then
    echo "   [AVISO] O script precisa de permissão de escrita em $ETC_ENV para continuar."
fi

# Variáveis globais (/etc/environment) são definidas SEM aspas duplas (padrão Linux)
update_env_var "$ETC_ENV" "GTK_IM_MODULE" "xim" ""
update_env_var "$ETC_ENV" "QT_IM_MODULE" "xim" ""
echo "   [OK] Variáveis globais (GTK/QT) configuradas para XIM."
echo ""

# 3. Configurar o perfil do usuário (~/.profile)
echo "--- CONFIGURANDO VARIÁVEIS DE USUÁRIO (~/.profile) ---"

# Garante que o arquivo .profile exista
touch "$PROFILE_FILE"

# Configura o XMODIFIERS e XIM (agora COM aspas duplas)
update_env_var "$PROFILE_FILE" "XMODIFIERS" "@im=xim" "export"
update_env_var "$PROFILE_FILE" "XIM" "xim" "export"
echo "   [OK] Variáveis de sessão (XMODIFIERS/XIM) configuradas COM aspas."
echo ""

echo "==================================================="
echo "✅ INSTALAÇÃO CONCLUÍDA!"
echo "==================================================="
echo "🚨 Ação Necessária:"
echo "As mudanças só serão aplicadas após o reinício da sessão."
echo "Por favor, faça LOGOUT (Sair) ou REINICIE o seu computador agora."