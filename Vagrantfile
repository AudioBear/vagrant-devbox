# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'json'

$audiobear = JSON.parse IO.read("audiobear.json")

# add vagrant specific properties to the DNA files
$devbox_data = begin JSON.parse IO.read("devbox.json") rescue system "./bootstrap" end

$audiobear['devbox'] = $devbox_data

sshkey = File.expand_path $devbox_data["sshkey"]
$devbox_data["ssh_private_bytes"] = IO.read(sshkey)
$devbox_data["ssh_public_bytes"] = IO.read(sshkey + ".pub")

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.box = "precise"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  
  config.vm.provider :virtualbox do |vb|
    vb.gui = false # $devbox_data["gui"]
    vb.name = "AudioBear"
    vb.customize [
      "modifyvm", :id,
      "--memory", "1096",
      #"--vram", "32",
      #"--accelerate3d", "on",
      #"--cpus", "1",
      # "--cpus", Fater.sp_number_processors.to_s
      #"--clipboard", "bidirectional"
    ]
  end
  
  config.vm.network :private_network, ip: "10.9.9.9"

  # Assign this VM to a bridged network, allowing you to connect directly to a
  # network using the host's network device. This makes the VM appear as another
  # physical device on your network.
  # config.vm.network :bridged

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.

  # config.vm.forward_port 80, 80
  # config.vm.forward_port 443, 443

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  # config.vm.share_folder "v-data", "/vagrant_data", "../data"
  
  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding 
  # some recipes and/or roles.
  #
  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "cookbooks"
    chef.roles_path = "roles"
    chef.data_bags_path = "data_bags"
    
    chef.json = $audiobear
    chef.run_list = $audiobear["run_list"]
  end
end

