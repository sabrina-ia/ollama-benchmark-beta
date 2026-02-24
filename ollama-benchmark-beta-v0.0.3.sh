#!/bin/bash
# =============================================================================
#  ███████  █████  ██████      ████████ ███████ ██████  
#  ██      ██   ██ ██   ██        ██    ██      ██   ██ 
#  ███████ ███████ ██████         ██    █████   ██████  
#       ██ ██   ██ ██   ██        ██    ██      ██      
#  ███████ ██   ██ ██████         ██    ███████ ███████ 
# =============================================================================
# SAB TEC - Tecnologia e Serviços
# Ollama Benchmark Beta | beta-v.0.0.3
# =============================================================================

# =============================================================================
# METADADOS DO PROJETO
# =============================================================================
PROJECT_NAME="Ollama Benchmark Beta"
VERSION="beta-v.0.0.3"
COMPANY="SAB TEC - Tecnologia e Serviços"
CONTACT="sab.tecno.ia@gmail.com"
GITHUB="https://github.com/sabrina-ia"
ISSUES="https://github.com/sabrina-ia"
DEVELOPER="Tiago Sant Anna"
ROLE="AI Engineer | Especialista em LLMs & Agentes Autônomos"
SCRIPT_NAME="ollama-benchmark-${VERSION}.sh"
RELEASE_DATE="2026-02-25"

DESCRIPTION="Script beta para testes de benchmark em modelos locais do Ollama.
Testado em ambiente Ubuntu 24.04 LTS em Hyper-V.
Recursos: Auto-detecção | Auto-chmod | Sudo-check interativo | System Info |
Hyper-V detection | Anti-sobrescrita | Visualização colorida | Sistema de Log |
Fallback sem dependências | Máximo 3 tentativas de instalação."

# =============================================================================
# CONFIGURAÇÃO DE LOG
# =============================================================================
LOG_DIR="./benchmark_logs"
mkdir -p "$LOG_DIR"
LOG_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DEBUG_LOG="${LOG_DIR}/debug_${LOG_TIMESTAMP}.log"
INSTALL_ATTEMPTS=0
MAX_INSTALL_ATTEMPTS=3

# =============================================================================
# FUNÇÃO DE LOG COM TIMESTAMP
# =============================================================================
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$DEBUG_LOG"
}

log_message "INFO" "Iniciando $PROJECT_NAME $VERSION"

# =============================================================================
# FUNÇÃO: MENU DE ERRO COM TIMEOUT
# =============================================================================
error_menu() {
    local error_msg="$1"
    local timeout="${2:-20}"
    
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${SAB_WHITE}                    ❌ ERRO CRÍTICO DETECTADO                           ${RED}║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${SAB_RED}$error_msg${NC}"
    echo ""
    echo -e "${SAB_WHITE}Opções disponíveis:${NC}"
    echo ""
    echo -e "   ${SAB_GREEN}[1]${SAB_WHITE} 🔄 Tentar novamente${NC}"
    echo -e "   ${SAB_GOLD}[2]${SAB_WHITE} 📧 Reportar issue: ${GITHUB}${NC}"
    echo -e "   ${SAB_RED}[3]${SAB_WHITE} 🚪 Sair do script${NC}"
    echo ""
    echo -e "${SAB_GOLD}⏳ Aguardando escolha (${timeout} segundos)...${NC}"
    echo -e "${SAB_GRAY}   O script será encerrado automaticamente após o tempo.${NC}"
    echo ""

    local choice=""
    for ((i=timeout; i>=1; i--)); do
        echo -ne "\r${SAB_GOLD}   Tempo restante: ${SAB_RED}${i}s${SAB_GOLD} | Digite 1, 2 ou 3: ${NC}"
        
        if read -t 1 -n 1 choice 2>/dev/null; then
            echo ""
            case $choice in
                1)
                    log_message "INFO" "Usuário escolheu tentar novamente"
                    return 0
                    ;;
                2)
                    log_message "INFO" "Usuário escolheu reportar issue"
                    echo -e "${SAB_CYAN}📧 Por favor, reporte o erro em:${NC}"
                    echo -e "${SAB_GREEN}   $GITHUB${NC}"
                    echo ""
                    exit 1
                    ;;
                3)
                    log_message "INFO" "Usuário escolheu sair"
                    exit 1
                    ;;
                *)
                    echo -e "${SAB_RED}   Opção inválida.${NC}"
                    i=$((i+1))
                    sleep 0.5
                    ;;
            esac
        fi
    done
    
    echo ""
    log_message "ERROR" "Timeout do menu de erro atingido. Encerrando."
    exit 1
}

# =============================================================================
# CORES BÁSICAS (antes de verificar lolcat)
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# =============================================================================
# VERIFICAÇÃO CORRIGIDA DO LOCAT (incluindo /usr/games)
# =============================================================================
check_lolcat() {
    log_message "INFO" "Verificando lolcat..."
    
    # Verificar se está no PATH padrão
    if command -v lolcat &> /dev/null; then
        log_message "INFO" "lolcat encontrado no PATH padrão"
        return 0
    fi
    
    # Verificar em /usr/games (caminho comum no Ubuntu)
    if [ -x "/usr/games/lolcat" ]; then
        log_message "INFO" "lolcat encontrado em /usr/games, adicionando ao PATH"
        export PATH="$PATH:/usr/games"
        return 0
    fi
    
    # Verificar em /usr/local/games
    if [ -x "/usr/local/games/lolcat" ]; then
        log_message "INFO" "lolcat encontrado em /usr/local/games, adicionando ao PATH"
        export PATH="$PATH:/usr/local/games"
        return 0
    fi
    
    log_message "WARNING" "lolcat não encontrado"
    return 1
}

