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
                        sh 'pip install -r requirements.txt'
                        sh 'pip list'
                        sh 'python3 ./model.py'
                        archiveArtifacts artifacts: 'ner_model/**/*', onlyIfSuccessful: true
                    }
                }
            }
        }
    }
}
