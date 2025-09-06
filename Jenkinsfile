pipeline {
    agent any

    environment {
        DOCKER_USER = credentials('Dockerhub-flask') // username stored in Jenkins creds
        DOCKER_PASS = credentials('Dockerhub-flask') // PAT/password stored in Jenkins creds
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/swaroopasgit/flask-ci-cd-demo.git', credentialsId: 'flask-ci-cd', branch: 'main'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t flask-ci-demo .'
                }
            }
        }

        stage('Docker Login & Push') {
            steps {
                script {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker tag flask-ci-demo $DOCKER_USER/flask-ci-demo:latest
                    docker push $DOCKER_USER/flask-ci-demo:latest
                    '''
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    sh '''
                    docker stop flask-ci-container || true
                    docker rm flask-ci-container || true
                    docker run -d --name flask-ci-container -p 5000:5000 $DOCKER_USER/flask-ci-demo:latest
                    '''
                }
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    sh '''
                    sleep 5
                    curl -f http://localhost:5000/ || exit 1
                    '''
                }
            }
        }
    }

    post {
        failure {
            script {
                sh '''
                docker stop flask-ci-container || true
                docker rm flask-ci-container || true
                '''
            }
        }
    }
}
