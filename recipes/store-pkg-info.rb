ruby_block "store-package-info" do
  block do
    globbed = Dir.glob("#{node.default['client-test']['pkg_dir']}/*.json")

    if globbed.size > 0
      # pick the latest package file.
      latest_json_file = globbed.sort.reverse[0]
      pkg_info = JSON.load(File.open(latest_json_file).read)
      pkg_info["package_fullpath"] = "#{node.default['client-test']['pkg_dir']}/#{pkg_info["basename"]}"

      (node.run_state['chef-client-test'] ||= {})['pkg_info'] = pkg_info
    end
  end
end

log "node-pkg-info" do
  level :info
  message lazy { node.run_state['chef-client-test']['pkg_info'].inspect }
end
