#!/bin/bash

if [ -n "$1" ]; then
    log_file="$1"
else
    read -p "Digite o nome do arquivo a ser analisado: " log_file
fi

if [ ! -f "$log_file" ]; then
    echo "Erro: arquivo nao encontrado: $log_file"
    exit 1
fi

while true; do
    echo ""
    echo "===== ANALISADOR SIMPLES DE LOG ====="
    echo "Arquivo analisado: $log_file"
    echo ""
    echo "1  - Detectar possiveis ataques de XSS"
    echo "2  - Detectar tentativas de SQL Injection"
    echo "3  - Detectar varredura de diretorios (Directory Traversal)"
    echo "4  - Detectar possiveis ataques por scanners (User-Agent suspeito)"
    echo "5  - Identificar tentativas de acesso a arquivos sensiveis (.env, .git, etc.)"
    echo "6  - Detectar possiveis ataques de forca bruta a arquivos/pastas"
    echo "7  - Primeiro e ultimo acesso de um IP suspeito"
    echo "8  - Localizar User-Agent utilizado por um IP suspeito"
    echo "9  - Listar IPs e verificar o numero de requisicoes"
    echo "10 - Localizar acesso a um arquivo especifico"
    echo "0  - Sair"
    echo ""
    read -p "Escolha uma opcao: " opcao
    echo ""

    case "$opcao" in
        1)
            echo "[+] Possiveis ataques de XSS encontrados:"
            grep -iE "<script|%3Cscript" "$log_file"
            ;;
        2)
            echo "[+] Possiveis tentativas de SQL Injection encontradas:"
            grep -iE "union|select|insert|drop|%27|%22" "$log_file"
            ;;
        3)
            echo "[+] Possiveis tentativas de Directory Traversal encontradas:"
            grep -iE "\.\./|\.\.%2f" "$log_file"
            ;;
        4)
            echo "[+] Possiveis acessos com User-Agent suspeito:"
            grep -iE "nikto|nmap|sqlmap|acunetix|curl|masscan|python" "$log_file"
            ;;
        5)
            echo "[+] Tentativas de acesso a arquivos sensiveis:"
            grep -iE "\.env|\.git|\.htaccess|\.bak" "$log_file"
            ;;
        6)
            echo "[+] IPs com maior quantidade de erros 404:"
            grep " 404 " "$log_file" | cut -d " " -f 1 | sort | uniq -c | sort -nr | head
            ;;
        7)
            read -p "Digite o IP suspeito: " ip
            echo ""
            echo "[+] Primeiro acesso encontrado para o IP $ip:"
            grep "$ip" "$log_file" | head -n1
            echo ""
            echo "[+] Ultimo acesso encontrado para o IP $ip:"
            grep "$ip" "$log_file" | tail -n1
            ;;
        8)
            read -p "Digite o IP suspeito: " ip
            echo ""
            echo "[+] User-Agents utilizados pelo IP $ip:"
            grep "$ip" "$log_file" | cut -d '"' -f 6 | sort | uniq
            ;;
        9)
            echo "[+] Lista de IPs e numero de requisicoes:"
            cut -d " " -f 1 "$log_file" | sort | uniq -c | sort -nr
            ;;
        10)
            read -p "Digite o nome do arquivo sensivel: " arquivo
            echo ""
            echo "[+] Acessos encontrados para o arquivo $arquivo:"
            grep -i "$arquivo" "$log_file"
            ;;
        0)
            exit
            ;;
        *)
            echo "Opcao invalida."
            ;;
    esac
done
