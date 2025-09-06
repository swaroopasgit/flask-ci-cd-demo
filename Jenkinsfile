pipeline {
    agent any

    environment {
        // Point Jenkins to the correct Docker Desktop socket
        DOCKER_HOST = "unix:///Users/kusumavakkalanka/Library/Containers/com.docker.docker/Data/docker-cli.sock"
        DOCKER_USER = "saiswaroopa08"
        DOCKER_IMAGE = "flask-ci-demo"
        DOCKER_CONTAINER = "flask-ci-container"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git url: 'https://github.com/swaroopasgit/flask-ci-cd-demo.git', branch: 'main', credentialsId: 'flask-ci-cd'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:latest ."
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([string(credentialsId: 'docker-hub-pass', variable: 'DOCKER_PASS')]) {
                    sh "echo \$DOCKER_PASS | docker login -u ${DOCKER_USER} --password-stdin"
                    sh "docker tag ${DOCKER_IMAGE}:latest ${DOCKER_USER}/${DOCKER_IMAGE}:latest"
                    sh "docker push ${DOCKER_USER}/${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                // Remove old container if exists
                sh "docker rm -f ${DOCKER_CONTAINER} || true"

                // Run new container
                sh "docker run -d --name ${DOCKER_CONTAINER} -p 5001:5000 ${DOCKER_USER}/${DOCKER_IMAGE}:latest"
            }
        }

        stage('Smoke Test') {
            steps {
                // optional: test container health
                sh "curl -f http://localhost:5001 || exit 1"
            }
        }
    }

    post {
        always {
            // cleanup old container
            sh "docker rm -f ${DOCKER_CONTAINER} || true"
        }
    }
}
