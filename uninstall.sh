# Conteúdo do uninstall.sh (Script de Rollback)
# -------------------------------------------------------------

#!/bin/bash

XCOMPOSE_FILE=".XCompose"
XCOMPOSE_PATH="$HOME/$XCOMPOSE_FILE"
ETC_ENV="/etc/environment"
PROFILE_FILE="$HOME/.profile"

echo "==================================================="
echo "Script de Desinstalação (Rollback) XCompose Fedora"
echo "==================================================="
echo "Atenção: Este script irá reverter as alterações nos seguintes arquivos:"
echo " - $XCOMPOSE_PATH"
echo " - $ETC_ENV"
echo " - $PROFILE_FILE"
echo "==================================================="

# --- Funções de Rollback ---

restore_and_cleanup() {
    FILE=$1
    BACKUP_FILE="${FILE}.bak"

    # 1. Tenta restaurar o backup
    if [ -f "$BACKUP_FILE" ]; then
        echo "-> Restaurando backup de $FILE..."
        # Copia o backup de volta para o original (requer sudo para arquivos de sistema)
        sudo cp "$BACKUP_FILE" "$FILE"
        
        # 2. Remove o backup
        echo "   [Limpeza] Removendo arquivo de backup: $BACKUP_FILE"
        sudo rm "$BACKUP_FILE"
        
        echo "   [OK] $FILE restaurado com sucesso."
    else
        echo "-> [AVISO] Backup de $FILE não encontrado ($BACKUP_FILE). Tentando remover as linhas inseridas."
        # Se o backup não existir, tentamos remover as linhas do XIM explicitamente (segurança secundária)
        
        # Expressões para as linhas que procuramos remover:
        VAR_NAMES=("GTK_IM_MODULE" "QT_IM_MODULE" "XMODIFIERS" "XIM")
        
        for VAR in "${VAR_NAMES[@]}"; do
            echo "   [Limpeza] Removendo $VAR de $FILE..."
            # Remove linhas que começam com o nome da variável, ignorando export e aspas
            sudo sed -i "/^[[:space:]]*(export)?[[:space:]]*${VAR}=/d" "$FILE"
        done
        echo "   [AVISO] $FILE modificado para remover variáveis XIM/GTK/QT."
    fi
}

# --- Execução do Rollback ---

# 1. Rollback do Arquivo de Variáveis Globais (/etc/environment)
restore_and_cleanup "$ETC_ENV"
echo ""

# 2. Rollback do Arquivo de Variáveis do Usuário (~/.profile)
restore_and_cleanup "$PROFILE_FILE"
echo ""

# 3. Rollback e Limpeza do Arquivo XCompose
BACKUP_XCOMPOSE="$XCOMPOSE_PATH.bak"

if [ -f "$BACKUP_XCOMPOSE" ]; then
    # Se o backup do XCompose existir, restaura
    restore_and_cleanup "$XCOMPOSE_PATH"
else
    # Se o backup do XCompose NÃO existir, remove o arquivo customizado
    echo "-> Backup de $XCOMPOSE_FILE não encontrado. Removendo arquivo customizado..."
    if [ -f "$XCOMPOSE_PATH" ]; then
        rm "$XCOMPOSE_PATH"
        echo "   [OK] Arquivo $XCOMPOSE_PATH removido."
    else
        echo "   [AVISO] Arquivo $XCOMPOSE_PATH não existia para ser removido."
    fi
fi
echo ""

echo "==================================================="
echo "✅ DESINSTALAÇÃO CONCLUÍDA!"
echo "==================================================="
echo "🚨 Ação Necessária:"
echo "As alterações só serão desfeitas após o reinício da sessão."
echo "Por favor, faça LOGOUT (Sair) ou REINICIE o seu computador agora."