# Bit Jenkins Examples for Git CI/CD Pipelines
Example Jenkin Files for common Bit and Git CI/CD workflows.

## Setup Guide

1. [Install](https://www.jenkins.io/doc/book/installing/) Jenkins
2. [Install](https://plugins.jenkins.io/docker-workflow/) Docker Pipeline Plugin.
3. Follow steps `New Items -> Pipeline -> Pipeline script from SCM` and select any of the scripts inside the `jenkins-files` directory of this repository.

    Following is an example Jenkins CI/CD pipeline task file of checking the Bit version available in the docker container.
  
    ```
    # @file jenkins-files/bit-init
    pipeline {
      agent {
        docker { image 'bitsrc/stable:latest' }
      }
      stages {
        stage('build') {
          steps {
            sh 'bit -v'
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
| Bit Merge Request Build    | [jenkins-files/merge-request](/jenkins-files/merge-request) |
| Bit Lane Cleanup           | [jenkins-files/lane-cleanup](/jenkins-files/lane-cleanup) |
| Commit Bitmap              | [jenkins-files/commit-bitmap](/jenkins-files/commit-bitmap) |

  :arrow_down: [Download Files](https://github.com/bit-tasks/github-action-examples/raw/main/downloads/automating-component-releases.zip)

### Update Workspace Components, External Dependencies and Envs

| Task                        | Example                         |
|-----------------------------|---------------------------------|
| Dependency Update           | [jenkins-files/dependency-update](/jenkins-files/dependency-update)   |

  :arrow_down: [Download Files](https://github.com/bit-tasks/github-action-examples/raw/main/downloads/dependency-update.zip)

### Sync Git Branches with Bit Lanes

| Task                        | Example                         |
|-----------------------------|---------------------------------|
| Branch Lane                 | [jenkinbs-files/branch-lane](/jenkins-files/branch-lane)  |

  :arrow_down: [Download Files](https://github.com/bit-tasks/github-action-examples/raw/main/downloads/branch-lane.zip)


## Usage Documentation

You can use the Bit commands referring to the [Bit shell script examples](https://github.com/bit-tasks/shell-scripts) and add additional functionality depending on your Git version control platform (e.g GitHub or GitLab).

### 1. Bit Initialization

*Source:* [script details](https://github.com/bit-tasks/shell-scripts/blob/main/scripts/bit-init.sh)

The Bit Docker image comes with the latest Bit version pre-installed. Still, the `gitlab.bit.init` script provides:

- Verification and possible installation of the relevant version as specified in the `engine` block of your `workspace.jsonc`.
- Initialization of default `org` and `scope` variables for further tasks.
- Execution of the `bit install` command inside the workspace.

#### Example

```
pipeline {
  agent {
    docker { image 'bitsrc/stable:latest' }
  }
  environment {
    GIT_USER_NAME = 'git_user_name'
    GIT_USER_EMAIL = 'git_user_email'
    BIT_CONFIG_USER_TOKEN = 'bit_user_token'
  }
  stages {
    stage('build') {
      steps {
        sh 'cd my-workspace-dir'
        script {
          sh '''
            #!/bin/bash
            
            WSDIR="my-workspace-dir" # Specify your workspace directory
            BIT_VERSION="0.2.8" # Leave empty for the latest version
            
            # install bvm and bit
            npm i -g @teambit/bvm
            bvm install ${BIT_VERSION} --use-system-node
            export PATH="${HOME}/bin:${PATH}" # This step may change depending on your CI runner
            
            # change to the working directory before running bit install
            cd ${WSDIR}
            bit install
        '''
        }
      }
    }
  }
}
```

### 2. Bit Verification: `gitlab.bit.verify`

```bash
gitlab.bit.verify
```
*Source:* [script details](https://github.com/bit-tasks/shell-scripts/blob/main/scripts/bit-verify.sh)

#### Parameters (Optional)

- `--skip-build`: This parameter, like `gitlab.bit.verify --skip-build`, prevents the `bit build` command execution.

#### Example

```
pipeline {
  agent {
    docker { image 'bitsrc/stable:latest' }
  }
  environment {
    GIT_USER_NAME = 'git_user_name'
    GIT_USER_EMAIL = 'git_user_email'
    BIT_CONFIG_USER_TOKEN = 'bit_user_token'
  }
  stages {
    stage('build') {
      steps {
        sh 'cd my-workspace-dir'
        script {
          sh '''
            #!/bin/bash
            
            WSDIR="my-workspace-dir" # Specify your workspace directory
            BIT_VERSION="0.2.8" # Leave empty for the latest version
            
            # install bvm and bit
            npm i -g @teambit/bvm
            bvm install ${BIT_VERSION} --use-system-node
            export PATH="${HOME}/bin:${PATH}" # This step may change depending on your CI runner
            
            # change to the working directory before running bit install
            cd ${WSDIR}
            bit install
            
            # added from bit-verify.sh
            bit status --strict
            bit build
        '''
        }
      }
    }
  }
}
```

## Contributor Guide

To contribute, make updates to scripts starting with `gitlab.bit.` in the [Bit Docker Image Repository](https://github.com/bit-tasks/bit-docker-image).

To create zip files use the below commands.

```bash
chmod +x zip_files.sh
bash ./zip_files.sh
```
