pipeline {
    agent any
    tools {
        "org.jenkinsci.plugins.terraform.TerraformInstallation" "terraform"
    }
    parameters {
        string(name: 'CUSTOMER_NAME', description: 'Name to apply to the instance')
        // string(name: 'DATABASE_PASS', description: 'Password to apply to the newly created DB')
        // string(name: 'DOMAIN', description: '(Sub)Domain the LMS will be reachable at')
        string(name: 'CONSUL_STATE_PATH', defaultValue: 'tcc/us-east-1/instance/state/ins', description: 'Path in Consul for state data')
        string(name: 'WORKSPACE', defaultValue: 'dev', description:'workspace to use in Terraform')
    }

    environment {
        TF_HOME = tool('terraform')
        TF_INPUT = "0"
        TF_IN_AUTOMATION = "TRUE"
        TF_VAR_consul_address = "consul.totaratalent.com"
        TF_VAR_customer_name = "${params.CUSTOMER_NAME}"
        // TF_VAR_customer_pass = "${params.DATABASE_PASS}"
        // TF_VAR_customer_doma = "${params.DOMAIN}"
        TF_VAR_customer_envi = "${params.WORKSPACE}"
        TF_VAR_rds_pass = credentials('TF_VAR_rds_pass')
        TF_LOG = "WARN"
        CONSUL_HTTP_TOKEN = credentials('CONSUL_HTTP_TOKEN')
        CONSUL_HTTP_SSL = "true"
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        aws_profile = "ec4l"
        PATH = "$TF_HOME:$PATH"
    }

    stages {
        stage('NetworkInit'){
            steps {
                    sh 'terraform --version'
                    sh "terraform init --backend-config='path=${params.CONSUL_STATE_PATH}'"
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
        // stage('AnsibleValidation'){
        //     steps('Check'){
        //         sh 'ansible --version'
        //         sh 'ansible-playbook --version'
        //         sh 'ansible-lint --version'
        //         sh 'printenv | grep TF_VAR_'
        //     }
        // }
        // stage('RunPlaybook'){
        //     steps('Configurate'){
        //         ansiblePlaybook become: true, colorized: true, credentialsId: 'devops', disableHostKeyChecking: true, installation: 'ansible', inventory: 'ansible/hosts.aws_ec2.yml', playbook: 'ansible/init.yml'
        //     }
        // }
    }
}
