#!/bin/bash

CSV="usuarios.csv"

# Verifica se o script está sendo executado como root
#if [ "$EUID" -ne 0 ]; then
 #   echo "Este script precisa ser executado como root."
 #   exit 1
#fi

# Verifica se o arquivo CSV existe
if [ ! -f "$CSV" ]; then
    echo "Arquivo '$CSV' não encontrado."
    exit 1
fi

# Solicita o nome de usuário e senha
read -p "Insira seu nome de usuário: " admin_user
read -s -p "Insira sua senha: " admin_pass
echo ""

# Validação simulada
echo "Credenciais inseridas. Verificando permissões..."
sleep 1
echo "Permissão concedida." 

# Função para selecionar usuário
selecionar_usuario() {
    read -p "Digite o nome de login do usuário: " usuario

    if ! grep -q ",$usuario," "$CSV"; then
        echo -e "\e[31mUsuário '$usuario' não encontrado no arquivo CSV.\e[0m"
        return 1
    fi

    if ! id "$usuario" &>/dev/null; then
        echo -e "\e[31mUsuário '$usuario' não existe no sistema.\e[0m"
        return 1
    fi

    return 0
}

# Ações
reset_senha() {
    selecionar_usuario || return
    nova_senha=$(tr -dc 'A-Za-z0-9!@#$%&*' </dev/urandom | head -c 12)
    echo "$usuario:$nova_senha" | chpasswd
    passwd -e "$usuario"
    echo -e "\e[32mSenha redefinida com sucesso. Nova senha: $nova_senha\e[0m"
    echo "$nova_senha" | xclip -selection clipboard 2>/dev/null && echo "(Copiada para área de transferência)"
}

desbloquear_usuario() {
    selecionar_usuario || return
    usermod -U "$usuario" && echo -e "\e[32mUsuário $usuario desbloqueado.\e[0m"
}

desativar_usuario() {
    selecionar_usuario || return
    usermod -L "$usuario" && echo -e "\e[32mUsuário $usuario desativado.\e[0m"
}

ativar_usuario() {
    selecionar_usuario || return
    usermod -U "$usuario" && echo -e "\e[32mUsuário $usuario ativado.\e[0m"
}

status_usuario() {
    selecionar_usuario || return
    info=$(passwd -S "$usuario")
    echo -e "\nStatus do usuário:"
    echo "$info"
}

# Menu
while true; do
    clear
    echo "===================================="
    echo "        GERENCIAMENTO DE USUÁRIO"
    echo "===================================="
    echo "1 - RESET DE SENHA"
    echo "2 - DESBLOQUEAR USUÁRIO"
    echo "3 - DESATIVAR USUÁRIO"
    echo "4 - ATIVAR USUÁRIO"
    echo "5 - STATUS DO USUÁRIO"
    echo "6 - SAIR"
    echo "------------------------------------"
    read -p "Escolha uma opção: " opcao

    case "$opcao" in
        1) reset_senha ;;
        2) desbloquear_usuario ;;
        3) desativar_usuario ;;
        4) ativar_usuario ;;
        5) status_usuario ;;
        6) echo "Saindo..."; exit 0 ;;
        *) echo -e "\e[31mOpção inválida. Tente novamente.\e[0m" ;;
    esac
    echo ""
    read -p "Pressione Enter para continuar..."
done
