pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "flask-ci-demo"
        DOCKER_CREDENTIALS = "Dockerhub-flask"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    credentialsId: 'flask-ci-cd',
                    url: 'https://github.com/swaroopasgit/flask-ci-cd-demo.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t $DOCKER_IMAGE ."
                }
            }
        }

        stage('Docker Login & Push') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "$DOCKER_CREDENTIALS", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker tag $DOCKER_IMAGE $DOCKER_USER/$DOCKER_IMAGE:latest"
                        sh "docker push $DOCKER_USER/$DOCKER_IMAGE:latest"
                    }
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    sh """
                        docker stop flask-ci-container || true
                        docker rm flask-ci-container || true
                        docker run -d --name flask-ci-container -p 5000:5000 $DOCKER_USER/$DOCKER_IMAGE:latest
                    """
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    sh "curl -f http://localhost:5000 || exit 1"
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished."
        }
        failure {
            echo "Pipeline failed. Rolling back..."
            sh """
                docker stop flask-ci-container || true
                docker rm flask-ci-container || true
            """
        }
    }
}
