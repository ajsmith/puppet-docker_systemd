# Build dependency list for systemd units.

module Puppet::Parser::Functions

  newfunction(
    :systemd_requires,
    :type => :rvalue,
    :doc => "Build dependency list for systemd units."
  ) do |args|
    args = args[0] || {}
    container_deps = args[:depends] || []
    systemd_deps = args[:systemd_depends] || []
    all_deps =
      systemd_deps + container_deps.map { |dep| "docker-#{dep}.service"}
    all_deps.join(' ')
  end

end
