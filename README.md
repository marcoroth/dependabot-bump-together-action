# Dependabot Bump Together GitHub Action

GitHub Action to bump multiple dependencies with [dependabot](https://dependabot.com) in a single pull request.

## Example usage

Here is an example how to use this action:

```yaml
uses: marcoroth/dependabot-bump-together-action@master
  with:
    packages: dependency_1, dependency_2
    package_managers: bundler, npm_and_yarn
    directory: /
    branch: development
    username: x-access-token
    bundler_version: 2.3.5
    dependabot_version: 0.171.2
    token: ${{ secrets.GITHUB_ACCESS_TOKEN }}
```

## Inputs

These options can be provided via `with:` in the workflow file.

### `dependencies`

**Required:** Comma-separated list of the dependencies dependabot should bump together


### `package_managers`

**Required:** Comma-separated list of the package managers dependabot should update.

Default value: `bundler, npm_and_yarn`

The available options are:

- `bundler`
- `pip` (includes pipenv)
- `npm_and_yarn`
- `maven`
- `gradle`
- `cargo`
- `hex`
- `composer`
- `nuget`
- `dep`
- `go_modules`
- `elm`
- `submodules`
- `docker`
- `terraform`


### `directory`

**Required:** Directory in which the project to update lives

Default value: `/`


### `branch`

**Required:** Branch dependabot runs against

Default value: `master`


### `username`

**Required:** The user to create the pull request

Default value: `x-access-token`


### `token`

**Required:** A GitHub [Access Token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) with permission to create the pull request and access potential private repos dependabot should bump.


### `bundler_version`

Bundler version to use

Default value: `2.3.5`


### `dependabot_version`

Dependabot version to use

Default value: `0.171.2`


## Ressources

This GitHub Action depends on the [`dependabot/dependabot-core`](https://hub.docker.com/r/dependabot/dependabot-core) Docker image and uses a modified version of the [dependabot/dependabot-script](https://github.com/dependabot/dependabot-script) `update-script.rb` to bump the dependencies.
