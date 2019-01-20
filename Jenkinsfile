// pipeline {
//   agent any
//   stages {
//     stage('Build API') {
//       steps {
//         echo 'Building API...'
//         sh "docker build -t nonbreakingspace/mirror-api:`git log -1 --pretty=%H` ./api"
//         sh "docker tag nonbreakingspace/mirror-api:`git log -1 --pretty=%H` nonbreakingspace/mirror-api:latest"
//         echo 'Successfully built API'
//       }
//     }
//     stage('Push API to Docker Hub') {
//       steps {
//         echo 'Pushing to Docker Hub...'
//         docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials-id') {
//           sh "docker push nonbreakingspace/mirror-api"
//         }
//         echo 'Successfully pushed to Docker Hub'
//       }
//     }
//   }
//   post {
//     always {
//       sh "sudo chmod -R 777 ."
//     }
//   }
// }

node { 
  try {
    stage("Build API") {
      echo 'Building API...'
      sh "docker build -t nonbreakingspace/mirror-api:`git log -1 --pretty=%H` ./api"
      sh "docker tag nonbreakingspace/mirror-api:`git log -1 --pretty=%H` nonbreakingspace/mirror-api:latest"
      echo 'Successfully built API'
    }
    stage('Push API to Docker Hub') {
      echo 'Pushing to Docker Hub...'
      docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials-id') {
        sh "docker push nonbreakingspace/mirror-api"
      }
      echo 'Successfully pushed to Docker Hub'
    }
  } catch(e) {
    echo "Pipeline failed"
    throw e
  } finally {
    sh "sudo chmod -R 777 ."
  }
}