#!/bin/bash

CSV="usuarios.csv"

# Verifica se o script está sendo executado como root
#if [ "$EUID" -ne 0 ]; then
#    echo "Este script precisa ser executado como root."
#    exit 1
#fi

# Verifica se o arquivo CSV existe
if [ ! -f "$CSV" ]; then
    echo "Arquivo '$CSV' não encontrado."
    exit 1
fi

# Função para selecionar usuário do CSV
selecionar_usuario() {
    read -p "Digite o nome de login do usuário: " usuario

    # Verifica se o nome existe no CSV (supondo que está na 2ª coluna)
    if ! awk -F',' -v u="$usuario" '$2 == u {found=1} END {exit !found}' "$CSV"; then
        echo "Usuário '$usuario' não encontrado no arquivo CSV."
        return 1
    fi

    # Verifica se o usuário existe no sistema
    if ! id "$usuario" &>/dev/null; then
        echo "Usuário '$usuario' não existe no sistema."
        return 1
    fi

    echo "Usuário selecionado: $usuario"
    return 0
}

# Funções usando o usuário selecionado
reset_senha() {
    selecionar_usuario || return
    passwd "$usuario"
}

desbloquear_usuario() {
    selecionar_usuario || return
    if usermod -U "$usuario"; then
        echo "Usuário $usuario desbloqueado."
    else
        echo "Erro ao desbloquear o usuário."
    fi
}

desativar_usuario() {
    selecionar_usuario || return
    if usermod -L "$usuario"; then
        echo "Usuário $usuario desativado."
    else
        echo "Erro ao desativar o usuário."
    fi
}

ativar_usuario() {
    selecionar_usuario || return
    if usermod -U "$usuario"; then
        echo "Usuário $usuario ativado."
    else
        echo "Erro ao ativar o usuário."
    fi
}

status_usuario() {
    selecionar_usuario || return
    passwd -S "$usuario"
}

# Menu principal
menu() {
    clear
    echo "Escolha uma das opções abaixo:"
    echo "1 - Reset de senha"
    echo "2 - Desbloquear usuário"
    echo "3 - Desativar usuário"
    echo "4 - Ativar usuário"
    echo "5 - Status do usuário"
    echo "6 - Sair"
    read -p "Digite a opção desejada: " opcao

    case $opcao in
        1) reset_senha ;;
        2) desbloquear_usuario ;;
        3) desativar_usuario ;;
        4) ativar_usuario ;;
        5) status_usuario ;;
        6) echo "Saindo..."; exit 0 ;;
        *) echo "Opção inválida." ;;
    esac
}

# Loop principal
while true; do
    menu
    read -p "Pressione Enter para continuar..." pausa
done
