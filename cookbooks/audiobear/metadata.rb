maintainer "AudioBear Contributors"
name "audiobear"
version "0.9.0"
license "GPLv2"

recipe "audiobear", "Sets up an audiobear development box."

%{ubuntu debian}.each do |os|
  supports os
end

# depends "redis"

