pipeline {
    agent any

    environment {
        IMAGE_NAME = "flask-ci-demo"
        DEPLOY_CONTAINER_NAME = "flask-ci-container"
        DEPLOY_PORT = "5001"  // change if needed
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "Cloning repository..."
                git credentialsId: 'flask-ci-cd', url: 'https://github.com/swaroopasgit/flask-ci-cd-demo.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh 'docker build -t $IMAGE_NAME:latest .'
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'Dockerhub-flask', 
                                                 usernameVariable: 'DOCKER_USER', 
                                                 passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "Logging into Docker Hub..."
                        docker login -u $DOCKER_USER -p $DOCKER_PASS
                        docker tag $IMAGE_NAME:latest $DOCKER_USER/$IMAGE_NAME:latest
                        docker push $DOCKER_USER/$IMAGE_NAME:latest
                    '''
                }
            }
        }

        stage('Deploy Container') {
            steps {
                echo "Stopping old container (if exists) and running new one..."
                sh '''
                    docker stop $DEPLOY_CONTAINER_NAME || true
                    docker rm $DEPLOY_CONTAINER_NAME || true
                    docker run -d --name $DEPLOY_CONTAINER_NAME -p $DEPLOY_PORT:5000 $DOCKER_USER/$IMAGE_NAME:latest
                '''
            }
        }

        stage('Smoke Test') {
            steps {
                echo "Checking if the Flask app is running..."
                sh '''
                    sleep 5
                    curl -f http://localhost:$DEPLOY_PORT || exit 1
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline finished."
        }
        success {
            echo "CI/CD Pipeline succeeded! Flask app deployed at port $DEPLOY_PORT."
        }
        failure {
            echo "Pipeline failed. Rolling back..."
            sh '''
                docker stop $DEPLOY_CONTAINER_NAME || true
                docker rm $DEPLOY_CONTAINER_NAME || true
            '''
        }
    }
}

