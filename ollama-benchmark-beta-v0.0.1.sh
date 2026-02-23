#!/bin/bash
# =============================================================================
#  ███████  █████  ██████      ████████ ███████ ██████  
#  ██      ██   ██ ██   ██        ██    ██      ██   ██ 
#  ███████ ███████ ██████         ██    █████   ██████  
#       ██ ██   ██ ██   ██        ██    ██      ██      
#  ███████ ██   ██ ██████         ██    ███████ ███████ 
# =============================================================================
# SAB TEC - Tecnologia e Serviços
# Ollama Benchmark Beta | v0.0.1
# =============================================================================

# =============================================================================
# METADADOS DO PROJETO
# =============================================================================
PROJECT_NAME="Ollama Benchmark Beta"
VERSION="v0.0.1"
COMPANY="SAB TEC - Tecnologia e Serviços"
CONTACT="sab.tecno@gmail.com"
GITHUB="https://github.com/sabtecno"
DEVELOPER="Tiago Sant Anna"
ROLE="AI Engineer | Especialista em LLMs & Agentes Autônomos"
SCRIPT_NAME="ollama-benchmark-beta-${VERSION}.sh"
RELEASE_DATE="2026-02-21"

DESCRIPTION="Script beta para testes de benchmark em modelos locais do Ollama.
Testado em ambiente Ubuntu 24.04 LTS em Hyper-V.
Recursos: Auto-detecção | Auto-chmod | Sudo-check interativo | System Info |
Hyper-V detection | Anti-sobrescrita | Visualização colorida."

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
# FUNÇÃO: VERIFICAR E INSTALAR DEPENDÊNCIAS
# =============================================================================

check_and_install_dependencies() {
    local deps=("lolcat" "figlet" "bc" "jq" "dos2unix")
    local missing=()
    local needs_restart=false
    
    echo -e "${CYAN}🔍 Verificando dependências do sistema...${NC}"
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Dependências ausentes: ${missing[*]}${NC}"
        echo -e "${CYAN}📦 Preparando instalação...${NC}"
        
        if [ "$EUID" -ne 0 ]; then
            echo -e "${YELLOW}🔐 Será necessário privilégio sudo para instalar dependências.${NC}"
            echo -e "${CYAN}⏳ Aguardando 5 segundos... (Ctrl+C para cancelar)${NC}"
            sleep 5
        fi
        
        echo -e "${CYAN}🔄 Atualizando repositórios do sistema...${NC}"
        sudo apt-get update -qq || {
            echo -e "${RED}❌ Falha ao atualizar repositórios${NC}"
            return 1
        }
        
        echo -e "${CYAN}⬆️  Atualizando pacotes existentes...${NC}"
        sudo apt-get upgrade -y -qq || {
            echo -e "${ORANGE}⚠️  Alguns pacotes não puderam ser atualizados${NC}"
        }
        
        echo -e "${CYAN}📦 Instalando dependências: ${missing[*]}${NC}"
        sudo apt-get install -y "${missing[@]}" || {
            echo -e "${RED}❌ Falha na instalação de dependências${NC}"
            return 1
        }
        
        needs_restart=true
        echo -e "${GREEN}✅ Todas as dependências instaladas com sucesso!${NC}"
    else
        echo -e "${GREEN}✅ Todas as dependências já estão instaladas${NC}"
    fi
    
    if command -v dos2unix &> /dev/null; then
        if file "$0" | grep -q "CRLF"; then
            echo -e "${CYAN}🔧 Convertendo script para formato Unix...${NC}"
            dos2unix "$0" 2>/dev/null
            needs_restart=true
        fi
    fi
    
    if [ "$needs_restart" = true ]; then
        echo -e "${GREEN}🔄 Reiniciando script com dependências atualizadas...${NC}"
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
    
    if chmod +x "$0" 2>/dev/null; then
        echo -e "${GREEN}✅ Permissão aplicada automaticamente. Reiniciando...${NC}"
        exec bash "$0" "$@"
    else
        echo -e "${RED}❌ ERRO CRÍTICO: Não foi possível aplicar permissão de execução!${NC}"
        
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
# AGORA PODEMOS USAR CORES AVANÇADAS
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

# =============================================================================
# FUNÇÃO: IMPRIMIR CABEÇALHO CORPORATIVO
# =============================================================================

print_header() {
    clear
    echo ""
    
    if command -v figlet &> /dev/null && command -v lolcat &> /dev/null; then
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
                    if sudo -v 2>/dev/null; then
                        echo -e "${SAB_GREEN}✅ Autenticação sudo bem-sucedida!${NC}"
                        SUDO_MODE="AUTO"
                        echo -e "${SAB_GREEN}🔄 Reiniciando script com privilégios sudo...${NC}"
                        sleep 2
                        exec sudo bash "$0" "$@"
                    else
                        echo -e "${SAB_RED}❌ Falha na autenticação sudo.${NC}"
                        echo -e "${SAB_ORANGE}⚠️  Continuando sem privilégios elevados...${NC}"
                        SUDO_MODE="MANUAL"
                    fi
                    break
                    ;;
                2)
                    echo -e "${SAB_GOLD}🚪 Encerrando script...${NC}"
                    echo ""
                    echo -e "${SAB_CYAN}💡 Execute manualmente:${NC}"
                    echo -e "${SAB_GREEN}   sudo ./${SCRIPT_NAME}${NC}"
                    echo ""
                    exit 0
                    ;;
                3)
                    echo -e "${SAB_ORANGE}⚠️  Continuando sem sudo.${NC}"
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
        sleep 2
    fi
