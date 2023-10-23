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

The docker images comes with the support for GitHub (`github.bit.<command>` and GitLab (`gitlab.bit.<command>`). If you use a different Git version control system, you can use the Bit commands referring to the [Bit shell script examples](https://github.com/bit-tasks/shell-scripts). 

let's look at several examples of using Jenkins with GitLab.

### 1. Bit Initialization: `gitlab.bit.init`

```bash
gitlab.bit.init
```
*Source:* [script details](https://github.com/bit-tasks/bit-docker-image/blob/main/scripts/gitlab.bit.init)

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
  }
  stages {
    stage('build') {
      steps {
        sh 'cd my-workspace-dir'
        sh 'gitlab.bit.init'
      }
    }
  }
}
```
### 2. Bit Verification: `gitlab.bit.verify`

```bash
gitlab.bit.verify
```
*Source:* [script details](https://github.com/bit-tasks/bit-docker-image/blob/main/scripts/gitlab.bit.verify)

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
  }
  stages {
    stage('build') {
      steps {
        sh 'cd my-workspace-dir'
        sh 'gitlab.bit.init'
        sh 'gitlab.bit.verify'
      }
    }
  }
}
```

### 3. Bit Commit Bitmap: `gitlab.bit.commit-bitmap`

```bash
gitlab.bit.commit-bitmap --skip-ci
```
*Source:* [script details](https://github.com/bit-tasks/bit-docker-image/blob/main/scripts/gitlab.bit.commit-bitmap)

#### Parameters (Optional)

- `--skip-push`: Avoids pushing changes; useful for tests.
- `--skip-ci`: Prevents re-triggering CI on code push, avoiding potential loops.

#### Example

```
pipeline {
  agent {
    docker { image 'bitsrc/stable:latest' }
  }
  environment {
    GIT_USER_NAME = 'git_user_name'
    GIT_USER_EMAIL = 'git_user_email'
  }
  stages {
    stage('build') {
      steps {
        sh 'cd my-workspace-dir'
        sh 'gitlab.bit.init'
        sh 'gitlab.bit.commit-bitmap --skip-ci'
      }
    }
  }
}
```

### 4. Bit Merge Request: `gitlab.bit.merge-request`

```bash
gitlab.bit.merge-request
```
*Source:* [script details](https://github.com/bit-tasks/bit-docker-image/blob/main/scripts/gitlab.bit.merge-request)

Execute this script when a Merge Request is created. It verifies the components and create a lane in [bit.cloud](https://bit.cloud) for previewing and testing components.

#### Example

```
pipeline {
  agent {
    docker { image 'bitsrc/stable:latest' }
  }
  environment {
    GIT_USER_NAME = 'git_user_name'
    GIT_USER_EMAIL = 'git_user_email'
  }
  stages {
    stage('build') {
      steps {
        sh 'cd my-workspace-dir'
        sh 'gitlab.bit.init'
        sh 'gitlab.bit.merge-request'
      }
    }
  }
}
```

### 5. Bit Lane Cleanup: `gitlab.bit.lane-cleanup`

```bash
gitlab.bit.lane-cleanup
```
*Source:* [script details](https://github.com/bit-tasks/bit-docker-image/blob/main/scripts/gitlab.bit.lane-cleanup)

Execute this script when code is pushed to the main branch. It will detect whether the push is a result of a merge request merge event and will then proceed to clean up the lane.

#### Example

```
pipeline {
  agent {
    docker { image 'bitsrc/stable:latest' }
  }
  environment {
    GIT_USER_NAME = 'git_user_name'
    GIT_USER_EMAIL = 'git_user_email'
  }
  stages {
    stage('build') {
      steps {
        sh 'cd my-workspace-dir'
        sh 'gitlab.bit.init'
        sh 'gitlab.bit.lane-cleanup'
      }
    }
  }
}
```

### 6. Bit Tag and Export: `gitlab.bit.tag-export`

```bash
gitlab.bit.tag-export
```
*Source:* [script details](https://github.com/bit-tasks/bit-docker-image/blob/main/scripts/gitlab.bit.tag-export)

Tag component versions using labels on Merge Requests or within Merge Request/Commit titles. Use version keywords `major`, `minor`, `patch`, and `pre-release`.

> **Note:** If a Merge Request is merged, track it via its `merge commit` in the target branch. For the action to detect the version keyword, the `merge commit` should be the recent one in the commit history.

#### Example

```
pipeline {
  agent {
    docker { image 'bitsrc/stable:latest' }
  }
  environment {
    GIT_USER_NAME = 'git_user_name'
    GIT_USER_EMAIL = 'git_user_email'
  }
  stages {
    stage('build') {
      steps {
        sh 'cd my-workspace-dir'
        sh 'gitlab.bit.init'
        sh 'gitlab.bit.tag-export'
      }
    }
  }
}
```

### 7. Bit Branch and Lane: `gitlab.bit.branch-lane`

```bash
gitlab.bit.branch-lane
```
*Source:* [script details](https://github.com/bit-tasks/bit-docker-image/blob/main/scripts/gitlab.bit.branch-lane)

Execute this script when a new branch is created in Git. It will create a lane in [bit.cloud](https://bit.cloud) for each new Branch and keep the lane in sync with the components modified in Git.

#### Example

```
pipeline {
  agent {
    docker { image 'bitsrc/stable:latest' }
  }
  environment {
    GIT_USER_NAME = 'git_user_name'
    GIT_USER_EMAIL = 'git_user_email'
  }
  stages {
    stage('build') {
      steps {
        sh 'cd my-workspace-dir'
        sh 'gitlab.bit.init'
        sh 'gitlab.bit.branch-lane'
      }
    }
  }
}
```

### 8. Bit Dependency Update: `gitlab.bit.dependency-update`

```bash
gitlab.bit.dependency-update --allow "envs, workspace-components"
```
*Source:* [script details](https://github.com/bit-tasks/bit-docker-image/blob/main/scripts/gitlab.bit.dependency-update)

Run this script as a [scheduled pipeline](https://docs.gitlab.com/ee/ci/pipelines/schedules.html), which will create a merge request to the specified branch with the updated dependencies.

#### Parameters (Optional)

- `--allow`: Allow different types of dependencies. Options `all`, `external-dependencies`, `workspace-components`, `envs`. You can also use a combination of one or two values, e.g. `gitlab.bit.dependency-update --allow "external-dependencies, workspace-components"`. Default `all`.
- `--branch`: Branch to check for dependency updates. Default `main`.

#### Example

```
pipeline {
  agent {
    docker { image 'bitsrc/stable:latest' }
  }
  environment {
    GIT_USER_NAME = 'git_user_name'
    GIT_USER_EMAIL = 'git_user_email'
  }
  stages {
    stage('build') {
      steps {
        sh 'cd my-workspace-dir'
        sh 'gitlab.bit.init'
        sh 'gitlab.bit.dependency-update --allow "all" --branch "main"'
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
