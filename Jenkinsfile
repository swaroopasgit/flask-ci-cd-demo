pipeline {
    agent any

    environment {
        IMAGE_NAME = "flask-ci-demo"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git(
                    url: 'https://github.com/swaroopasgit/flask-ci-cd-demo.git',
                    branch: 'main',
                    credentialsId: 'flask-ci-cd'  // Git credential ID
                )
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'Dockerhub-flask', 
                    usernameVariable: 'DOCKER_USER', 
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker tag $IMAGE_NAME $DOCKER_USER/$IMAGE_NAME:latest
                        docker push $DOCKER_USER/$IMAGE_NAME:latest
                    '''
                }
            }
        }

        stage('Deploy Container') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'Dockerhub-flask', 
            usernameVariable: 'DOCKER_USER', 
            passwordVariable: 'DOCKER_PASS'
        )]) {
            sh """
                docker stop flask-ci-container || true
                docker rm flask-ci-container || true
                docker run -d --name flask-ci-container -p 5000:5000 ${DOCKER_USER}/${IMAGE_NAME}:latest
            """
        }
    }
}

        stage('Smoke Test') {
            steps {
                sh 'curl -f http://localhost:5000 || echo "Smoke test failed"'
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed. Cleaning up...'
            sh '''
                docker stop flask-ci-container || true
                docker rm flask-ci-container || true
            '''
        }
    }
}
