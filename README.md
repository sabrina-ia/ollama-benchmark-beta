# Ollama Benchmark Beta 🔬

**Ferramenta de Benchmarking para Modelos Ollama**
O **Ollama Benchmark Beta** é um toolkit open-source de benchmarking e avaliação para modelos Ollama, projetado para testar e qualificar LLMs para sistemas de orquestração multi-agente.
&gt; ⚠️ **Nota**: Este é um componente standalone do ecossistema SABRINA, um sistema autônomo de orquestração de IA atualmente em desenvolvimento privado.

## Propósito
Originalmente desenvolvido para avaliar modelos para alocação de sub-agentes do projeto SABRINA, o Ollama Benchmark Beta agora está disponível para a comunidade realizar benchmarks de modelos Ollama em seus próprios projetos.

## Características
- **Avaliação Abrangente**: Testa múltiplas capacidades dos modelos (raciocínio, codificação, criatividade, etc.)
- **Integração Ollama**: Compatível nativo com a API local do Ollama
- **Relatórios Detalhados**: Gera métricas comparativas e análises de desempenho
- **Configurável**: Permite ajustar parâmetros de teste conforme necessidade
- **Multi-Modelo**: Capacidade de comparar diferentes modelos em batch

## Instalação Rápida
```bash
# Clone o repositório
git clone https://github.com/sabtecno/ollama-benchmark-beta.git
cd ollama-benchmark-beta

# Execute o script
chmod +x ollama-benchmark-beta-v0.0.1.sh
./ollama-benchmark-beta-v0.0.1.sh
```
## Requisitos
### Infraestrutura Testada ✅
| Componente | Especificação                              |
| ---------- | ------------------------------------------ |
| **CPU**    | Intel Xeon E5-2680 v4 @ 2.40GHz            |
| **RAM**    | 32GB                                       |
| **GPU**    | AMD Radeon R5 220 (2GB) - Offboard Simples |

### Stack de Software
| Camada                    | Tecnologia       |
| ------------------------- | ---------------- |
| **Host OS**               | Windows 10       |
| **Virtualizador**         | Hyper-V          |
| **Guest OS**              | Ubuntu 24.04 LTS |
| **Orquestração de Tools** | OpenClaw         |
| **LLM Backend**           | Ollama           |
| **Web Search**            | SearXNG          |
| **Interface**             | OpenWebUI        |
✅ Status: Todos os componentes instalados, atualizados e operacionais (100%)

### Dependências
Ollama com suporte a tool calling
OpenClaw instalado e configurado
Bash 4.0+
jq (processamento JSON)
curl
## Uso

./ollama-benchmark-beta-v0.0.1.sh [opções]
### Opções disponíveis:
-m, --model : Especifica o modelo a ser testado (padrão: llama2)
-t, --timeout : Define timeout para cada teste (padrão: 60s)
-o, --output : Diretório de saída para relatórios
-h, --help : Exibe ajuda completa

### Estrutura do Projeto
ollama-benchmark-beta/
├── ollama-benchmark-beta-v0.0.1.sh    # Script principal
├── benchmarks/                        # Conjunto de testes
│   ├── reasoning/
│   ├── coding/
│   └── creativity/
├── templates/                         # Templates de relatório
└── docs/                              # Documentação completa

## Resultados dos Testes
O script gera:
📊 Relatório JSON com métricas detalhadas
📈 Resumo em Markdown para visualização rápida
🏆 Ranking comparativo entre modelos testados
Roadmap
[ ] Suporte a testes de visão computacional
[ ] Integração com Hugging Face Hub
[ ] Dashboard web para visualização de resultados
[ ] Benchmarks específicos para agentes autônomos

## Contribuição
Contribuições são bem-vindas! Por favor, leia nosso CONTRIBUTING.md antes de submeter PRs.

## Licença
Este projeto está licenciado sob a MIT License.

## Sobre a SAB TEC
Desenvolvido por: Tiago Sant Anna
Cargo: AI Engineer | Especialista em LLMs & Agentes Autônomos
Empresa: SAB TEC - Tecnologia e Serviços
Contato: sab.tecno@gmail.com
GitHub: https://github.com/sabtecno

## Versão do Projeto
Versão: v0.0.1
Data de Lançamento: 2026-02-21

## Agradecimentos
Este projeto ganhou forma graças à invaluable ajuda e suporte da Comunidade Automatik. A troca de conhecimentos, feedback técnico e colaboração dentro desta comunidade foram fundamentais para o desenvolvimento e aprimoramento desta ferramenta.
### Agradecimentos especiais a:
Rafa Martins - Comunidade Automatik
Claudeir Ribeiro - Comunidade Automatik

## Referências
| Recurso                 | Link                               |
| ----------------------- | ---------------------------------- |
| **Automatik**           | <https://mundoautomatik.com/>      |
| **Automatik \| Grupos** | <https://links.mundoautomatik.com> |
| **Telegram\|Automatik** | <https://t.me/mundoautomatik>      |
| **Openclaw**            | <https://openclaw.ai>              |
