properties([
  parameters([
    booleanParam(defaultValue: false, description: 'If set to true, on completion of docker build, the image will be deployed to production', name: 'deploy_to_prod')
  ])
])

node {
  // def commitId = "`git rev-parse HEAD`"
  def buildNumber = currentBuild.number
  
  try {
    stage("Build API") {
      echo 'Building API...'
      sh "docker build -t nonbreakingspace/mirror-api:1.0.${buildNumber} ./api"
      sh "docker tag nonbreakingspace/mirror-api:1.0.${buildNumber} nonbreakingspace/mirror-api:latest"
      echo 'Successfully built API'
    }
    stage('Push API to Docker Hub') {
      echo 'Pushing to Docker Hub...'
      docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials-id') {
        sh "docker push nonbreakingspace/mirror-api"
      }
      echo 'Successfully pushed to Docker Hub'
    }
    stage('Deploy to Production') {
      if(params.deploy_to_prod) {
        parallel (
          "Tag Release Build": {
            sh "Tagging current build as the release build..."
            sh "docker tag nonbreakingspace/mirror-api:1.0.${buildNumber} nonbreakingspace/mirror-api:release"
            docker.withRegistry('https://index.docker.io/v1/', 'docker-hub-credentials-id') {
              sh "docker push nonbreakingspace/mirror-api"
            }
            sh "Build has been tagged as release and pushed to Docker Hub"
          },
          "Rollout on Kubernetes Cluster": {
            echo 'Rolling deployment to Kubernetes cluster...'
            sh "kubectl --kubeconfig='./kubeconfig.yaml' set image deployment.apps/mirror-api mirror-api=nonbreakingspace/mirror-api:1.0.${buildNumber} --record"
            sh "kubectl --kubeconfig='./kubeconfig.yaml' rollout status deployment.apps/mirror-api"
            echo 'Successfully deployed to production'
          }
        )
      } else {
        echo 'No deployment to production was requested'
      }
    }
  } catch(e) {
    echo "Pipeline failed"
    throw e
  } finally {
    sh "sudo chmod -R 777 ."
  }
}