# =============================================================================
# FUNÇÃO: VERIFICAR E INSTALAR DEPENDÊNCIAS (com máximo 3 tentativas)
# =============================================================================
check_and_install_dependencies() {
    INSTALL_ATTEMPTS=$((INSTALL_ATTEMPTS + 1))
    log_message "INFO" "Tentativa de instalação $INSTALL_ATTEMPTS/$MAX_INSTALL_ATTEMPTS"
    
    if [ $INSTALL_ATTEMPTS -gt $MAX_INSTALL_ATTEMPTS ]; then
        log_message "ERROR" "Máximo de tentativas de instalação atingido"
        error_menu "❌ Máximo de $MAX_INSTALL_ATTEMPTS tentativas de instalação atingido.\n   Verifique sua conexão com a internet e permissões sudo."
        return 1
    fi
    
    local deps=("lolcat" "figlet" "bc" "jq" "dos2unix")
    local missing=()
    local needs_restart=false
    
    echo -e "${CYAN}🔍 Verificando dependências do sistema...${NC}"
    log_message "INFO" "Verificando dependências: ${deps[*]}"
    
    for dep in "${deps[@]}"; do
        if [ "$dep" = "lolcat" ]; then
            if ! check_lolcat; then
                missing+=("$dep")
            fi
        elif ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Dependências ausentes: ${missing[*]}${NC}"
        log_message "WARNING" "Dependências ausentes: ${missing[*]}"
        echo -e "${CYAN}📦 Preparando instalação...${NC}"
        
        if [ "$EUID" -ne 0 ]; then
            echo -e "${YELLOW}🔐 Será necessário privilégio sudo para instalar dependências.${NC}"
            echo -e "${CYAN}⏳ Aguardando 5 segundos... (Ctrl+C para cancelar)${NC}"
            sleep 5
        fi
        
        echo -e "${CYAN}🔄 Atualizando repositórios do sistema...${NC}"
        log_message "INFO" "Atualizando repositórios"
        if ! sudo apt-get update -qq; then
            echo -e "${RED}❌ Falha ao atualizar repositórios${NC}"
            log_message "ERROR" "Falha ao atualizar repositórios"
            error_menu "❌ Falha ao atualizar repositórios do sistema.\n   Verifique sua conexão com a internet."
            return 1
        fi
        
        echo -e "${CYAN}⬆️  Atualizando pacotes existentes...${NC}"
        log_message "INFO" "Atualizando pacotes existentes"
        sudo apt-get upgrade -y -qq || {
            echo -e "${YELLOW}⚠️  Alguns pacotes não puderam ser atualizados${NC}"
            log_message "WARNING" "Alguns pacotes não puderam ser atualizados"
        }
        
        echo -e "${CYAN}📦 Instalando dependências: ${missing[*]}${NC}"
        log_message "INFO" "Instalando: ${missing[*]}"
        if ! sudo apt-get install -y "${missing[@]}"; then
            echo -e "${RED}❌ Falha na instalação de dependências${NC}"
            log_message "ERROR" "Falha na instalação de dependências"
            
            echo -e "${YELLOW}🔄 Tentativa $INSTALL_ATTEMPTS falhou. Tentando novamente...${NC}"
            sleep 3
            check_and_install_dependencies
            return $?
        fi
        
        needs_restart=true
        echo -e "${GREEN}✅ Todas as dependências instaladas com sucesso!${NC}"
        log_message "INFO" "Dependências instaladas com sucesso"
        
        # Re-verificar lolcat após instalação
        if ! check_lolcat; then
            log_message "WARNING" "lolcat instalado mas não encontrado no PATH, tentando localizar..."
            # Tentar encontrar e linkar
            if [ -f "/usr/games/lolcat" ]; then
                sudo ln -sf /usr/games/lolcat /usr/local/bin/lolcat 2>/dev/null || true
                export PATH="$PATH:/usr/games"
            fi
        fi
    else
        echo -e "${GREEN}✅ Todas as dependências já estão instaladas${NC}"
        log_message "INFO" "Todas as dependências já estão instaladas"
    fi
    
    if command -v dos2unix &> /dev/null; then
        if file "$0" | grep -q "CRLF"; then
            echo -e "${CYAN}🔧 Convertendo script para formato Unix...${NC}"
            log_message "INFO" "Convertendo script para formato Unix"
            dos2unix "$0" 2>/dev/null
            needs_restart=true
        fi
    fi
    
    if [ "$needs_restart" = true ]; then
        echo -e "${GREEN}🔄 Reiniciando script com dependências atualizadas...${NC}"
        log_message "INFO" "Reiniciando script após instalação de dependências"
        sleep 2
        exec bash "$0" "$@"
    fi
    
    return 0
}

# =============================================================================
# VERIFICAÇÃO DE PERMISSÕES (AUTO-CHMOD)
# =============================================================================
if [ ! -x "$0" ]; then
    echo -e "${YELLOW}⚠️  Script sem permissão de execução detectado${NC}"
    log_message "WARNING" "Script sem permissão de execução"
    
    if chmod +x "$0" 2>/dev/null; then
        echo -e "${GREEN}✅ Permissão aplicada automaticamente. Reiniciando...${NC}"
        log_message "INFO" "Permissão de execução aplicada automaticamente"
        exec bash "$0" "$@"
    else
        echo -e "${RED}❌ ERRO CRÍTICO: Não foi possível aplicar permissão de execução!${NC}"
        log_message "ERROR" "Não foi possível aplicar permissão de execução"
        
        if [ "$EUID" -ne 0 ]; then
            echo ""
            echo -e "${YELLOW}⏳ Aguardando 10 segundos...${NC}"
            
            for i in {10..1}; do
                echo -ne "\r${YELLOW}   Continuando em $i segundos... (Ctrl+C para cancelar)${NC}"
                sleep 1
            done
            echo ""
            echo ""
            
            if ! chmod +x "$0" 2>/dev/null; then
                echo -e "${RED}❌ FALHA: Execute manualmente:${NC}"
                echo -e "${RED}   sudo chmod +x $SCRIPT_NAME && sudo ./$SCRIPT_NAME${NC}"
                log_message "ERROR" "Falha ao aplicar permissão mesmo após espera"
                exit 1
            fi
        else
            exit 1
        fi
    fi
fi

# =============================================================================
# INSTALAR DEPENDÊNCIAS
# =============================================================================
check_and_install_dependencies

