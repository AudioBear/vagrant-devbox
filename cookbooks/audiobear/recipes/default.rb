include_recipe "build-essential"
include_recipe "git"
include_recipe "redis"
include_recipe "nginx"
include_recipe "tup"

username = node['audiobear']['user']
userhome ="/home/#{username}"
www_user = username

user username  do
  comment "AudioBear Developer"
  uid 2002
  gid "users"
  home userhome 
  shell node['audiobear']['user_shell']
end

www_files = "#{userhome}/Projects/audiobear-www-releases" 
www_working_copy = "#{userhome}/Projects/audiobear-www" 

directory www_files do
  action :create
  user username
  recursive true
end

git www_files do
  repo "https://bitbucket.org/zahary/audiobear-www-releases.git"
  revision "master"
  action :sync
  user username
  enable_submodules true
end

sites = {
  "retail" => {
    :search_srv => "10.10.10.2:8070",
    :api_srv => "127.0.0.1:5000",
    :root => www_files,
    :globalroot => www_files,
    :subdoiman => ""
  },

  "test" => {
    :search_srv => "10.10.10.2:8871",
    :api_srv => "127.0.0.1:8181",
    :root => www_files,
    :globalroot => www_files,
    :subdoiman => "test"
  },

  "devel" => {
    :search_srv => "10.10.10.2:26384",
    :api_srv => "127.0.0.1:8181",
    :root => www_files,
    :globalroot => www_files,
    :subdoiman => "dev"
  },
}

sites.each do |site, vars|
  site = "audiobear-#{site}"

  template "#{node['nginx']['dir']}/sites-available/#{site}" do
    mode "755"
    action :create
    owner www_user
    source "audiobear.nginx.erb"
    variables vars
  end

  nginx_site site
end

