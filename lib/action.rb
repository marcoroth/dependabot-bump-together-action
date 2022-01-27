# frozen_string_literal: true

require 'dependabot/file_fetchers'
require 'dependabot/file_parsers'
require 'dependabot/update_checkers'
require 'dependabot/file_updaters'
require 'dependabot/pull_request_creator'
require 'dependabot/omnibus'

username = ENV['INPUT_USERNAME']
repo = ENV['GITHUB_REPOSITORY']
directory = ENV['INPUT_DIRECTORY']
branch = ENV['INPUT_BRANCH']
dependencies = ENV['INPUT_DEPENDENCIES']
package_managers_raw = ENV['INPUT_PACKAGE_MANAGERS']
access_token = ENV['INPUT_TOKEN']

updated_files_global = []
updated_deps_global = []
commit = nil

puts "INFO: using user: #{username}"
puts "INFO: using repo: #{repo}"
puts "INFO: using directory: #{directory}"
puts "INFO: using branch: #{branch}"

credentials = [
  {
    'type' => 'git_source',
    'host' => 'github.com',
    'username' => username,
    'password' => access_token
  }
]

source = Dependabot::Source.new(
  provider: 'github',
  repo: repo,
  directory: directory,
  branch: branch
)
puts ""

package_managers = package_managers_raw.to_s.split(',').map(&:strip)
puts "INFO: using package managers: #{package_managers.join(', ')}"

packages = dependencies.to_s.split(',').map(&:strip)
puts "INFO: processing packages: #{packages.join(', ')}"
puts ""

puts "INFO: no package manager provided. The provided input is \"#{package_managers_raw}\"" if package_managers.empty?
puts "INFO: no dependencies given. The provided input is \"#{dependencies}\"" if packages.empty?

package_managers.each do |package_manager|
  updated_deps_for_package_manager = []

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

  if packages.any?
    dependencies.select! { |dep|
      packages.include?(dep.name) ||
      (package_manager == "pip" && packages.include?(dep.name.split("[").first))
    }
  end

  # Get all updates that match list of packages
  dependencies.each do |dep|
    puts "INFO: processing #{package_manager} dependency #{dep.name} #{dep.version}"

    checker = Dependabot::UpdateCheckers.for_package_manager(package_manager).new(
      dependency: dep,
      dependency_files: files,
      credentials: credentials
    )

    if checker.up_to_date?
      puts "INFO: #{dep.name} #{dep.version} is up to date! Skipping..."
      puts ""

      next
    else
      puts "INFO: #{dep.name} is outdated and will be updated..."
      puts ""
    end

    checker.can_update?(requirements_to_unlock: :own)
    updated_deps = checker.updated_dependencies(requirements_to_unlock: :own)

    updated_deps_for_package_manager << updated_deps if updated_deps.any?
  end

  # Iteratively update files for each dependency
  deps = updated_deps_for_package_manager.flatten.uniq

  updater = Dependabot::FileUpdaters.for_package_manager(package_manager).new(
    dependencies: deps,
    dependency_files: files,
    credentials: credentials
  )

  # Overwrite files with changes for each update
  files = updater.updated_dependency_files

  begin
    updated_files_global << files
    updated_deps_global << deps
  rescue RuntimeError
    puts "INFO: No files to update for package manager '#{package_manager}'. Skipping..."

    next
  rescue Dependabot::SharedHelpers::HelperSubprocessFailed, StandardError => e
    puts "ERROR: Error while trying to retrieve updated files for package manager '#{package_manager}'. Reason: #{e}. Skipping..."
    puts e.backtrace

    next
  end
rescue => e
  puts "ERROR: while proccessing package manager '#{package_manager}'. Reason: #{e}"
  puts e.backtrace

  next
end

updated_deps_global = updated_deps_global.flatten.uniq
updated_files_global = updated_files_global.flatten.uniq

updated_deps_global.each do |updated_dep|
  new_ref = updated_dep.requirements&.first&.dig(:source, :ref)
  prev_ref = updated_dep.previous_requirements&.first&.dig(:source, :ref)
  file = updated_dep.requirements&.first&.dig(:file)

  puts "INFO: updated #{updated_dep.package_manager} dependency #{updated_dep.name} from #{prev_ref ? "#{prev_ref} ": ""}(#{updated_dep.previous_version}) to #{new_ref ? "#{new_ref} ": ""}(#{updated_dep.version}) in #{file}"
end

puts ""

updated_files_global.each do |updated_file|
  puts "INFO: going to commit changes in #{updated_file.name}"
end

if updated_deps_global.any? && updated_files_global.any?
  pr_creator = Dependabot::PullRequestCreator.new(
    source: source,
    base_commit: commit,
    dependencies: updated_deps_global,
    files: updated_files_global,
    credentials: credentials
  )

  pr = pr_creator.create

  puts ''

  if pr.to_h[:created_at].present?
    puts "INFO: Created PR with title '#{pr.to_h.dig(:title)}' (ID: ##{pr.to_h.dig(:number)}) in #{repo}"
    puts "INFO: #{pr.to_h.dig(:url).to_s.gsub('api.github.com/repos', 'github.com')}"
  else
    puts 'ERROR: PR already exists or an error has occurred'
  end
else
  puts 'INFO: no dependencies to update'
end
