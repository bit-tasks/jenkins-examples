# Bit Jenkins Examples for Git CI/CD Pipelines
Example Jenkin Files for common Bit and Git CI/CD workflows.

## Setup Guide

1. Jenkins Setup
   - [Install](https://www.jenkins.io/doc/book/installing/) Jenkins. Example [Setting up Jenkins in AWS Guide](https://www.jenkins.io/doc/tutorials/tutorial-for-installing-jenkins-on-AWS/).
   - [Install](https://plugins.jenkins.io/docker-workflow/) Docker Pipeline Plugin.
   - Ensure that your Build Nodes can run docker. Example If you use the Jenkins Host to run build tasks in an Amazon Linux instance, use the following steps.
     1. **Update the System:** `sudo yum update`
     2. **Install Docker:** `sudo yum install docker`
     3. **Start and Enable Docker:** `sudo service docker start sudo chkconfig docker on`
     4. **Add Jenkins User to Docker Group:** `sudo usermod -aG docker jenkins`
     5. **Verify Docker Installation:** `docker --version`
     6. **Restart Jenkins (If on Host):** `sudo service jenkins restart`
2. Use BIT_CONFIG_USER_TOKEN ([docs](https://bit.dev/reference/ci/jenkins#generating-an-access-token)).
        
3. Follow steps `New Items -> Pipeline -> Pipeline script` and select any of the scripts inside the `jenkins-files` and copy-paste its content.

    Following is an example Jenkins CI/CD pipeline script of checking the Bit version available in the docker container.

    ```
    pipeline {
      agent {
        docker {
            image 'bitsrc/stable:latest'
            args '-u root --privileged'
        }
      }
      environment {
        GIT_USER_NAME = 'git_user_name'
        GIT_USER_EMAIL = 'git_user_email'
        BIT_CONFIG_USER_TOKEN = 'bit_config_access_token'
      }
      stages {
        stage('Test Bit Version') {
          steps {
            script {
              sh '''
                bit -v
              '''
            }
          }
        }
      }
    }
    ```

## Bit Docker Image
You can configure support through the [Bit Docker image](https://github.com/bit-tasks/bit-docker-image). Select from these available images:

- **Latest Stable:** 
  ```
  bitsrc/stable:latest
  ```
  
- **Nightly:** 
  ```bash
  bitsrc/nightly:latest
  ```

### Automating Component Release

| Task                        | Example                         | 
|-----------------------------|---------------------------------|
| Initialize Bit             | [jenkins-files/bit-init](/jenkins-files/bit-init)           |
| Bit Verify Components      | [jenkins-files/verify](/jenkins-files/verify)               |
| Bit Tag and Export         | [jenkins-files/tag-export](/jenkins-files/tag-export)       |
| Bit Merge Request Build    | [jenkins-files/pull-request](/jenkins-files/pull-request) |
| Bit Lane Cleanup           | [jenkins-files/lane-cleanup](/jenkins-files/lane-cleanup) |
| Commit Bitmap              | [jenkins-files/commit-bitmap](/jenkins-files/commit-bitmap) |

  :arrow_down: [Download Files](https://github.com/bit-tasks/github-action-examples/raw/main/downloads/automating-component-releases.zip)

### Update Workspace Components, External Dependencies and Envs

| Task                        | Example                         |
|-----------------------------|---------------------------------|
| Dependency Update           | [jenkins-files/bit-dependency-update](/jenkins-files/dependency-update)   |

  :arrow_down: [Download Files](https://github.com/bit-tasks/github-action-examples/raw/main/downloads/dependency-update.zip)

### Sync Git Branches with Bit Lanes

| Task                        | Example                         |
|-----------------------------|---------------------------------|
| Branch Lane                 | [jenkinbs-files/bit-branch-lane](/jenkins-files/branch-lane)  |
| Lane Branch                 | [jenkinbs-files/bit-lane-branch](/jenkins-files/lane-branch)  |

  :arrow_down: [Download Files](https://github.com/bit-tasks/github-action-examples/raw/main/downloads/branch-lane.zip)


## Usage Documentation

You can use the Bit commands referring to the [Bit shell script examples](https://github.com/bit-tasks/shell-scripts) and add additional functionality depending on your Git version control platform (e.g GitHub or GitLab).

### 1. Bit Initialization

*Source:* [script details](https://github.com/bit-tasks/shell-scripts/blob/main/scripts/bit-init.sh)

The Bit Docker image comes with the latest Bit version pre-installed. Therefore, you only need to run `bit install` inside the workspac directory in your script.

#### Example

```
pipeline {
  agent {
    docker {
      image 'bitsrc/stable:latest'
      args '-u root --privileged'
    }
  }
  environment {
    GIT_USER_NAME = 'git_user_name'
    GIT_USER_EMAIL = 'git_user_email'
    BIT_CONFIG_USER_TOKEN = 'bit_config_access_token'
  }
  stages {
    stage('Build') {
      steps {
        script {
          sh '''
            cd "my-workspace-directory"
            bit install
          '''
        }
      }
    }
  }
  post {
    always {
      script {
        cleanWs()
      }
    }
  }
}
```

If you need to install a different version of Bit, you can include the following script.

```sh
  BIT_VERSION="0.2.8"
  
  # install bvm and bit
  npm i -g @teambit/bvm
  bvm install ${BIT_VERSION} --use-system-node
  export PATH="${HOME}/bin:${PATH}" # This step may change depending on your CI runner

  cd "my-workspace-directory"
  bit install
```

### 2. Bit Verification

*Source:* [script details](https://github.com/bit-tasks/shell-scripts/blob/main/scripts/bit-verify.sh)

#### Example

```
pipeline {
  agent {
    docker {
      image 'bitsrc/stable:latest'
      args '-u root --privileged'
    }
  }
  environment {
    GIT_USER_NAME = 'git_user_name'
    GIT_USER_EMAIL = 'git_user_email'
    BIT_CONFIG_USER_TOKEN = 'bit_config_access_token'
  }
  stages {
    stage('Build') {
      steps {
        script {
          sh '''
            # added from bit-init.sh
            cd "my-workspace-directory"
            bit install

            # added from bit-verify.sh
            bit status --strict
            bit build
          '''
        }
      }
    }
  }
  post {
    always {
      script {
        cleanWs()
      }
    }
  }
}
```

For other Bit and Git CI/CD pipelines tasks refer [Shell Scripts](https://github.com/bit-tasks/shell-scripts).

## Setup PNPM Caching
You can speed up the CI builds by caching the `pnpm store` by mounting it from the Jenkins host.

```
pipeline {
  agent {
    docker {
      image 'bitsrc/stable:latest'
      args '-u root --privileged -v /jenkins/caches/my-workspace-directory/.pnpm-store:/my-workspace-directory/.pnpm-store'
    }
  }
  environment {
    GIT_USER_NAME = 'git_user_name'
    GIT_USER_EMAIL = 'git_user_email'
    BIT_CONFIG_USER_TOKEN = 'bit_config_access_token'
    PNPM_STORE = '/my-workspace-directory/.pnpm-store' // Define the environment variable for the pnpm store path
  }
  stages {
    stage('Build') {
      steps {
        script {
          sh '''
            # Configure pnpm to use the mounted cache directory
            pnpm config set store-dir $PNPM_STORE

            # Proceed with bit and pnpm commands
            cd "my-workspace-directory"
            bit install

            # Verify and build operations
            bit status --strict
            bit build
          '''
        }
      }
    }
  }
  post {
    always {
      script {
        cleanWs(notFailBuild: true)
      }
    }
  }
}
```

**Note:** The exact volume path that you mount may depend on your Jenkins host configuration.

## Contributor Guide

To contribute, make updates to scripts starting with `gitlab.bit.` in the [Bit Docker Image Repository](https://github.com/bit-tasks/bit-docker-image).

To create zip files use the below commands.

```bash
chmod +x zip-files.sh
bash ./zip-files.sh
```
