test_name 'Puppet User and Group' do
  hosts.each do |host|
    if host['use_existing_container'] == 'true'
      puts "SKIPPING PUPPET USER AND GROUP"
      next
    end
    step "ensure puppet user and group added to all nodes because this is what the packages do" do
      on host, puppet("resource user puppet ensure=present")
    end
  end
end
