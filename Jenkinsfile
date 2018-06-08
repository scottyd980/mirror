pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        sh 'echo "Hello"'
        sh 'docker build -t mirror ./api'
      }
    }
  }
}