pipeline {
    agent any
    stages {
        stage('Git Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Train and Predict') {
            steps {
                script {
                    def customImage = docker.build('custom-image')
                    customImage.inside {
                        sh '/app/.venv/bin/python ./model.py'
                        archiveArtifacts artifacts: 'ner_model/**/*', onlyIfSuccessful: true
                    }
                }
            }
        }
    }
}
