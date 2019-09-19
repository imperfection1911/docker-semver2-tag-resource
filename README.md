# docker-semver2-tag-resource
Concourse resource provides semver2 docker tag

## Source Configuration

* `repo_path`:  _Required_ Location of repository in resource
* `redis_host`: _Required_ Redis server location. Used to store docker-tag between tasks

## Behavior

### Check: dummy
Nothing

### In: pull docker tag from redis
Pulling docker tag from redis by metadata variables($BUILD_TEAM_NAME:$BUILD_PIPELINE_NAME:$BUILD_ID)

### Out: push docker tag to redis
calculating docker tag by scheme

![text](https://github.com/imperfection1911/docker-semver2-tag-resource/blob/master/tag_diagram.png)

|Steps| Description| Docker tag|
|:-----:|:----------:|:-----------:|
|0| Push to git| |
|1|With git tag||
|2|Without git tag||
|3|If git tag match Semver2, then Docker Image tag will form as follows.| {Git Tag}-{Last sha-1 commit}|
|4|If git tag don't match Semver2, then Docker Image tag will form as follows.|dirty_tag-{Last sha-1 commit}|
|5|If branch name match regexp ^(feature\|bugfix\|hotfix\|release)/(.*)$ . Then branch name splits on '/' and tag equals right part and commit short hash|{$1}-{Last sha-1 commit}|
|6|Everything that don't match regexp ^(feature\|bugfix\|hotfix\|release)/(.*)$|{Branch name}-{Last sha-1 commit}|


## Example

Resource type

```
resource_types:
  - name: docker-tag
    type: docker-image
    source:
      username: {{registry_user}}
      password: {{registry_password}}
      repository: imperfection1911/concourse-tag-semver2-resource
```

Resource

```
resources:

  - name: repo
    type: git-multibranch
    source:
      uri: ((git_url))
      branches: '.*'
      private_key: {{git_key}}

  - name: docker-tag
    type: docker-tag
    source:
      repo_path: repo
      redis_host: redis.local
```

Job

```
jobs:
  - name: build_image

    plan:
      - get: repo
        trigger: true
        
      - put: docker-tag
      
      - get: docker-tag

      - put: docker_registry
        params:
          build: repo
          tag_file: docker-tag/tag
```
