pipeline {
  agent any
  environment {
    ARM_CLIENT_ID     = credentials('AZURE_CLIENT_ID')
    ARM_CLIENT_SECRET = credentials('AZURE_CLIENT_SECRET')
    ARM_TENANT_ID     = credentials('AZURE_TENANT_ID')
    ARM_SUBSCRIPTION_ID = credentials('AZURE_SUBSCRIPTION_ID')
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Terraform Init/Apply') {
      steps {
        sh '''
          az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
          export ARM_CLIENT_ID=$ARM_CLIENT_ID
          export ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET
          export ARM_TENANT_ID=$ARM_TENANT_ID
          export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID

          cd infra-aks-terraform
          terraform init -backend-config="resource_group_name=${TFSTATE_RG}" -backend-config="storage_account_name=${TFSTATE_STORAGE}" -backend-config="container_name=${TFSTATE_CONTAINER}" -backend-config="key=aks.terraform.tfstate"
          terraform plan -out=tfplan -var="rg_name=${TF_RG_NAME}" -var="location=${TF_LOCATION}"
          terraform apply -auto-approve tfplan
        '''
      }
    }
    stage('Build & Push') {
      steps {
        sh '''
          cd ../sample-app
          docker build -t myregistry/sample-app:${BUILD_NUMBER} .
          docker login myregistry -u $DOCKER_USER -p $DOCKER_PASS
          docker push myregistry/sample-app:${BUILD_NUMBER}
        '''
      }
    }
    stage('Deploy to AKS') {
      steps {
        sh '''
          # after terraform apply, fetch kubeconfig
          az aks get-credentials --resource-group ${TF_RG_NAME} --name ${AKS_NAME} --file kubeconfig
          export KUBECONFIG=$PWD/kubeconfig
          kubectl set image deployment/sample-app sample-app=myregistry/sample-app:${BUILD_NUMBER} --namespace production || kubectl apply -f k8s/deployment.yaml
        '''
      }
    }
  }
  post {
    success { echo "Pipeline succeeded" }
    failure { mail to: 'you@company.com', subject: "Failed: ${env.JOB_NAME}", body: "See Jenkins build" }
  }
}
