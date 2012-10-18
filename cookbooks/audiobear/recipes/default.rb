include_recipe "build-essential"
include_recipe "git"
include_recipe "redis"

username = node['audiobear']['user']
user username  do
  comment "AudioBear Developer"
  uid 2001
  gid "users"
  home "/home/#{username}"
  shell node['audiobear']['user']['shell']
end

