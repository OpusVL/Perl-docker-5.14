pipeline {
    agent any

    stages {
        stage('Build for production') {
            steps {
                sh "docker build --target release -t perl-5.14:${env.BRANCH_NAME} ."
            }
        }

        stage('Build for development') {
            steps {
                sh "docker build --target dev -t perl-5.14-dev:${env.BRANCH_NAME} ."
            }
        }
    }
}