# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.6'
git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'aws-sdk-s3', '~> 1'