pipeline {

    agent {
        label "node"
    }

    environment {
        mvnHome = tool('M3-slave')
        jdk = tool('JDK8-slave')
        scannerHome = tool('SonarQubeScanner')
        JAVA_HOME = "${jdk}"

        /* Duas maneiras de obter o branch-name em multibranch pipelines */
        BRANCH = "${env?.CHANGE_BRANCH ? env?.CHANGE_BRANCH : env?.BRANCH_NAME}"
        //BRANCH = sh(returnStdout: true, script: 'git rev-parse --abbrev-ref HEAD').trim()
    }

    parameters {
        booleanParam(name: "RELEASE", description: "Build a release (new version) from current commit.", defaultValue: false)
        string(name: "VERSION", description: "You want choice a specific version value?")
    }

    /*
    options {
        skipDefaultCheckout(true)
    }
    */

    stages {

        /*
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "$BRANCH"]],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [
                        [$class: 'WipeWorkspace'],
                        [$class: 'CleanBeforeCheckout'],
                        [$class: 'LocalBranch', localBranch: "$BRANCH"],
                    ],
                    submoduleCfg: [],
                    userRemoteConfigs: [[
                        credentialsId: '82c1ecee-eb52-4fed-98ca-2f1333f92965',
                        url: "${env?.GIT_URL}"
                    ]]
                ])
            }
        }

        stage('Update Versions') {
            steps{
                sh "mvn versions:use-latest-versions -DallowSnapshots=true -Dincludes=br.com.oobj*,br.com.noov*"
            }
        }

        stage('Commit Versions') {
            steps{
                sh "mvn versions:commit"
            }
        }
        */

        stage('Compile') {
            steps {
                sh "mvn -B clean compile test-compile"
            }
        }

        stage('Tests') {
            steps {
                sh "mvn -B test"
            }
        }

        stage('SonarQube') {
            steps {
                withSonarQubeEnv('Docker-Sonar') {
                    sh "mvn -B sonar:sonar -Dsonar.pullrequest.key=$BUILD_ID -Dsonar.branch.name=$BRANCH -Dsonar.host.url=https://sonar.oobj.com.br -Dsonar.login=admin -Dsonar.password=sonar@oobj!"
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Snapshot') {
            when {
                allOf {
                    not { changeRequest() }
                    anyOf {
                        branch 'master'
                        branch 'develop'
                    }
                }
            }
            steps {
                sh "mvn -B deploy -DskipTests"
            }
        }

        /*
        stage('Set Version') {
            when {
                allOf {
                    branch 'master'
                    expression { params.RELEASE }
                }
            }
            steps {
                sh "mvn -B versions:set -DnewVersion=${params.VERSION} versions:commit"
            }
        }

        stage('Changelog') {
            when {
                allOf {
                    branch 'master'
                    expression { params.RELEASE }
                }
            }
            steps {
                sh "mvn -B git-changelog-maven-plugin:git-changelog"
                sh "cat CHANGELOG.md"
                sh "git commit -a -m 'chore[changelog]: generating changelog'"
                sh "git push"
            }
        }
        */

        stage('Release') {
            when {
                allOf {
                    branch 'master'
                    expression { params.RELEASE }
                }
            }
            steps {
                sh "mvn -B release:clean \
                        release:prepare -DtagNameFormat=v@{project.version} -DcheckModificationExcludeList=pom.xml \
                        release:perform -DskipTests"
            }
        }

        /*
        stage('Build and Publish Image') {
            when {
                branch 'master'
            }
            steps {
                sh """
                    docker build -t ${IMAGE} .
                    docker tag ${IMAGE} ${IMAGE}:${VERSION}
                    docker push ${IMAGE}:${VERSION}
                """
          }
        }
        */

        //Se estiver em alguma branch fix/feat fa o merge para develop. Se estiver na branch develop, faz o merge na master
        // na develop, sobe a versão do artefato de acordo com a mensagem do commit. commit conventions
    }

    post {
        always {
            echo "post always"
        }
        success{
            echo "post success"
        }
        failure{
            echo "post failure"
        }
        unstable {
            echo "post unstable"
        }
        changed {
            echo "post changed"
        }
    }
}