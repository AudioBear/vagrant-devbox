# solo.rb
file_cache_path "/tmp/vagrant-chef-1"
encrypted_data_bag_secret "/tmp/encrypted_data_bag_secret"

cookbook_path ["cookbooks"]
role_path ["roles"]
log_level :info

data_bag_path "data_bags"

http_proxy nil
http_proxy_user nil
http_proxy_pass nil
https_proxy nil
https_proxy_user nil
https_proxy_pass nil
no_proxy nil

