include_recipe "build-essential"
include_recipe "git"
include_recipe "redis"
include_recipe "nginx"
include_recipe "tup::source"

include_recipe "samba::server"
node.samba.workgroup = "WORKGROUP"
node.samba.interfaces = ""
node.samba.hosts_allow = ""

username = node['audiobear']['user']
userhome ="/home/#{username}"
www_user = username

user username  do
  comment "AudioBear Developer"
  gid "users"
  home userhome 
  shell node['audiobear']['user_shell']
end

projects_root = "#{userhome}/Projects"

%w{ python
    python-psycopg2
    postgresql }.each { |p| package p }

directory projects_root do
  action :create
  user username
  recursive true
end

%w{audiobear audiobear-www-releases audiobear-api}.each do |project|
  git "#{projects_root}/#{project}" do
    repo "git@bitbucket.org:zahary/#{project}.git"
    revision "master"
    action :sync
    user username
    enable_submodules true   
  end
end

www_files = "#{projects_root}/audiobear-www-releases/www"
www_working_copy = "#{projects_root}/audiobear" 
api_working_copy = "#{projects_root}/audiobear-api" 

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
    :root => "#{projects_root}/audiobear-www-releases/debug",
    :globalroot => www_files,
    :subdoiman => "test"
  },

  "devel" => {
    :search_srv => "10.10.10.2:26384",
    :api_srv => "127.0.0.1:8181",
    :root => www_working_copy,
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

samba_user "musicbrainz" do
  password node.audiobear.user_smbpass
  action [:create, :enable]
end

