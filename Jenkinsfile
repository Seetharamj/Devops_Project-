pipeline {
  agent any

  environment {
    DOCKER_COMPOSE_FILE = "${WORKSPACE}/docker/docker-compose.yml"
    AWS_REGION = "us-east-1"  // Optional: for AWS CLI/SDK if used
  }

  stages {
    stage('Clone Repo') {
      steps {
        git branch: 'main', credentialsId: 'github-creds', url: 'https://github.com/Seetharamj/Devops_Project-.git'
      }
    }

    stage('Terraform Init & Apply') {
      steps {
        withCredentials([[
          $class: 'AmazonWebServicesCredentialsBinding',
          credentialsId: 'aws-creds'
        ]]) {
          sh '''
            cd terraform
            terraform init
            terraform apply -auto-approve
          '''
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t devops-app ./docker'
      }
    }

    stage('Deploy with Docker Compose') {
      steps {
        sh "docker-compose -f $DOCKER_COMPOSE_FILE up -d"
      }
    }
  }

  post {
    failure {
      echo "❌ Build failed!"
    }
    success {
      echo "✅ Deployment completed successfully!"
    }
  }
}
