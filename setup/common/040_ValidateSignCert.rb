test_name "Validate Sign Cert" do
  need_to_run = false
  hosts.each do |host|
    need_to_run ||= host['use_existing_container'] != 'true'
  end
  if need_to_run
    skip_test 'not testing with puppetserver' unless @options['is_puppetserver']
    hostname = on(master, 'facter hostname').stdout.strip
    fqdn = on(master, 'facter fqdn').stdout.strip
    puppet_version = on(master, puppet("--version")).stdout.chomp

    step "Set 'server' setting"
    hosts.each do |host|
      on(host, puppet("config set server #{master.hostname} --section main"))
    end

    step "Start puppetserver" do
      master_opts = {
        main: {
          dns_alt_names: "puppet,#{hostname},#{fqdn}",
          server: fqdn,
          autosign: true
        },
      }

      # In Puppet 6, we want to be using an intermediate CA
      unless version_is_less(puppet_version, "5.99")
        on master, 'puppetserver ca setup' unless master['use_existing_container'] == 'true'
      end
      with_puppet_running_on(master, master_opts) do
        step "Agents: Run agent --test with autosigning enabled to get cert"
        on agents, puppet("agent --test"), :acceptable_exit_codes => [0,2]
      end
    end
  end
end
