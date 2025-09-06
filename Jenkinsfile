pipeline {
    agent any

    environment {
        CONTAINER_NAME = 'flask-ci-container'
        IMAGE_NAME = 'saiswaroopa08/flask-ci-demo'
        DOCKERHUB_CRED = 'docker-hub-creds' // Jenkins credentials ID for Docker Hub
        GIT_CRED = 'flask-ci-cd'            // Jenkins credentials ID for Git
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/swaroopasgit/flask-ci-cd-demo.git',
                    credentialsId: "${GIT_CRED}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:latest ."
                }
            }
        }

        stage('Docker Login & Push') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CRED}", 
                                                     passwordVariable: 'DOCKER_PASS', 
                                                     usernameVariable: 'DOCKER_USER')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${IMAGE_NAME}:latest"
                    }
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // Stop & remove container if already running
                    sh "docker rm -f ${CONTAINER_NAME} || true"
                    // Run container
                    sh "docker run -d --name ${CONTAINER_NAME} -p 5001:5000 ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    sh "sleep 5" // give container a few seconds to start
                    sh "curl -f http://localhost:5001 || exit 1"
                }
            }
        }
    }

    post {
        always {
            node {
                script {
                    echo 'Cleaning up Docker container...'
                    sh "docker rm -f ${CONTAINER_NAME} || true"
                }
            }
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed! Check logs.'
        }
    }
}
