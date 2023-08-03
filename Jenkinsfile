pipeline {

    parameters {
        choice(name: 'action', choices: ['apply','destroy'], description: 'You want to apply or destrosy?')
    } 
    environment {
         AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
         AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

   agent  any
    stages {
         stage('checkout') {
            steps {
                 script{
                        dir("terraform")
                        {
                            git credentialsId: 'MadgicalGithub' , url: 'git@github.com:madgicaltechdom/rezo-infrastructure-aws.git'
                        }
                    }
                }
            }
        stage('terraform action') {
            steps {
                sh ('terraform ${action} --auto-approve')
            }
        }
       
    }

  }