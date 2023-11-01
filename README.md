# Bit Jenkins Examples for Git CI/CD Pipelines
Example Jenkin Files for common Bit and Git CI/CD workflows.

## Setup Guide

1. [Install](https://www.jenkins.io/doc/book/installing/) Jenkins
2. [Install](https://plugins.jenkins.io/docker-workflow/) Docker Pipeline Plugin.
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
        BIT_CONFIG_USER_TOKEN = 'bit_user_token'
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
    BIT_CONFIG_USER_TOKEN = 'bit_user_token'
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
    BIT_CONFIG_USER_TOKEN = 'bit_user_token'
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

## Contributor Guide

To contribute, make updates to scripts starting with `gitlab.bit.` in the [Bit Docker Image Repository](https://github.com/bit-tasks/bit-docker-image).

To create zip files use the below commands.

```bash
chmod +x zip_files.sh
bash ./zip_files.sh
```
