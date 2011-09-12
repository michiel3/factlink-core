proxy_conf = YAML::load_file(Rails.root.join('config/proxy.yml'))[Rails.env]['proxy']
FactlinkUI::Application.config.proxy_url = "http://" + proxy_conf['hostname'] + ':' + proxy_conf['port'].to_s