# =============================================================================
# AGORA PODEMOS USAR CORES AVANÇADAS (com fallback se lolcat falhar)
# =============================================================================
SAB_BLUE='\033[38;5;33m'
SAB_CYAN='\033[38;5;87m'
SAB_GREEN='\033[38;5;82m'
SAB_GOLD='\033[38;5;220m'
SAB_ORANGE='\033[38;5;208m'
SAB_RED='\033[38;5;196m'
SAB_WHITE='\033[38;5;255m'
SAB_GRAY='\033[38;5;245m'
NC='\033[0m'

# Flag para controle de fallback
USE_COLORS=true
if ! check_lolcat; then
    USE_COLORS=false
    log_message "WARNING" "Usando modo fallback sem lolcat"
fi

# =============================================================================
# FUNÇÃO: IMPRIMIR CABEÇALHO CORPORATIVO (com fallback)
# =============================================================================
print_header() {
    clear
    echo ""
    
    if [ "$USE_COLORS" = true ] && command -v figlet &> /dev/null && check_lolcat; then
        figlet -f slant "SAB TEC" | lolcat
    else
        echo -e "${SAB_CYAN}"
        echo "  ███████  █████  ██████      ████████ ███████ ██████ "
        echo "  ██      ██   ██ ██   ██        ██    ██      ██   ██"
        echo "  ███████ ███████ ██████         ██    █████   ██████ "
        echo "       ██ ██   ██ ██   ██        ██    ██      ██     "
        echo "  ███████ ██   ██ ██████         ██    ███████ ███████"
        echo -e "${NC}"
    fi
    
    echo -e "${SAB_BLUE}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${SAB_BLUE}║${SAB_GOLD}  ${COMPANY}${NC}"
    echo -e "${SAB_BLUE}╠══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${SAB_BLUE}║${SAB_CYAN}  📋 PROJETO:${SAB_WHITE}  ${PROJECT_NAME}${NC}"
    echo -e "${SAB_BLUE}║${SAB_CYAN}  🏷️  VERSÃO:${SAB_WHITE}   ${VERSION}${NC}"
    echo -e "${SAB_BLUE}║${SAB_CYAN}  📅 RELEASE:${SAB_WHITE}  ${RELEASE_DATE}${NC}"
    echo -e "${SAB_BLUE}╠══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${SAB_BLUE}║${SAB_GREEN}  👤 DESENVOLVEDOR:${SAB_WHITE} ${DEVELOPER}${NC}"
    echo -e "${SAB_BLUE}║${SAB_GREEN}  🎯 ESPECIALIDADE:${SAB_WHITE}  ${ROLE}${NC}"
    echo -e "${SAB_BLUE}╠══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${SAB_BLUE}║${SAB_GOLD}  📧 CONTATO:${SAB_WHITE}  ${CONTACT}${NC}"
    echo -e "${SAB_BLUE}║${SAB_GOLD}  🐙 GITHUB:${SAB_WHITE}   ${GITHUB}${NC}"
    echo -e "${SAB_BLUE}║${SAB_GOLD}  🐛 ISSUES:${SAB_WHITE}   ${ISSUES}${NC}"
    echo -e "${SAB_BLUE}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# =============================================================================
# FUNÇÃO: IMPRIMIR DESCRIÇÃO TÉCNICA
# =============================================================================
print_description() {
    echo -e "${SAB_CYAN}┌─────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${SAB_CYAN}│${SAB_WHITE} 📖 DESCRIÇÃO TÉCNICA${NC}"
    echo -e "${SAB_CYAN}├─────────────────────────────────────────────────────────────────────────┤${NC}"
    
    echo "$DESCRIPTION" | fold -s -w 70 | while read line; do
        printf "${SAB_CYAN}│${SAB_GRAY} %-71s${SAB_CYAN}│${NC}\n" "$line"
    done
    
    echo -e "${SAB_CYAN}└─────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

# =============================================================================
# MENU INTERATIVO SUDO
# =============================================================================
print_header
print_description

if [ "$EUID" -eq 0 ]; then
    echo -e "${SAB_GREEN}✅ Você já está executando como root/sudo!${NC}"
    echo -e "${SAB_GREEN}   A limpeza de cache será automática sem solicitar senha.${NC}"
    SUDO_MODE="AUTO"
    log_message "INFO" "Executando como root/sudo"
    sleep 3
else
    echo -e "${SAB_ORANGE}╔════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${SAB_ORANGE}║${SAB_WHITE}                    🔐 CONFIGURAÇÃO DE PRIVILÉGIOS SUDO                 ${SAB_ORANGE}║${NC}"
    echo -e "${SAB_ORANGE}╚════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${SAB_ORANGE}⚠️  Você NÃO está executando como sudo.${NC}"
    echo -e "${SAB_GRAY}   Durante o benchmark, a limpeza de cache a cada 3 modelos requer privilégios.${NC}"
    echo ""
    echo -e "${SAB_WHITE}Escolha uma opção:${NC}"
    echo ""
    echo -e "   ${SAB_GREEN}[1]${SAB_WHITE} 🔐 Logar como sudo ${SAB_GREEN}AGORA${SAB_WHITE} (senha solicitada uma única vez)${NC}"
    echo -e "   ${SAB_GOLD}[2]${SAB_WHITE} 🚪 Encerrar e executar manualmente: ${SAB_GOLD}sudo ./${SCRIPT_NAME}${NC}"
    echo -e "   ${SAB_RED}[3]${SAB_WHITE} ⚠️  Continuar sem sudo (senha solicitada a cada limpeza de cache)${NC}"
    echo ""
    echo -e "${SAB_GOLD}⏳ Aguardando escolha (20 segundos)...${NC}"
    echo -e "${SAB_GRAY}   O script continuará automaticamente com a opção [3] após o tempo.${NC}"
    echo ""

    SUDO_MODE="MANUAL"
    for ((i=20; i>=1; i--)); do
        echo -ne "\r${SAB_GOLD}   Tempo restante: ${SAB_ORANGE}${i}s${SAB_GOLD} | Digite 1, 2 ou 3: ${NC}"
        
        if read -t 1 -n 1 escolha 2>/dev/null; then
            echo ""
            case $escolha in
                1)
                    echo -e "${SAB_CYAN}🔐 Solicitando senha sudo...${NC}"
                    log_message "INFO" "Usuário escolheu logar como sudo"
                    if sudo -v 2>/dev/null; then
                        echo -e "${SAB_GREEN}✅ Autenticação sudo bem-sucedida!${NC}"
                        log_message "INFO" "Autenticação sudo bem-sucedida"
                        SUDO_MODE="AUTO"
                        echo -e "${SAB_GREEN}🔄 Reiniciando script com privilégios sudo...${NC}"
                        sleep 2
                        exec sudo bash "$0" "$@"
                    else
                        echo -e "${SAB_RED}❌ Falha na autenticação sudo.${NC}"
                        log_message "ERROR" "Falha na autenticação sudo"
                        echo -e "${SAB_ORANGE}⚠️  Continuando sem privilégios elevados...${NC}"
                        SUDO_MODE="MANUAL"
                    fi
                    break
                    ;;
                2)
                    echo -e "${SAB_GOLD}🚪 Encerrando script...${NC}"
                    log_message "INFO" "Usuário escolheu encerrar para executar manualmente"
                    echo ""
                    echo -e "${SAB_CYAN}💡 Execute manualmente:${NC}"
                    echo -e "${SAB_GREEN}   sudo ./${SCRIPT_NAME}${NC}"
                    echo ""
                    exit 0
                    ;;
                3)
                    echo -e "${SAB_ORANGE}⚠️  Continuando sem sudo.${NC}"
                    log_message "INFO" "Usuário escolheu continuar sem sudo"
                    echo -e "${SAB_GRAY}   Atenção: A senha será solicitada a cada limpeza de cache!${NC}"
                    SUDO_MODE="MANUAL"
                    sleep 3
                    break
                    ;;
                *)
                    echo -e "${SAB_RED}   Opção inválida. Use 1, 2 ou 3.${NC}"
                    i=$((i+1))
                    sleep 0.5
                    ;;
            esac
        fi
    done
    
    if [ "$SUDO_MODE" = "MANUAL" ] && [ "$i" -eq 0 ]; then
        echo ""
        echo -e "${SAB_ORANGE}⏱️  Tempo esgotado. Continuando sem sudo...${NC}"
        log_message "INFO" "Timeout do menu sudo, continuando sem privilégios"
        sleep 2
    fi
