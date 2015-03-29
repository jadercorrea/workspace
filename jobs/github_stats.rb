require 'octokit'
require 'action_view'
include ActionView::Helpers::DateHelper

def config
  config = YAML::load_file('config.yml')

  Octokit.configure do |c|
    c.auto_paginate = true
    c.login = config['github_login']
    c.password = config['github_password']
  end
  config["repos"]
end

def git_send(repo_name)
    repo = Octokit::Client.new.repository(repo_name)
    pulls = Octokit.pulls(repo_name, :state => 'open').count

    send_event('github', {
      repo: repo_name.slice(/([^\/]+)$/),
      issues: repo.open_issues_count - pulls,
      pulls: pulls,
      forks: repo.forks,
      watchers: repo.subscribers_count,
      stargazers: repo.stargazers_count,
      activity: time_ago_in_words(repo.updated_at).capitalize
    })
end

SCHEDULER.every '3m', :first_in => 0 do |job|
  repos = repos || config

  repos.each do |name|
    git_send(name)
  end
end
