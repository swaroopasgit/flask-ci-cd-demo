pipeline {
    agent any

    environment {
        IMAGE_NAME = 'saiswaroopa08/flask-ci-demo:latest'
        CONTAINER_NAME = 'flask-ci-container'
    }



    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', credentialsId: 'flask-ci-cd', url: 'https://github.com/swaroopasgit/flask-ci-cd-demo.git'
            }
        }

        stage('Build Docker Image') {
            steps {
               sh 'docker build -t saiswaroopa08/flask-ci-demo:latest ./app'
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([saiswaroopa08(credentialsId: 'Dockerhub-flask', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker push saiswaroopa08/flask-ci-demo:latest'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'kubectl apply -f k8s/service.yaml'
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    def ip = sh(script: "minikube ip", returnStdout: true).trim()
                    def port = sh(script: "kubectl get svc flask-service -o=jsonpath='{.spec.ports[0].nodePort}'", returnStdout: true).trim()
                    sh "curl --fail http://${ip}:${port}/ || exit 1"
                }
            }
        }
    }
}
