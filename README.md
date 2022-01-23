# Dependabot Bump Together GitHub Action

GitHub Action to bump multiple dependencies with [Dependabot](https://dependabot.com) in a single pull request.

## Example usage

Here is an example how to use this action:

```yaml
name: Dependabot
on:
  workflow_dispatch:
  schedule:
    - cron: "0 0 * * *"
jobs:
  check-dependencies:
    runs-on: ubuntu-latest
    steps:
      - uses: marcoroth/dependabot-bump-together-action@main
        with:
          dependencies: dependency_1, dependency_2
          package_managers: bundler, npm_and_yarn, pip
          directory: /
          branch: main
          username: x-access-token
          token: ${{ secrets.GITHUB_TOKEN }}
```

## Inputs

These options can be provided via `with:` in the workflow file.

### `dependencies`

**Required:** Comma-separated list of the dependencies Dependabot should bump together


### `package_managers`

**Required:** Comma-separated list of the package managers Dependabot should update.

Default value: `bundler, npm_and_yarn, pip`

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

**Required:** The branch Dependabot runs against in your repository.

Default value: `main`


### `username`

**Required:** The user to create the pull request

Default value: `x-access-token`


### `token`

**Required:** A GitHub [Access Token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) with permission to create the pull request and access potential private repos Dependabot should bump.


## Ressources

This GitHub Action depends on the [`dependabot/dependabot-core`](https://hub.docker.com/r/dependabot/dependabot-core) Docker Image and uses a modified version of the [dependabot/dependabot-script](https://github.com/dependabot/dependabot-script) `update-script.rb` to bump the dependencies.
