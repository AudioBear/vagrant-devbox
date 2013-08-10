require 'rubygems'
require 'bundler/setup'
require 'highline/import'
require 'json'

## Set up developer data for Vagrant and Chef
data = begin JSON.parse File.read("devbox.json") rescue {} end

data['username']    = ask("Please, enter your preferred username: ") { |q| q.default = ENV['USER'] || ENV['USERNAME'] }
data['fullname']    = ask("Please, enter your full name: ") { |q| q.default = data['fullname'] || `git config user.name`.chomp }
data['email']       = ask("Enter your email address: ")     { |q| q.default = data['email']    || `git config user.email`.chomp }
data['sshkey']      = ask("Enter path to your SSH key: ")   { |q| q.default = data['sshkey']   || "~/.ssh/id_rsa" }

data['sshkey'] = File.expand_path data['sshkey']
File.exist?(data['sshkey']) or abort("#{data['sshkey']} does not exist!")

def yes_or_no(flag)
  return nil if flag.nil?
  flag ? "yes" : "no" 
end

data['gui'] = agree("Would you like to use a GUI environment? ") { |q| q.default = yes_or_no(data['gui']) || 'yes' }

open("devbox.json", "w") { |f| f.puts data.to_json }

## Set up ssh config on the host machine
ssh_cfg_file = File.expand_path("~/.ssh/config")
ssh_cfg_contents = open(ssh_cfg_file).read

vm_ip = "10.9.9.9"

audiobear_hosts = <<SSHCONFIG
# AUDIOBEAR BEGIN
Host audiobear
  HostName #{vm_ip}
  User #{data['username']}
  Port 22
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile #{data['sshkey']}
  IdentitiesOnly yes

# AUDIOBEAR END
SSHCONFIG

unless ssh_cfg_contents.gsub!(/# AUDIOBEAR BEGIN.*# AUDIOBEAR END/m, audiobear_hosts)
  ssh_cfg_contents += audiobear_hosts
end

open(ssh_cfg_file, "w") { |f| f.write ssh_cfg_contents }

def exec cmd
  puts "Executing: #{cmd}"
  system cmd
end

## Check out all chef dependencies and provision the machine
exec "git submodule init"
exec "git submodule update --recursive"

## Install some useful vagrant plugins
exec "vagrant plugin install vagrant-vbguest"
exec "vagrant up"

if RUBY_PLATFORM =~ /mingw|win/ and not Path.exists?("L:")
  if agree("Would you like to mount your Linux home directory as drive L: under Windows? ")
    exec "net use L: /persistent:yes \\\\#{vm_ip}\\#{username} /user:#{username} darkium"
  end
end