fi

echo ""
echo -e "${SAB_GREEN}▶ Iniciando benchmark...${NC}"
log_message "INFO" "Iniciando benchmark"
echo ""

set -e

# =============================================================================
# CAPTURA DE INFORMAÇÕES DO SISTEMA
# =============================================================================
echo -e "${SAB_CYAN}🔍 Analisando ambiente de execução...${NC}"
log_message "INFO" "Analisando ambiente de execução"

detectar_virtualizacao() {
    local virt="Bare Metal (Fisico)"
    local virt_type="N/A"
    local host_os="N/A"
    
    if [ -d "/sys/bus/vmbus" ] || [ -d "/sys/class/vmbus" ]; then
        virt="Hyper-V (Microsoft)"
        virt_type="VM"
        host_os="Windows (provavel)"
    fi
    
    if grep -q "hypervisor" /proc/cpuinfo 2>/dev/null; then
        if grep -q "Microsoft" /proc/cpuinfo 2>/dev/null; then
            virt="Hyper-V"
            virt_type="VM"
        fi
    fi
    
    if [ -f "/sys/class/dmi/id/product_name" ]; then
        local dmi=$(cat /sys/class/dmi/id/product_name 2>/dev/null)
        if echo "$dmi" | grep -qi "virtual"; then
            virt="Hyper-V"
            virt_type="VM"
        fi
    fi
    
    if command -v systemd-detect-virt &> /dev/null; then
        local sd_virt=$(systemd-detect-virt 2>/dev/null || echo "none")
        if [ "$sd_virt" != "none" ]; then
            virt="$sd_virt"
            virt_type="VM"
            [ "$sd_virt" = "microsoft" ] && virt="Hyper-V" && host_os="Windows"
        fi
    fi
    
    if command -v lscpu &> /dev/null; then
        local hypervisor=$(lscpu 2>/dev/null | grep -i "hypervisor vendor" | awk -F': ' '{print $2}' | xargs)
        if [ -n "$hypervisor" ]; then
            virt="$hypervisor"
            virt_type="VM"
            [ "$hypervisor" = "Microsoft" ] && virt="Hyper-V" && host_os="Windows"
        fi
    fi
    
    echo "$virt|$virt_type|$host_os"
}

SYS_INFO=$(detectar_virtualizacao)
SYS_VIRT=$(echo "$SYS_INFO" | cut -d'|' -f1)
SYS_VIRT_TYPE=$(echo "$SYS_INFO" | cut -d'|' -f2)
SYS_HOST_OS=$(echo "$SYS_INFO" | cut -d'|' -f3)

