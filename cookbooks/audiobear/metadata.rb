maintainer "AudioBear Contributors"
name "audiobear"
version "0.9.0"
license "GPL v2"

recipe "audiobear", "Sets up an audiobear development box."

%w{ubuntu debian}.each do |os|
  supports os
end

attribute 'audiobear/user',
  :display_name => "Developer UserName",
  :description => "The user account that will be created for you",
  :default => "dev"

attribute 'audiobear/user_shell',
  :display_name => "Developer Shell",
  :description => "The shell you would like to use",
  :default => "/bin/bash"

# depends "redis"

