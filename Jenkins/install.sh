#!/bin/bash

source config.sh

echo "Оновлення системи та встановлення необхідних компонентів..."
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y openjdk-17-jdk curl unzip docker-compose git awscli gh

echo "Додаємо офіційний репозиторій Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "Встановлення Jenkins..."
sudo apt update -y
sudo apt install -y jenkins

echo "Запуск Jenkins..."
sudo systemctl enable --now jenkins

echo "⏳ Очікуємо запуск Jenkins..."
sleep 40  # Даємо час Jenkins запуститися

echo "Переконуємось, що Jenkins працює..."
if ! systemctl is-active --quiet jenkins; then
    echo "❌ Помилка: Jenkins не запустився!"
    sudo systemctl status jenkins.service
    sudo journalctl -xe -u jenkins.service
    exit 1
fi

echo "⚙️ Завантаження jenkins-cli.jar у репозиторій..."
mkdir -p jenkins_files

if [ ! -f "$CLI_JAR" ]; then
    curl -sSL "${JENKINS_URL}/jnlpJars/jenkins-cli.jar" -o "$CLI_JAR"
    chmod +x "$CLI_JAR"
    echo "✅ jenkins-cli.jar збережено у jenkins_files!"
else
    echo "✅ jenkins-cli.jar вже існує у jenkins_files!"
fi

echo "⚙️ Створюємо Groovy-скрипт для автоматичного створення адміністратора та обходу Setup Wizard..."
sudo mkdir -p /var/lib/jenkins/init.groovy.d
cat <<EOF | sudo tee /var/lib/jenkins/init.groovy.d/basic-security.groovy
#!groovy
import jenkins.model.*
import hudson.security.*
import jenkins.install.InstallState

def instance = Jenkins.getInstanceOrNull()
if (instance == null) {
    println("❌ Помилка: неможливо отримати інстанс Jenkins")
    return
}

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("$JENKINS_USER", "$JENKINS_PASSWORD")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)

// Обхід Setup Wizard
instance.installState = InstallState.INITIALIZED

instance.save()

println("✅ Адміністратор створений: $JENKINS_USER / $JENKINS_PASSWORD")
println("✅ Setup Wizard пропущено.")
EOF

echo "Перезапуск Jenkins..."
sudo systemctl restart jenkins

bash plugin.sh

# Видалення файлів для обходу Setup Wizard (на всякий випадок)
sudo rm -rf /var/lib/jenkins/jenkins.install.UpgradeWizard.state
sudo rm -rf /var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion
bash cred.sh

bash pipeline.sh

echo "✅ Jenkins встановлено та налаштовано!"
echo "Логін: $JENKINS_USER"
echo "Пароль: $JENKINS_PASSWORD"
