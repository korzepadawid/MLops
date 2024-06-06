pipeline {
    agent any
    parameters {
        string(name: 'KAGGLE_USERNAME', defaultValue: 'alicjaszulecka', description: 'Kaggle username')
        password(name: 'KAGGLE_KEY', defaultValue:'', description: 'Kaggle Key')
        string(name: 'CUTOFF', defaultValue: '100', description: 'cut off number')
    }
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
                        sh 'pip list'
                        sh 'python3 ./model.py'
                        archiveArtifacts artifacts: 'ner_model/**/*', onlyIfSuccessful: true
                    }
                }
            }
        }
    }
}
