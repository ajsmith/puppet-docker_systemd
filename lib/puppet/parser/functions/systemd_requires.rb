# Build dependency list for systemd units.

module Puppet::Parser::Functions

  newfunction(
    :systemd_requires,
    :type => :rvalue,
    :doc => "Build dependency list for systemd units."
  ) do |args|
    args = args[0] || {}
    container_deps =
      (args[:depends] || []).map { |dep| "docker-#{dep}.service"}
    systemd_deps = args[:systemd_depends] || []
    (systemd_deps + container_deps).join(' ')
  end

end
