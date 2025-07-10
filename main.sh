#!/bin/bash

CSV="usuarios.csv"

# Função para selecionar usuário do CSV
selecionar_usuario() {
    echo "Usuários disponíveis:"
    tail -n +2 "$CSV" | nl -w2 -s'. ' | cut -d',' -f1 --complement
    echo

    read -p "Digite o número do usuário desejado: " escolha
    usuario=$(tail -n +2 "$CSV" | sed -n "${escolha}p" | cut -d',' -f2)

    if [ -z "$usuario" ]; then
        echo "Opção inválida. Tente novamente."
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
    usermod -U "$usuario"
    echo "Usuário $usuario desbloqueado."
}

desativar_usuario() {
    selecionar_usuario || return
    usermod -L "$usuario"
    echo "Usuário $usuario desativado."
}

ativar_usuario() {
    selecionar_usuario || return
    usermod -U "$usuario"
    echo "Usuário $usuario ativado."
}

status_usuario() {
    selecionar_usuario || return
    passwd -S "$usuario"
}

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

while true; do
    menu
    read -p "Pressione Enter para continuar..." pausa
done
