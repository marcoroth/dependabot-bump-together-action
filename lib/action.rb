# frozen_string_literal: true

require 'dependabot/file_fetchers'
require 'dependabot/file_parsers'
require 'dependabot/update_checkers'
require 'dependabot/file_updaters'
require 'dependabot/pull_request_creator'
require 'dependabot/omnibus'

credentials = [
  {
    'type' => 'git_source',
    'host' => 'github.com',
    'username' => ENV['INPUT_USERNAME'],
    'password' => ENV['INPUT_TOKEN']
  }
]

source = Dependabot::Source.new(
  provider: 'github',
  repo: ENV['GITHUB_REPOSITORY'],
  directory: ENV['INPUT_DIRECTORY'],
  branch: ENV['INPUT_BRANCH']
)

updated_files_global = []
updated_deps_global = []
commit = nil

package_managers = ENV['INPUT_PACKAGE_MANAGERS'].split(",").map(&:strip) || %w[bundler npm_and_yarn]

package_managers.each do |package_manager|
  fetcher = Dependabot::FileFetchers.for_package_manager(package_manager).new(
    source: source,
    credentials: credentials
  )

  files = fetcher.files
  commit = fetcher.commit

  parser = Dependabot::FileParsers.for_package_manager(package_manager).new(
    dependency_files: files,
    source: source,
    credentials: credentials
  )

  dependencies = parser.parse

  if ENV['INPUT_DEPENDENCIES']
    packages = ENV['INPUT_DEPENDENCIES'].split(",").map(&:strip)

    dependencies.select! { |dep| packages.include?(dep.name) }
  end

  dependencies.each do |dep|
    puts "INFO: processing dependency #{dep.name} #{dep.version}"

    checker = Dependabot::UpdateCheckers.for_package_manager(package_manager).new(
      dependency: dep,
      dependency_files: files,
      credentials: credentials
    )

    next if checker.up_to_date?

    checker.can_update?(requirements_to_unlock: :own)
    updated_deps = checker.updated_dependencies(requirements_to_unlock: :own)

    updater = Dependabot::FileUpdaters.for_package_manager(package_manager).new(
      dependencies: updated_deps,
      dependency_files: files,
      credentials: credentials
    )

    updated_deps_global << updated_deps
    updated_files_global << updater.updated_dependency_files
  end
end

updated_deps_global.flatten!
updated_files_global.flatten!

puts updated_deps_global.inspect
puts updated_files_global.inspect

if updated_deps_global.any? || updated_files_global.any?

  pr_creator = Dependabot::PullRequestCreator.new(
    source: source,
    base_commit: commit,
    dependencies: updated_deps_global,
    files: updated_files_global,
    credentials: credentials
  )

  pr_creator.create
else
  puts 'Nothing to update'
end
