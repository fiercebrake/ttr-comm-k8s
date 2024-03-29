pipeline {
    agent any
    tools {
        "org.jenkinsci.plugins.terraform.TerraformInstallation" "terraform"
    }
    parameters {
        string(name: 'CUSTOMER_NAME', description: 'Name to apply to the instance')
        string(name: 'WORKSPACE', defaultValue: 'dev', description:'workspace to use in Terraform')
    }

    environment {
        TF_HOME = tool('terraform')
        TF_INPUT = "0"
        TF_IN_AUTOMATION = "TRUE"
        TF_VAR_consul_address = "consul.totaratalent.com"
        TF_VAR_customer_name = "${params.CUSTOMER_NAME}"
        TF_VAR_customer_envi = "${params.WORKSPACE}"
        TF_VAR_rds_pass = credentials('TF_VAR_rds_pass')
        TF_VAR_dok_user = "fierce.brake@gmail.com"
        TF_VAR_dok_pass = "dckr_pat_LQNgjuv7Qlq8_vtovVOGHSGYUps" 
        TF_LOG = "WARN"
        CONSUL_HTTP_TOKEN = credentials('CONSUL_HTTP_TOKEN')
        CONSUL_HTTP_SSL = "true"
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        aws_profile = "ec4l"
    }

    stages {
        stage('NetworkInit'){
            steps {
                    sh 'terraform --version'
                    sh "terraform init --backend-config='path=tcc/us-east-1/instance/state/ins'"
            }
        }
        stage('NetworkValidate'){
            steps {
                    sh 'terraform validate'
            }
        }
        stage('NetworkPlan'){
            steps {
                    script {
                        try {
                           sh "terraform workspace new ${params.WORKSPACE}"
                        } catch (err) {
                            sh "terraform workspace select ${params.WORKSPACE}"
                        }
                        sh "terraform plan -out terraform-networking.tfplan;echo \$? > status"
                        stash name: "terraform-networking-plan", includes: "terraform-networking.tfplan"
                    }
            }
        }
        stage('NetworkApply'){
            steps {
                script{
                    def apply = false
                    try {
                        input message: 'confirm apply', ok: 'Apply Config'
                        apply = true
                    } catch (err) {
                        apply = false
                            sh "terraform destroy -auto-approve"
                        currentBuild.result = 'UNSTABLE'
                    }
                    if(apply){
                            unstash "terraform-networking-plan"
                            sh 'terraform apply terraform-networking.tfplan'
                    }
                }
            }
        }
        stage('AnsibleValidation'){
            steps('Check'){
                sh 'ansible --version'
                sh 'ansible-playbook --version'
                sh 'ansible-lint --version'
            }
        }
        stage('RunPlaybook'){
            steps('Configurate'){
                ansiblePlaybook credentialsId: 'devops', disableHostKeyChecking: true, installation: 'ansible', inventory: 'ansible/hosts.aws_ec2.yml', playbook: 'ansible/init.yml'
            }
        }
    }
}