fi

echo ""
echo -e "${SAB_GREEN}▶ Iniciando benchmark...${NC}"
echo ""

set -e

# =============================================================================
# CAPTURA DE INFORMAÇÕES DO SISTEMA
# =============================================================================

echo -e "${SAB_CYAN}🔍 Analisando ambiente de execução...${NC}"

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

# =============================================================================
# DIRETÓRIOS E ARQUIVOS
# =============================================================================

RESULTS_DIR="./benchmark_results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$RESULTS_DIR"

COUNTER=1
RESULTS_FILE="${RESULTS_DIR}/benchmark_beta_${VERSION}_${TIMESTAMP}.csv"
while [ -f "$RESULTS_FILE" ]; do
    RESULTS_FILE="${RESULTS_DIR}/benchmark_beta_${VERSION}_${TIMESTAMP}_${COUNTER}.csv"
    COUNTER=$((COUNTER + 1))
done

LOG_FILE="${RESULTS_FILE%.csv}.log"
SYSINFO_FILE="${RESULTS_FILE%.csv}_sysinfo.txt"

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
echo "═══════════════════════════════════════════════════════════════════════════"
} > "$SYSINFO_FILE"

# =============================================================================
# HEADER DE EXECUÇÃO
# =============================================================================

print_header

echo -e "${SAB_CYAN}┌─────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${SAB_CYAN}│${SAB_WHITE} 🖥️  AMBIENTE DE EXECUÇÃO${NC}"
echo -e "${SAB_CYAN}├─────────────────────────────────────────────────────────────────────────┤${NC}"
echo -e "${SAB_CYAN}│${SAB_GRAY}  Sistema:    ${SAB_WHITE}${SYS_OS}${NC}"
echo -e "${SAB_CYAN}│${SAB_GRAY}  Kernel:     ${SAB_WHITE}${SYS_KERNEL}${NC}"
echo -e "${SAB_CYAN}│${SAB_GRAY}  Virtual:    ${SAB_WHITE}${SYS_VIRT}${NC}"
[ "$SYS_VIRT_TYPE" = "VM" ] && echo -e "${SAB_CYAN}│${SAB_GRAY}  Host:       ${SAB_WHITE}${SYS_HOST_OS}${NC}"
echo -e "${SAB_CYAN}│${SAB_GRAY}  CPU:        ${SAB_WHITE}${SYS_CPU_CORES} cores${NC}"
echo -e "${SAB_CYAN}│${SAB_GRAY}  RAM:        ${SAB_WHITE}${SYS_RAM_TOTAL}${NC}"
echo -e "${SAB_CYAN}│${SAB_GRAY}  Ollama:     ${SAB_WHITE}${SYS_OLLAMA_VERSION}${NC}"
echo -e "${SAB_CYAN}│${SAB_GRAY}  Modo:       ${SAB_GREEN}${SUDO_MODE}${NC}"
echo -e "${SAB_CYAN}└─────────────────────────────────────────────────────────────────────────┘${NC}"
echo ""

# =============================================================================
# AUTO-DETECÇÃO DE MODELOS
# =============================================================================

echo -e "${SAB_CYAN}🔍 Detectando modelos instalados no Ollama...${NC}"

MODELS_ARRAY=()

while IFS= read -r line; do
    [ -z "$line" ] && continue
    [ "$line" = "NAME" ] && continue
    
    modelo=$(echo "$line" | awk '{print $1}')
    [ -z "$modelo" ] && continue
    
    if echo "$modelo" | grep -q ":cloud$"; then
        echo -e "  ${SAB_CYAN}☁️  Pulando cloud:${NC} $modelo"
        continue
    fi
    
    MODELS_ARRAY+=("$modelo")
    
done < <(ollama list 2>/dev/null | tail -n +2)

