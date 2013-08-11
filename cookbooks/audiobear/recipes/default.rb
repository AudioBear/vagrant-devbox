include_recipe "apt"
include_recipe "build-essential"
include_recipe "git"
include_recipe "redis"
include_recipe "nginx"
include_recipe "tup::source"
include_recipe "node::source"
include_recipe "devbox"

include_recipe "mongodb::10gen_repo"
include_recipe "mongodb::default"

username = node.devbox.username
userhome ="/home/#{username}"
www_user = username

user username  do
  comment username
  gid "users"
  home userhome 
  shell node['audiobear']['user_shell']
end

projects_root = "#{userhome}/Projects"

%w{ curl
    python
    python-psycopg2
    postgresql
    libpq-dev }.each { |p| package p }

directory projects_root do
  action :create
  user username
  recursive true
end

%w{audiobear audiobear-www-releases audiobear-api}.each do |project|
  git "#{projects_root}/#{project}" do
    repo "git@bitbucket.org:zahary/#{project}.git"
    revision "master"
    action :checkout
    user username
    enable_submodules true
    ssh_wrapper "#{$userhome}/.ssh/git_ssh_wrapper"
  end
end

www_files = "#{projects_root}/audiobear-www-releases/www/retail"
www_working_copy = "#{projects_root}/audiobear" 
api_working_copy = "#{projects_root}/audiobear-api" 

sites = {
  "retail" => {
    :search_srv => "10.10.10.2:8070",
    :api_srv => "127.0.0.1:5000",
    :root => www_files,
    :globalroot => www_files,
    :subdomain => ""
  },

  "test" => {
    :search_srv => "10.10.10.2:8871",
    :api_srv => "127.0.0.1:8181",
    :root => "#{projects_root}/audiobear-www-releases/www/debug",
    :globalroot => www_files,
    :subdomain => "test"
  },

  "local" => {
    :search_srv => "audiobear.com",
    :api_srv => "127.0.0.1:8181",
    :root => www_working_copy,
    :globalroot => www_files,
    :subdomain => "local"
  },

  "devel" => {
    :search_srv => "10.10.10.2:26384",
    :api_srv => "127.0.0.1:8181",
    :root => www_working_copy,
    :globalroot => www_files,
    :subdomain => "dev"
  },

  "devbox" => {
    :search_srv => "audiobear.com",
    :api_srv => "127.0.0.1:8181",
    :root => www_working_copy,
    :globalroot => www_files,
    :subdomain => "devbox"
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

template "/etc/init/audiobear.conf" do
  action :create
  owner username
  mode "755"
  source "audiobear.upstart.conf.erb"
  variables(
    :user => username,
    :dir => api_working_copy,
    :port => 5000)
end

if $devbox
  include_recipe "samba::server"
  node.samba.workgroup = "WORKGROUP"
  node.samba.interfaces = ""
  node.samba.hosts_allow = ""

  samba_user username do
    password node.audiobear.user_smbpass
    action [:create, :enable]
  end
end

