pipeline {
    agent any

    environment {
        TF_STATE_BUCKET = 'backstage-jenkins-iac'
        TF_STATE_REGION = 'us-east-1'
    }

    parameters {
        string(name: 'BUCKET_NAME', description: 'Name of the S3 Bucket')
        string(name: 'REGION', defaultValue: 'us-east-1', description: 'AWS Region')
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Action to perform')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                script {
                    if (!params.BUCKET_NAME) {
                        error "BUCKET_NAME parameter is required"
                    }
                }
                sh '''
                    terraform init \
                    -backend-config="bucket=${TF_STATE_BUCKET}" \
                    -backend-config="key=s3/${BUCKET_NAME}.tfstate" \
                    -backend-config="region=${TF_STATE_REGION}"
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                // Using usernamePassword binding as it's very common and works with AWS keys
                withCredentials([usernamePassword(credentialsId: 'backstage-jenkins-iac-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        terraform plan \
                        -var="bucket_name=${BUCKET_NAME}" \
                        -var="region=${REGION}" \
                        -out=tfplan
                    '''
                }
            }
        }

        stage('Terraform Apply/Destroy') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'backstage-jenkins-iac-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    script {
                        if (params.ACTION == 'destroy') {
                            sh 'terraform destroy -auto-approve -var="bucket_name=${BUCKET_NAME}" -var="region=${REGION}"'
                        } else {
                            sh 'terraform apply -auto-approve tfplan'
                        }
                    }
                }
            }
        }
    }
}
