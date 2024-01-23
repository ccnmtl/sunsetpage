// Sandbox approvals that you will need (at least):
// staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods plus java.lang.Object[]
// staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods getAt java.lang.Iterable int
// java.lang.Object[]
// staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods plus java.util.List java.lang.Object

TAG = 'build-' + env.BUILD_NUMBER
env.TAG = TAG

// check for required parameters. assign them to the env for
// convenience and make sure that an exception is raised if any
// are missing as a side-effect

env.APP = APP
env.REPO = REPO

def staging_hosts = STAGING_HOSTS.split(" ")
def prod_hosts = PROD_HOSTS.split(" ")

def err = null
currentBuild.result = "SUCCESS"

try {
    node {
        stage 'Checkout'
        checkout scm

        stage "Docker Build"
        retry_backoff(5) { sh "docker pull ${REPO}/${APP}:latest" }
        sh "make build"

        stage "Docker Push"
        retry_backoff(5) { sh "docker push ${REPO}/${APP}:${TAG}" }
    }

    node {
        def branches = [:]
        stage "Docker Pull (staging)"

        for (int i = 0; i < staging_hosts.size(); i++) {
            branches["pull-${i}"] = create_pull_exec(i, staging_hosts[i])
        }
        parallel branches
    }

    node {
        stage "Restart Service (staging)"
        def branches = [:]
        for (int i = 0; i < staging_hosts.size(); i++) {
            branches["web-restart-${i}"] = create_restart_web_exec(i, staging_hosts[i])
        }
        parallel branches
    }

    node {
        def branches = [:]
        stage "Docker Pull (prod)"

        for (int i = 0; i < prod_hosts.size(); i++) {
            branches["pull-${i}"] = create_pull_exec(i, prod_hosts[i])
        }
        parallel branches
    }

    node {
        stage "Restart Service (prod)"
        def branches = [:]
        for (int i = 0; i < prod_hosts.size(); i++) {
            branches["web-restart-${i}"] = create_restart_web_exec(i, prod_hosts[i])
        }
        parallel branches
    }

} catch (caughtError) {
    err = caughtError
    currentBuild.result = "FAILURE"
} finally {
    (currentBuild.result != "ABORTED") && node {
        notifyBuild(currentBuild.result)
    }

    /* Must re-throw exception to propagate error */
        if (err) {
        throw err
    }
}

// -------------------- helper functions ----------------------

def notifyBuild(String buildStatus = 'STARTED') {
    // build status of null means successful
    buildStatus =  buildStatus ?: 'SUCCESS'

    // Default values
    def colorCode = '#FF0000'
    def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
    def summary = "${subject} (${env.BUILD_URL})"
    def details = """<p>STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
    <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>"""

    // Override default values based on build status
    if (buildStatus == 'STARTED') {
        color = 'YELLOW'
        colorCode = '#FFFF00'
    } else if (buildStatus == 'SUCCESS') {
        color = 'GREEN'
        colorCode = '#36a64f'
    } else {
        color = 'RED'
        colorCode = '#FF0000'
    }

    // Send notifications
    //  slackSend (color: colorCode, message: summary)

    // step([$class: 'Mailer',
    //         notifyEveryUnstableBuild: true,
    //         recipients: ADMIN_EMAIL,
    //         sendToIndividuals: true])
}

def create_pull_exec(int i, String host) {
    cmd = {
        node {
            sh """
ssh ${host} docker pull \${REPOSITORY}\$REPO/${APP}:\$TAG
            ssh ${host} cp /var/www/${APP}/TAG /var/www/${APP}/REVERT || true
ssh ${host} "echo export TAG=\$TAG > /var/www/${APP}/TAG"
"""
        }
    }
    return cmd
}

def create_restart_web_exec(int i, String host) {
    cmd = {
        node {
            sh """
ssh ${host} sudo /usr/sbin/service ${APP} stop || true
ssh ${host} sudo /usr/sbin/service ${APP} start
"""
        }
    }
    return cmd
}

// retry with exponential backoff
def retry_backoff(int max_attempts, Closure c) {
    int n = 0
    while (n < max_attempts) {
        try {
            c()
            return
        } catch (err) {
            if ((n + 1) >= max_attempts) {
                // we're done. re-raise the exception
                throw err
            }
            sleep(2**n)
            n++
            }
    }
    return
}