node {
  checkout scm
}

pipeline {
  agent {
    kubernetes {
      label "${JOB_BASE_NAME}-${BUILD_NUMBER}"
      defaultContainer 'slave-terraform'
      yaml """
      apiVersion: v1
      kind: Pod
         
      spec:
        containers:
          - name: jnlp
            image: ${params.awsBuildAccountNumber}.dkr.ecr.eu-west-2.amazonaws.com/lm/pipeline.agent.terraform:1.0.8
            workDir: /home/jenkins
            tty: true
          - name: slave-terraform
            image: ${params.awsBuildAccountNumber}.dkr.ecr.eu-west-2.amazonaws.com/lm/pipeline.agent.terraform:1.0.8
            securityContext:
              privileged: true
            command:
            - /bin/bash
            tty: true
        volumes:
          - name: dind-storage
            emptyDir: {}
      """
    }
  }
  parameters {
    string(name: 'env',  defaultValue: 'dev',  description: 'The environment where this job is ran in, i.e dev/uat/prod')
    }

options {
buildDiscarder(logRotator(numToKeepStr:'10'))
timeout(time: 1, unit: 'HOURS')
ansiColor('xterm')
disableConcurrentBuilds()
}

  stages {
    stage('Create Environment') {
      steps {
         withCredentials ([
           usernamePassword(credentialsId: 'jenkins-bot', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASSWORD'),
           usernamePassword(credentialsId: 'TF-CREDS', usernameVariable: 'TF_AK', passwordVariable: 'TF_SK')
         ]) {
          sh '''
            export PATH=$PATH:"/usr/local/bin":"/.local/bin":
	          export AWS_ACCESS_KEY_ID=${TF_AK}
	          export AWS_SECRET_ACCESS_KEY=${TF_SK}
            export AWS_DEFAULT_REGION="eu-west-2"

            terraform init   
            terraform plan -lock=false -var "awsBuildAccountNumber=${awsBuildAccountNumber}" -var-file="env/${env}.tfvars"
          '''
         }
      }
    }

    stage('Apply Approval') {
      steps {
          input "Apply these changes?"
      }
    }	  

    stage('Terraform Apply') {
      steps {
         withCredentials ([usernamePassword(credentialsId: 'TF-CREDS', usernameVariable: 'TF_AK', passwordVariable: 'TF_SK')
        ]) {
          sh '''
            export PATH=$PATH:"/usr/local/bin":"/.local/bin":
	          export AWS_ACCESS_KEY_ID=${TF_AK}
	          export AWS_SECRET_ACCESS_KEY=${TF_SK}
            export AWS_DEFAULT_REGION="eu-west-2"

            terraform apply -auto-approve -lock=false -var "awsBuildAccountNumber=${awsBuildAccountNumber}" -var-file="env/${env}.tfvars"
          '''
      }
      }
    }
  }
}