SYS_OS=$(lsb_release -d -s 2>/dev/null || cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Desconhecido")
SYS_KERNEL=$(uname -r)
SYS_ARCH=$(uname -m)
SYS_CPU=$(grep 'model name' /proc/cpuinfo 2>/dev/null | head -1 | cut -d':' -f2 | xargs || echo "N/A")
SYS_CPU_CORES=$(nproc 2>/dev/null || echo "N/A")
SYS_RAM_TOTAL=$(free -h 2>/dev/null | awk 'NR==2{print $2}' || echo "N/A")
SYS_RAM_AVAILABLE=$(free -h 2>/dev/null | awk 'NR==2{print $7}' || echo "N/A")
SYS_OLLAMA_VERSION=$(ollama --version 2>/dev/null || echo "N/A")

log_message "INFO" "Sistema: $SYS_OS | Kernel: $SYS_KERNEL | Virt: $SYS_VIRT | CPU: $SYS_CPU_CORES cores"

# =============================================================================
# CONFIGURAÇÃO DE DIRETÓRIOS - CORREÇÃO: USA DIRETÓRIO DO SCRIPT
# =============================================================================

# Detecta o diretório onde o script está localizado (não onde está sendo executado)
if [ -n "$BASH_SOURCE" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

# Se não conseguir detectar, usa o diretório atual
if [ -z "$SCRIPT_DIR" ] || [ ! -d "$SCRIPT_DIR" ]; then
    SCRIPT_DIR="$(pwd)"
fi

RESULTS_DIR="${SCRIPT_DIR}/benchmark_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Tenta criar o diretório com tratamento de erro
if ! mkdir -p "$RESULTS_DIR" 2>/dev/null; then
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${SAB_WHITE}                     ❌ ERRO AO CRIAR DIRETÓRIO                         ${RED}║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}Não foi possível criar o diretório de resultados:${NC}"
    echo -e "${RED}  ${RESULTS_DIR}${NC}"
    echo ""
    echo -e "${SAB_YELLOW}Possíveis causas:${NC}"
    echo -e "  • Sem permissão de escrita no diretório: ${SCRIPT_DIR}"
    echo -e "  • Diretório protegido por permissões do sistema"
    echo -e "  • Filesystem montado como somente leitura"
    echo ""
    echo -e "${SAB_CYAN}Soluções sugeridas:${NC}"
    echo -e "  1. Execute o script com sudo: ${SAB_GREEN}sudo ${SCRIPT_DIR}/${SCRIPT_NAME}${NC}"
    echo -e "  2. Altere as permissões: ${SAB_GREEN}sudo chown -R $(whoami) '${SCRIPT_DIR}'${NC}"
    echo -e "  3. Execute de um diretório com permissão de escrita (ex: /tmp ou ~)"
    echo ""
    echo -e "${SAB_GOLD}Diretório do script detectado:${NC} ${SCRIPT_DIR}"
    echo -e "${SAB_GOLD}Usuário atual:${NC} $(whoami)"
    echo -e "${SAB_GOLD}Permissões do diretório:${NC}"
    ls -ld "${SCRIPT_DIR}" 2>/dev/null || echo "  (não foi possível verificar)"
    echo ""
    exit 1
fi

# Verifica se tem permissão de escrita no diretório criado
if [ ! -w "$RESULTS_DIR" ]; then
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${SAB_WHITE}                  ❌ SEM PERMISSÃO DE ESCRITA                            ${RED}║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${RED}O diretório foi criado, mas sem permissão de escrita:${NC}"
    echo -e "${RED}  ${RESULTS_DIR}${NC}"
    echo ""
    echo -e "${SAB_CYAN}Execute com sudo ou verifique as permissões:${NC}"
    echo -e "  ${SAB_GREEN}sudo ${SCRIPT_DIR}/${SCRIPT_NAME}${NC}"
    echo ""
    exit 1
fi

echo -e "${SAB_GREEN}✅ Diretório de resultados configurado:${NC}"
echo -e "   ${RESULTS_DIR}"
echo ""

COUNTER=1
RESULTS_FILE="${RESULTS_DIR}/benchmark_beta_${VERSION}_${TIMESTAMP}.csv"
while [ -f "$RESULTS_FILE" ]; do
    RESULTS_FILE="${RESULTS_DIR}/benchmark_beta_${VERSION}_${TIMESTAMP}_${COUNTER}.csv"
    COUNTER=$((COUNTER + 1))
done

LOG_FILE="${RESULTS_FILE%.csv}.log"
SYSINFO_FILE="${RESULTS_FILE%.csv}_sysinfo.txt"

log_message "INFO" "Arquivos de saída: CSV=$RESULTS_FILE, LOG=$LOG_FILE, SYSINFO=$SYSINFO_FILE"

# =============================================================================
# SALVAR INFORMAÇÕES DO SISTEMA E EMPRESA
# =============================================================================
{
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                    SAB TEC - TECNOLOGIA E SERVIÇOS                       ║"
echo "║              Ollama Benchmark Beta - Relatório de Sistema                ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "METADADOS DO PROJETO:"
echo "  Nome:        ${PROJECT_NAME}"
echo "  Versão:      ${VERSION}"
echo "  Release:     ${RELEASE_DATE}"
echo "  Script:      ${SCRIPT_NAME}"
echo ""
echo "DESENVOLVEDOR:"
echo "  Nome:        ${DEVELOPER}"
echo "  Especialidade: ${ROLE}"
echo ""
echo "CONTATO:"
echo "  Email:       ${CONTACT}"
echo "  GitHub:      ${GITHUB}"
echo "  Issues:      ${ISSUES}"
echo ""
echo "═══════════════════════════════════════════════════════════════════════════"
echo "INFORMAÇÕES DO SISTEMA"
echo "═══════════════════════════════════════════════════════════════════════════"
echo "  Data/Hora:   $(date '+%Y-%m-%d %H:%M:%S')"
echo "  Modo Sudo:   ${SUDO_MODE}"
echo ""
echo "SISTEMA OPERACIONAL:"
echo "  OS:          ${SYS_OS}"
echo "  Kernel:      ${SYS_KERNEL}"
echo "  Arquitetura: ${SYS_ARCH}"
echo ""
echo "VIRTUALIZAÇÃO:"
echo "  Tipo:        ${SYS_VIRT}"
echo "  Classificação: ${SYS_VIRT_TYPE}"
echo "  Host OS:     ${SYS_HOST_OS}"
echo ""
echo "HARDWARE:"
echo "  CPU:         ${SYS_CPU}"
echo "  Cores:       ${SYS_CPU_CORES}"
echo "  RAM Total:   ${SYS_RAM_TOTAL}"
echo "  RAM Disp.:   ${SYS_RAM_AVAILABLE}"
echo ""
echo "OLLAMA:"
echo "  Versão:      ${SYS_OLLAMA_VERSION}"
echo ""
echo "ARQUIVOS DE SAÍDA:"
echo "  CSV:         ${RESULTS_FILE}"
echo "  LOG:         ${LOG_FILE}"
echo "  SYSINFO:     ${SYSINFO_FILE}"
echo "  DEBUG:       ${DEBUG_LOG}"
echo "═══════════════════════════════════════════════════════════════════════════"
} > "$SYSINFO_FILE"

# =============================================================================
# HEADER DE EXECUÇÃO
# =============================================================================
print_header

echo -e "${SAB_CYAN}┌─────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${SAB_CYAN}│${SAB_WHITE} 🖥️  AMBIENTE DE EXECUÇÃO${NC}"
echo -e "${SAB_CYAN}├─────────────────────────────────────────────────────────────────────────┤${NC}"
echo -e "${SAB_CYAN}│${SAB_GRAY}  Diretório:  ${SAB_WHITE}${SCRIPT_DIR}${NC}"
echo -e "${SAB_CYAN}│${SAB_GRAY}  Sistema:    ${SAB_WHITE}${SYS_OS}${NC}"
echo -e "${SAB_CYAN}│${SAB_GRAY}  Kernel:     ${SAB_WHITE}${SYS_KERNEL}${NC}"
echo -e "${SAB_CYAN}│${SAB_GRAY}  Virtual:    ${SAB_WHITE}${SYS_VIRT}${NC}"
[ "$SYS_VIRT_TYPE" = "VM" ] && echo -e "${SAB_CYAN}│${SAB_GRAY}  Host:       ${SAB_WHITE}${SYS_HOST_OS}${NC}"
echo -e "${SAB_CYAN}│${SAB_GRAY}  CPU:        ${SAB_WHITE}${SYS_CPU_CORES} cores${NC}"
echo -e "${SAB_CYAN}│${SAB_GRAY}  RAM:        ${SAB_WHITE}${SYS_RAM_TOTAL}${NC}"
echo -e "${SAB_CYAN}│${SAB_GRAY}  Ollama:     ${SAB_WHITE}${SYS_OLLAMA_VERSION}${NC}"
echo -e "${SAB_CYAN}│${SAB_GRAY}  Modo:       ${SAB_GREEN}${SUDO_MODE}${NC}"
echo -e "${SAB_CYAN}│${SAB_GRAY}  Log:        ${SAB_WHITE}${DEBUG_LOG}${NC}"
echo -e "${SAB_CYAN}└─────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""

# =============================================================================
# AUTO-DETECÇÃO DE MODELOS
# =============================================================================
echo -e "${SAB_CYAN}🔍 Detectando modelos instalados no Ollama...${NC}"
log_message "INFO" "Detectando modelos instalados no Ollama"

MODELS_ARRAY=()

while IFS= read -r line; do
    [ -z "$line" ] && continue
    [ "$line" = "NAME" ] && continue
    
    modelo=$(echo "$line" | awk '{print $1}')
    [ -z "$modelo" ] && continue
    
    if echo "$modelo" | grep -q ":cloud$"; then
        echo -e "  ${SAB_CYAN}☁️  Pulando cloud:${NC} $modelo"
        log_message "INFO" "Pulando modelo cloud: $modelo"
        continue
    fi
    
    MODELS_ARRAY+=("$modelo")
    
done < <(ollama list 2>/dev/null | tail -n +2)

if [ ${#MODELS_ARRAY[@]} -eq 0 ]; then
    echo -e "${SAB_RED}❌ Nenhum modelo local detectado!${NC}"
    log_message "ERROR" "Nenhum modelo local detectado"
    error_menu "❌ Nenhum modelo local detectado no Ollama!\n   Instale modelos com: ollama pull <modelo>"
    exit 1
fi

echo -e "${SAB_GREEN}✅ ${#MODELS_ARRAY[@]} modelo(s) detectado(s):${NC}"
log_message "INFO" "${#MODELS_ARRAY[@]} modelo(s) detectado(s)"
for m in "${MODELS_ARRAY[@]}"; do
    echo -e "   ${SAB_CYAN}•${NC} $m"
    log_message "INFO" "Modelo detectado: $m"
done
echo ""

# =============================================================================
# CONFIGURAÇÃO DOS TESTES
# =============================================================================
TEST_PROMPTS=(
    "O que é RAG em inteligência artificial? Explique de forma simples."
    "Se 3 máquinas produzem 3 peças em 3 minutos, quantas máquinas são necessárias para produzir 100 peças em 100 minutos? Explique o raciocínio."
    "O céu é verde? Responda apenas SIM ou NAO."
)

echo "modelo,teste_num,tempo_ms,tk_seg,memoria_mb,resposta_correta,resumo_resposta,timestamp,versao_script,os_info,virt_info,empresa,desenvolvedor" > "$RESULTS_FILE"

{
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                    SAB TEC - TECNOLOGIA E SERVIÇOS                       ║"
echo "║                        LOG DE EXECUÇÃO                                   ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Projeto:    ${PROJECT_NAME}"
echo "Versão:     ${VERSION}"
echo "Início:     $(date '+%Y-%m-%d %H:%M:%S')"
echo "Desenv.:    ${DEVELOPER} | ${ROLE}"
echo "Contato:    ${CONTACT}"
echo "GitHub:     ${GITHUB}"
echo "Issues:     ${ISSUES}"
echo "Sistema:    ${SYS_OS} | ${SYS_KERNEL}"
echo "Virtual:    ${SYS_VIRT}"
echo "Hardware:   ${SYS_CPU_CORES} cores | ${SYS_RAM_TOTAL} RAM"
echo "Modelos:    ${#MODELS_ARRAY[@]}"
echo "Arquivo:    ${RESULTS_FILE}"
echo "Log Debug:  ${DEBUG_LOG}"
echo "═══════════════════════════════════════════════════════════════════════════"
} | tee "$LOG_FILE"

echo -e "${SAB_GOLD}📅 Início:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "${SAB_GOLD}📝 Resultados:${NC} ${RESULTS_FILE}"
echo -e "${SAB_GOLD}📋 Log Debug:${NC} ${DEBUG_LOG}"
echo ""

total_start=$(date +%s)

# =============================================================================
# LOOP DE TESTES
# =============================================================================
model_count=0

for model in "${MODELS_ARRAY[@]}"; do
    model_count=$((model_count + 1))
    
    echo -e "${SAB_BLUE}─────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "${SAB_GOLD}📦 Modelo ${model_count}/${#MODELS_ARRAY[@]}:${NC} ${SAB_CYAN}${model}${NC}"
    log_message "INFO" "Iniciando testes para modelo: $model ($model_count/${#MODELS_ARRAY[@]})"
    
    if ! ollama list | grep -q "^${model}"; then
        echo -e "${SAB_RED}❌ Modelo não encontrado! Pulando...${NC}" | tee -a "$LOG_FILE"
        log_message "ERROR" "Modelo não encontrado: $model"
        echo "$model,0,0,0,0,NAO_ENCONTRADO,,$(date +%s),${VERSION},\"$SYS_OS\",\"$SYS_VIRT\",\"$COMPANY\",\"$DEVELOPER\"" >> "$RESULTS_FILE"
        continue
    fi
    
    model_size=$(ollama list | grep "^${model}" | awk '{print $3}' || echo "N/A")
    echo -e "${SAB_GREEN}✅ Disponível${NC} | Tamanho: ${SAB_CYAN}${model_size}${NC}"
    log_message "INFO" "Modelo $model disponível, tamanho: $model_size"
    
    echo -e "${SAB_ORANGE}🔥 Warm-up...${NC}"
    curl -s http://localhost:11434/api/generate \
        -d "{\"model\": \"$model\", \"prompt\": \"Oi\", \"stream\": false, \"options\": {\"num_ctx\": 2048}}" \
        > /dev/null 2>&1 || {
        echo -e "${SAB_ORANGE}⚠️  Warm-up falhou, continuando...${NC}"
        log_message "WARNING" "Warm-up falhou para modelo: $model"
    }
    sleep 2
    
    model_start=$(date +%s)
    
    for i in "${!TEST_PROMPTS[@]}"; do
        test_num=$((i + 1))
        prompt="${TEST_PROMPTS[$i]}"
        
        echo -e "  📝 Teste $test_num/3"
        log_message "INFO" "Executando teste $test_num/3 para $model"
        
        mem_before=$(free -m | awk 'NR==2{print $3}')
        
        start_time=$(date +%s%N)
        
        response=$(curl -s --max-time 600 \
            http://localhost:11434/api/generate \
            -H "Content-Type: application/json" \
            -d "{\"model\": \"$model\", \"prompt\": \"$prompt\", \"stream\": false, \"options\": {\"temperature\": 0.7, \"num_ctx\": 4096}}" 2>/dev/null) || {
            echo -e "${SAB_RED}    ❌ Timeout ou erro na requisição${NC}"
            log_message "ERROR" "Timeout ou erro na requisição para $model teste $test_num"
            echo "$model,$test_num,0,0,0,TIMEOUT,,$(date +%s),${VERSION},\"$SYS_OS\",\"$SYS_VIRT\",\"$COMPANY\",\"$DEVELOPER\"" >> "$RESULTS_FILE"
            continue
        }
        
        end_time=$(date +%s%N)
        
        elapsed_ns=$((end_time - start_time))
        elapsed_ms=$((elapsed_ns / 1000000))
        eval_count=$(echo "$response" | jq -r '.eval_count // 0')
        generated_text=$(echo "$response" | jq -r '.response // "null"' | head -c 250 | tr '\n' ' ' | sed 's/"/""/g')
        
        if [ "$elapsed_ms" -gt 0 ] && [ "$eval_count" -gt 0 ]; then
            tps=$(awk "BEGIN {printf \"%.2f\", ($eval_count / $elapsed_ms) * 1000}")
        else
            tps="0.00"
        fi
        
        mem_after=$(free -m | awk 'NR==2{print $3}')
        mem_used=$((mem_after - mem_before))
        [ "$mem_used" -lt 0 ] && mem_used=0
        
        resposta_correta="ANALISAR"
        case $test_num in
            1) 
                if echo "$generated_text" | grep -qi "retrieval.*augmented\|recuperação.*aumentada"; then
                    resposta_correta="SIM"
                elif echo "$generated_text" | grep -qi "representação\|gramática\|reasoning\|research.*assistant"; then
                    resposta_correta="NAO"
                else
                    resposta_correta="PARCIAL"
                fi
                ;;
            2) 
                if echo "$generated_text" | grep -qE '(^|[^0-9])3([^0-9]|$)' && ! echo "$generated_text" | grep -qE '(^|[^0-9])100([^0-9]|$)'; then
                    resposta_correta="SIM"
                elif echo "$generated_text" | grep -qE '(^|[^0-9])100([^0-9]|$)'; then
                    resposta_correta="NAO"
                else
                    resposta_correta="VERIFICAR"
                fi
                ;;
            3) 
                if echo "$generated_text" | grep -qiE '^nao$|^não$|\bnao\b|\bnão\b'; then
                    resposta_correta="SIM"
                elif echo "$generated_text" | grep -qiE '^sim$|\bsim\b'; then
                    resposta_correta="NAO"
                else
                    resposta_correta="VERIFICAR"
                fi
                ;;
        esac
        
        echo "$model,$test_num,$elapsed_ms,$tps,$mem_used,$resposta_correta,\"$generated_text\",$(date +%s),${VERSION},\"$SYS_OS\",\"$SYS_VIRT\",\"$COMPANY\",\"$DEVELOPER\"" >> "$RESULTS_FILE"
        
        echo -e "    ${SAB_GREEN}⏱️  ${elapsed_ms}ms${NC} | ${SAB_GREEN}🚀 ${tps} tk/s${NC} | ${SAB_ORANGE}🧠 ${mem_used}MB${NC} | ${SAB_CYAN}✓ $resposta_correta${NC}"
        log_message "INFO" "Teste $test_num concluído: ${elapsed_ms}ms, ${tps} tk/s, ${mem_used}MB, resposta: $resposta_correta"
        
        sleep 3
    done
    
    model_end=$(date +%s)
    model_duration=$((model_end - model_start))
    
    echo -e "${SAB_BLUE}  ⏹️  Concluído em ${model_duration}s${NC}"
    echo "  Modelo $model: ${model_duration}s" >> "$LOG_FILE"
    log_message "INFO" "Modelo $model concluído em ${model_duration}s"
    
    # LIMPEZA DE CACHE COM TRATAMENTO DE SUDO
    if [ $((model_count % 3)) -eq 0 ]; then
        echo "  🧹 Limpando cache..."
        log_message "INFO" "Limpando cache de memória (modelo $model_count)"
        
        if [ "$SUDO_MODE" = "AUTO" ]; then
            sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null 2>&1 || true
            echo -e "    ${SAB_GREEN}✅ Cache limpo (sudo automático)${NC}"
            log_message "INFO" "Cache limpo com sudo automático"
        else
            echo -e "    ${SAB_ORANGE}⚠️  Modo manual: senha sudo pode ser solicitada...${NC}"
            if sudo -n true 2>/dev/null; then
                sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null 2>&1 || true
                echo -e "    ${SAB_GREEN}✅ Cache limpo (sudo em cache)${NC}"
                log_message "INFO" "Cache limpo com sudo em cache"
            else
                echo -e "    ${SAB_ORANGE}🔐 Digite a senha sudo para limpar o cache:${NC}"
                if sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null 2>&1; then
                    echo -e "    ${SAB_GREEN}✅ Cache limpo com sucesso${NC}"
                    log_message "INFO" "Cache limpo com sucesso (sudo manual)"
                else
                    echo -e "    ${SAB_ORANGE}⚠️  Falha ao limpar cache (sem privilégios)${NC}"
                    log_message "WARNING" "Falha ao limpar cache (sem privilégios)"
                fi
            fi
        fi
    fi
    
    echo ""
    sleep 5
done

total_end=$(date +%s)
total_duration=$((total_end - total_start))

# =============================================================================
# FOOTER CORPORATIVO
# =============================================================================
echo "" | tee -a "$LOG_FILE"
echo "═══════════════════════════════════════════════════════════════════════════" | tee -a "$LOG_FILE"
echo -e "${SAB_GREEN}✅ BENCHMARK CONCLUÍDO COM SUCESSO!${NC}" | tee -a "$LOG_FILE"
echo -e "${SAB_GOLD}📅 Término:${NC} $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG_FILE"
echo -e "${SAB_GOLD}⏱️  Duração Total:${NC} ${total_duration}s (~$((total_duration/60)) min)" | tee -a "$LOG_FILE"
echo "═══════════════════════════════════════════════════════════════════════════" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "SAB TEC - TECNOLOGIA E SERVIÇOS" | tee -a "$LOG_FILE"
echo "  Desenvolvedor: ${DEVELOPER}" | tee -a "$LOG_FILE"
echo "  Especialidade: ${ROLE}" | tee -a "$LOG_FILE"
echo "  Contato: ${CONTACT}" | tee -a "$LOG_FILE"
echo "  GitHub: ${GITHUB}" | tee -a "$LOG_FILE"
echo "  Issues: ${ISSUES}" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "ARQUIVOS GERADOS:" | tee -a "$LOG_FILE"
echo "  📊 CSV:    ${RESULTS_FILE}" | tee -a "$LOG_FILE"
echo "  📋 LOG:    ${LOG_FILE}" | tee -a "$LOG_FILE"
echo "  🖥️  SYS:    ${SYSINFO_FILE}" | tee -a "$LOG_FILE"
echo "  🐛 DEBUG:  ${DEBUG_LOG}" | tee -a "$LOG_FILE"
echo "═══════════════════════════════════════════════════════════════════════════" | tee -a "$LOG_FILE"

log_message "INFO" "Benchmark concluído com sucesso. Duração: ${total_duration}s"

echo ""
echo -e "${SAB_CYAN}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${SAB_CYAN}║${SAB_WHITE}                        📊 RESUMO DOS RESULTADOS                          ${SAB_CYAN}║${NC}"
echo -e "${SAB_CYAN}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${SAB_CYAN}Modelo              | T1(ms) | T2(ms) | T3(ms) | Total  | Nota${NC}"
echo -e "${SAB_CYAN}────────────────────┼────────┼────────┼────────┼────────┼──────${NC}"

awk -F',' '
NR>1 {
    model=$1; test=$2; time=$3; qual=$6
    if(!(model in models)) { models[model]=1; order[++n]=model }
    times[model,test]=time
    quals[model,test]=qual
    if(time>0) total[model]+=time
}
END {
    for(i=1;i<=n;i++) {
        m=order[i]
        t1=times[m,1]; t2=times[m,2]; t3=times[m,3]
        tot=total[m]
        
        ft1=(t1>0)?sprintf("%6.1fs",t1/1000):"  N/A"
        ft2=(t2>0)?sprintf("%6.1fs",t2/1000):"  N/A"
        ft3=(t3>0)?sprintf("%6.1fs",t3/1000):"  N/A"
        ftot=(tot>0)?sprintf("%6.1fs",tot/1000):"  N/A"
        
        corretos=0
        if(quals[m,1]=="SIM") corretos++
        if(quals[m,2]=="SIM") corretos++
        if(quals[m,3]=="SIM") corretos++
        
        if(corretos==3) nota="⭐⭐⭐"
        else if(corretos==2) nota="⭐⭐"
        else if(corretos==1) nota="⭐"
        else nota="❌"
        
        printf "%-19s | %6s | %6s | %6s | %6s | %s\n", m, ft1, ft2, ft3, ftot, nota
    }
}' "$RESULTS_FILE"

echo ""
echo -e "${SAB_GOLD}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${SAB_GOLD}║${SAB_WHITE}                     SAB TEC - TECNOLOGIA E SERVIÇOS                        ${SAB_GOLD}║${NC}"
echo -e "${SAB_GOLD}║${SAB_CYAN}              Obrigado por utilizar nossas soluções!                        ${SAB_GOLD}║${NC}"
echo -e "${SAB_GOLD}║${SAB_GRAY}  📧 ${CONTACT}  |  🐙 ${GITHUB}  ${SAB_GOLD}║${NC}"
echo -e "${SAB_GOLD}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${SAB_CYAN}💡 Arquivos gerados:${NC}"
echo -e "   ${SAB_GREEN}📊${NC} ${RESULTS_FILE}"
echo -e "   ${SAB_GREEN}📋${NC} ${LOG_FILE}"
echo -e "   ${SAB_GREEN}🖥️ ${NC} ${SYSINFO_FILE}"
echo -e "   ${SAB_GREEN}🐛${NC} ${DEBUG_LOG}"
echo ""

log_message "INFO" "Script finalizado com sucesso"