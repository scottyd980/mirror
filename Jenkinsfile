pipeline {
  agent any
  stages {
    stage('Build API') {
      steps {
        sh 'docker build -t mirror ./api -v ${PWD}:/_build'
      }
    }
  }
}