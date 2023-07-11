# Atualização do Projeto Constata - Firebase

Este documento fornece informações sobre a configuração e registro de aplicativos Android e iOS em um projeto Firebase chamado "constata-abctechnology". Ele também detalha as alterações necessárias nos arquivos `build.gradle` para aplicar a configuração do Firebase e os plugins de compilação do Gradle.

## Plataformas Suportadas

O projeto Firebase "constata-abctechnology" deve ser configurado para suportar as seguintes plataformas:

- Android
- iOS

## Configuração do Firebase

Durante a criação do projeto Firebase, foram registrados os seguintes aplicativos:

### Aplicativo Android

- Nome do pacote: com.abctechnology.constata
- Firebase App ID: 1:771544945913:android:587e819c67d84ff7b07e28

### Aplicativo iOS

- Nome do pacote: com.example.constata003
- Firebase App ID: 1:771544945913:ios:7daa4c766073b8e1b07e28

## Atualização dos arquivos `build.gradle`

Para aplicar a configuração do Firebase e os plugins de compilação do Gradle, é necessário fazer as seguintes alterações nos arquivos `android/build.gradle` e `android/app/build.gradle`:

1. Abra o arquivo `android/build.gradle` e adicione as seguintes linhas no início do arquivo:

```gradle
buildscript {
    repositories {
        // Repositório do Firebase Gradle Plugin
        google()
    }

    dependencies {
        // Plugin do Firebase Gradle
        classpath 'com.google.gms:google-services:4.3.14'
    }
}
```

2. Abra o arquivo `android/app/build.gradle` e adicione as seguintes linhas no final do arquivo:

```gradle
// Plugin do Firebase Gradle
apply plugin: 'com.google.gms.google-services'
```

Após realizar essas alterações, os arquivos `build.gradle` estarão configurados corretamente para aplicar a configuração do Firebase.

Isso conclui a documentação da atualização do projeto Firebase. Certifique-se de seguir essas etapas para configurar corretamente o projeto em suas respectivas plataformas.