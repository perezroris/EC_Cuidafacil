# CuidaFácil — Smart HAS + AI Logistics Extension

Aplicativo mobile para dar mais autonomia e segurança a idosos que moram sozinhos ou com mobilidade reduzida, com alerta de emergência (SOS), lembretes de medicação, monitoramento de saúde via wearable e uma camada de **Logística Inteligente e Entrega 5.0** (Enterprise Challenge — Leroy Merlin).

> Projeto acadêmico desenvolvido para o curso de Sistemas de informação — FIAP (2026), no contexto do projeto anual **Smart HAS** e do **Enterprise Challenge Leroy Merlin — Smart HAS AI Logistics Extension**.

**Autor:** Thiago Perez Roris — RM 557921

---

## 📱 Sobre o projeto

O CuidaFácil nasceu do projeto anual Smart HAS e resolve um problema concreto: idosos que moram sozinhos enfrentam risco em emergências, esquecimento de medicação e falta de visibilidade sobre quando um cuidado vai chegar até eles — seja um remédio, um atendimento domiciliar, um exame ou uma sessão de fisioterapia.

A **AI Logistics Extension**, desenvolvida para o Enterprise Challenge com a Leroy Merlin, resolve essa última parte: transforma "esperar por um cuidado" em algo previsível, rastreável e com comunicação proativa — usando um modelo preditivo de ETA, tracking em tempo real e notificações automáticas nos marcos da jornada.

### Funcionalidades principais

| Módulo | O que faz |
|---|---|
| 🆘 SOS de Emergência | Botão de emergência + detecção de queda via wearable, alerta aos contatos com localização |
| 💊 Lembretes de Medicação | Cadastro de remédios, agenda de lembretes, confirmação e escalonamento ao cuidador |
| ❤️ Monitoramento de Saúde | Acompanhamento de frequência cardíaca, saturação e passos, com alertas automáticos |
| 🚚 **AI Logistics Extension** | Solicitação de entrega/atendimento (medicamento, atendimento domiciliar, exame, fisioterapia), com **predição de ETA por IA**, **tracking em tempo real** no mapa e **notificações proativas** |
| 👨‍👩‍👧 Contatos de Emergência | Cadastro de contatos que são acionados em caso de SOS |
| 🗺️ Mapa | Visualização de localização e trajetos |

### AI Logistics Extension — como funciona

A camada vive em `lib/services/servico_ia_logistica.dart`, `lib/providers/entrega_provider.dart` e nas telas `lib/screens/tela_nova_entrega.dart` / `lib/screens/tela_entrega.dart`.

- **Predição de ETA**: calcula o tempo estimado de chegada a partir da distância entre o agente (entregador/profissional) e o usuário, da velocidade média do tipo de atendimento e de um fator de trânsito por horário de pico — retornando também um percentual de confiança do modelo.
- **Tracking em tempo real**: a posição do agente é atualizada continuamente, recalculando o ETA a cada mudança, incluindo a simulação de imprevistos de rota.
- **Comunicação proativa**: notificações automáticas nos marcos da jornada (confirmado → a caminho → próximo → concluído), incluindo alertas de imprevisto.

> **Nota de transparência:** no estágio atual (MVP acadêmico), a predição de ETA e o deslocamento do agente são simulados localmente no app (sem um backend de geolocalização real de terceiros), para permitir uma demonstração completa e reprodutível do comportamento do sistema. A arquitetura já está desenhada para que esse serviço seja substituído por um modelo treinado (ex.: XGBoost) servido por um microsserviço Python + FastAPI, consumindo dados reais de geolocalização — sem exigir mudanças no restante do app.

---

## 🛠️ Tecnologias

- **App:** Flutter / Dart
- **Gerenciamento de estado:** Provider
- **Armazenamento local:** Hive
- **Navegação:** go_router
- **Mapas:** flutter_map + OpenStreetMap
- **Notificações locais:** flutter_local_notifications
- **Integrações externas:** ViaCEP (endereço), API de clima

Stack planejada para produção (documentada nas fases anteriores do projeto Smart HAS): Node.js + Firebase Cloud Messaging, Python + FastAPI, PostgreSQL, Redis, Firebase Firestore.

---

## ▶️ Como rodar o projeto

Pré-requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado (`flutter doctor` sem erros bloqueantes).

```bash
# 1. Clonar o repositório
git clone https://github.com/perezroris/EC_Cuidafacil.git
cd EC_Cuidafacil

# 2. Instalar as dependências
flutter pub get

# 3. Rodar em um emulador/dispositivo conectado
flutter run
```

O módulo de clima lê a chave da OpenWeather pela variável de compilação
`OPENWEATHER_API_KEY`, evitando credenciais no código-fonte.

Para gerar um APK de teste:

```bash
flutter build apk --debug
```

---

## 📂 Estrutura do projeto

```
lib/
├── main.dart                      # rotas, providers e inicialização (Hive)
├── models/                        # modelos de dados (Remedio, Contato, Entrega...)
├── providers/                     # gerenciamento de estado (ChangeNotifier)
│   └── entrega_provider.dart      # AI Logistics Extension — orquestra o tracking
├── screens/                       # telas do app
│   ├── tela_entrega.dart          # AI Logistics Extension — tracking em tempo real
│   └── tela_nova_entrega.dart     # AI Logistics Extension — solicitar atendimento
└── services/                      # integrações e regras de negócio
    └── servico_ia_logistica.dart  # AI Logistics Extension — modelo preditivo de ETA
```

---

## 🚧 Escopo e limitações conhecidas

Este é um produto acadêmico-profissional concluído dentro do escopo definido para o Enterprise Challenge — não uma solução pronta para produção em larga escala. Limitações assumidas conscientemente:

- Predição de ETA e tracking do agente são **simulados no cliente** (ver nota de transparência acima), não conectados a um backend real de geolocalização de terceiros.
- Autenticação, backend de push notifications e persistência em nuvem descritos nas fases de planejamento **não fazem parte deste protótipo mobile** — o app funciona com armazenamento local (Hive).
- Testes automatizados cobrem o essencial do fluxo; não há suíte de testes end-to-end completa.

---

## 👤 Equipe

**Thiago Perez Roris** — RM 557921 — FIAP, Sistemas de informação (2026)