if [ ${#MODELS_ARRAY[@]} -eq 0 ]; then
    echo -e "${SAB_RED}❌ Nenhum modelo local detectado!${NC}"
    exit 1
fi

echo -e "${SAB_GREEN}✅ ${#MODELS_ARRAY[@]} modelo(s) detectado(s):${NC}"
for m in "${MODELS_ARRAY[@]}"; do
    echo -e "   ${SAB_CYAN}•${NC} $m"
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
echo "Sistema:    ${SYS_OS} | ${SYS_KERNEL}"
echo "Virtual:    ${SYS_VIRT}"
echo "Hardware:   ${SYS_CPU_CORES} cores | ${SYS_RAM_TOTAL} RAM"
echo "Modelos:    ${#MODELS_ARRAY[@]}"
echo "Arquivo:    ${RESULTS_FILE}"
echo "═══════════════════════════════════════════════════════════════════════════"
} | tee "$LOG_FILE"

echo -e "${SAB_GOLD}📅 Início:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "${SAB_GOLD}📝 Resultados:${NC} ${RESULTS_FILE}"
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
    
    if ! ollama list | grep -q "^${model}"; then
        echo -e "${SAB_RED}❌ Modelo não encontrado! Pulando...${NC}" | tee -a "$LOG_FILE"
        echo "$model,0,0,0,0,NAO_ENCONTRADO,,$(date +%s),${VERSION},\"$SYS_OS\",\"$SYS_VIRT\",\"$COMPANY\",\"$DEVELOPER\"" >> "$RESULTS_FILE"
        continue
    fi
    
    model_size=$(ollama list | grep "^${model}" | awk '{print $3}' || echo "N/A")
    echo -e "${SAB_GREEN}✅ Disponível${NC} | Tamanho: ${SAB_CYAN}${model_size}${NC}"
    
    echo -e "${SAB_ORANGE}🔥 Warm-up...${NC}"
    curl -s http://localhost:11434/api/generate \
        -d "{\"model\": \"$model\", \"prompt\": \"Oi\", \"stream\": false, \"options\": {\"num_ctx\": 2048}}" \
        > /dev/null 2>&1 || {
        echo -e "${SAB_ORANGE}⚠️  Warm-up falhou, continuando...${NC}"
    }
    sleep 2
    
    model_start=$(date +%s)
    
    for i in "${!TEST_PROMPTS[@]}"; do
        test_num=$((i + 1))
        prompt="${TEST_PROMPTS[$i]}"
        
        echo -e "  📝 Teste $test_num/3"
        
        mem_before=$(free -m | awk 'NR==2{print $3}')
        
        start_time=$(date +%s%N)
        
        response=$(curl -s --max-time 600 \
            http://localhost:11434/api/generate \
            -H "Content-Type: application/json" \
            -d "{\"model\": \"$model\", \"prompt\": \"$prompt\", \"stream\": false, \"options\": {\"temperature\": 0.7, \"num_ctx\": 4096}}" 2>/dev/null) || {
            echo -e "${SAB_RED}    ❌ Timeout ou erro na requisição${NC}"
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
        
        sleep 3
    done
    
    model_end=$(date +%s)
    model_duration=$((model_end - model_start))
    
    echo -e "${SAB_BLUE}  ⏹️  Concluído em ${model_duration}s${NC}"
    echo "  Modelo $model: ${model_duration}s" >> "$LOG_FILE"
    
    # LIMPEZA DE CACHE COM TRATAMENTO DE SUDO
    if [ $((model_count % 3)) -eq 0 ]; then
        echo "  🧹 Limpando cache..."
        
        if [ "$SUDO_MODE" = "AUTO" ]; then
            sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null 2>&1 || true
            echo -e "    ${SAB_GREEN}✅ Cache limpo (sudo automático)${NC}"
        else
            echo -e "    ${SAB_ORANGE}⚠️  Modo manual: senha sudo pode ser solicitada...${NC}"
            if sudo -n true 2>/dev/null; then
                sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null 2>&1 || true
                echo -e "    ${SAB_GREEN}✅ Cache limpo (sudo em cache)${NC}"
            else
                echo -e "    ${SAB_ORANGE}🔐 Digite a senha sudo para limpar o cache:${NC}"
                if sync && echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null 2>&1; then
                    echo -e "    ${SAB_GREEN}✅ Cache limpo com sucesso${NC}"
                else
                    echo -e "    ${SAB_ORANGE}⚠️  Falha ao limpar cache (sem privilégios)${NC}"
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
echo "" | tee -a "$LOG_FILE"
echo "ARQUIVOS GERADOS:" | tee -a "$LOG_FILE"
echo "  📊 CSV:    ${RESULTS_FILE}" | tee -a "$LOG_FILE"
echo "  📋 LOG:    ${LOG_FILE}" | tee -a "$LOG_FILE"
echo "  🖥️  SYS:    ${SYSINFO_FILE}" | tee -a "$LOG_FILE"
echo "═══════════════════════════════════════════════════════════════════════════" | tee -a "$LOG_FILE"

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
echo ""