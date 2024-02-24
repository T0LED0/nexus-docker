# 🐳 Docker Nexus Backup Script 📦

Este é um script shell projetado para automatizar o processo de migração e backup de artefatos Docker do Sonatype Nexus. Ele oferece uma solução eficiente para lidar com um grande número de imagens de contêineres, facilitando o backup e a migração desses artefatos.

## Requisitos

Certifique-se de ter os seguintes requisitos instalados em seu sistema:
- [x] curl
- [x] jq
- [x] aws-cli
- [x] docker

## Como usar

1. Defina as variáveis de ambiente necessárias no script, como `BEAREN`, `REGISTRY`, `REPOSITORY_SOURCE`, etc.
2. Execute o script shell `script.sh`.
3. Aguarde a conclusão do processo de backup e migração.

## Funcionalidades Principais

- Verificação e configuração das variáveis de ambiente.
- Verificação dos requisitos do sistema.
- Extração da lista de artefatos do Sonatype Nexus.
- Download e compactação das imagens Docker.
- Upload das imagens compactadas para o Amazon S3.
- Limpeza do sistema após a conclusão do backup.

## Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para abrir problemas ou enviar solicitações de pull.

## Autores

Desenvolvido por [Lúcio Alves Toledo] 🚀

## Licença

Este projeto está licenciado sob a [Licença MIT](LICENSE).
