include_recipe "build-essential"
include_recipe "redis"
include_recipe "git"

user "gosho" do
  comment "Gosho Hubaveca"
  uid 2001
  gid "users"
  home "/home/gosho"
  shell "/bin/bash"
end

