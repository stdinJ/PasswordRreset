#!/bin/bash

CSV="usuarios.csv"

# Função para validar se o usuário que executa o script tem permissão (permissao=1 no CSV)
validar_permissao() {
    local user="$1"
    permissao=$(awk -F',' -v u="$user" '$2 == u {print $5}' "$CSV")
    if [[ "$permissao" != "1" ]]; then
        echo -e "\e[31mUsuário '$user' não tem permissão para usar este script.\e[0m"
        return 1
    fi
    return 0
}

# Função para selecionar usuário alvo da ação
selecionar_usuario() {
    read -p "Digite o nome de login do usuário (ex: joaosilva): " usuario
    usuario=$(echo "$usuario" | tr '[:upper:]' '[:lower:]')  # força minúsculas

    # Verifica se usuário está no CSV
    if ! awk -F',' -v u="$usuario" '$2 == u {found=1} END {exit !found}' "$CSV"; then
        echo -e "\e[31mUsuário '$usuario' não encontrado no arquivo CSV.\e[0m"
        return 1
    fi

    # Verifica se usuário existe no sistema
    if ! id "$usuario" &>/dev/null; then
        echo -e "\e[31mUsuário '$usuario' não existe no sistema.\e[0m"
        return 1
    fi

    return 0
}

# Gera senha com padrão: Maiúscula, especial, minúscula, minúscula, número, número
gerar_senha_padrao() {
    maiuscula=$(tr -dc 'A-Z' </dev/urandom | head -c 1)
    especial=$(tr -dc '!@#$%&*' </dev/urandom | head -c 1)
    minusculas=$(tr -dc 'a-z' </dev/urandom | head -c 2)
    numeros=$(tr -dc '0-9' </dev/urandom | head -c 2)
    echo "${maiuscula}${especial}${minusculas}${numeros}"
}

reset_senha() {
    selecionar_usuario || return
    nova_senha=$(gerar_senha_padrao)
    echo "$usuario:$nova_senha" | chpasswd
    passwd -e "$usuario"
    echo -e "\e[32mSenha redefinida com sucesso para '$usuario'. Nova senha: $nova_senha\e[0m"
    echo "$nova_senha" | xclip -selection clipboard 2>/dev/null && echo "(Senha copiada para a área de transferência)"
}

desbloquear_usuario() {
    selecionar_usuario || return
    usermod -U "$usuario" && echo -e "\e[32mUsuário '$usuario' desbloqueado.\e[0m"
}

desativar_usuario() {
    selecionar_usuario || return
    usermod -L "$usuario" && echo -e "\e[32mUsuário '$usuario' desativado.\e[0m"
}

ativar_usuario() {
    selecionar_usuario || return
    usermod -U "$usuario" && echo -e "\e[32mUsuário '$usuario' ativado.\e[0m"
}

status_usuario() {
    selecionar_usuario || return
    info=$(passwd -S "$usuario")
    echo -e "\nStatus do usuário '$usuario':"
    echo "$info"
}

# Verifica se o arquivo CSV existe
if [ ! -f "$CSV" ]; then
    echo "Arquivo '$CSV' não encontrado."
    exit 1
fi

# Solicita login do admin que vai executar o script
read -p "Insira seu nome de usuário para acesso ao script: " admin_user
admin_user=$(echo "$admin_user" | tr '[:upper:]' '[:lower:]')

validar_permissao "$admin_user" || { echo "Acesso negado."; exit 1; }

echo "Permissão concedida. Bem-vindo, $admin_user!"

# Loop do menu
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
