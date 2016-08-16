
def single_arg(opt, separator=' ')
  lambda { |arg| "--#{opt}#{separator}#{arg}" }
end

def separate_multi_arg(opt, separator=' ')
  lambda { |args| args.map {|arg| "--#{opt}#{separator}#{arg}"}.join(' ') }
end

module Puppet::Parser::Functions

  @@processors = {
    :entrypoint => single_arg('entrypoint'),
    :env => separate_multi_arg('env'),
    :env_file => separate_multi_arg('env-file'),
    :hostname => single_arg('hostname'),
    :label => separate_multi_arg('label'),
    :label_file => single_arg('label-file'),
    :link => separate_multi_arg('link'),
    :log_driver => single_arg('log-driver'),
    :log_opt => separate_multi_arg('log-opt'),
    :name => single_arg('name'),
    :net => single_arg('net'),
    :privileged => single_arg('privileged', '='),
    :publish => separate_multi_arg('publish'),
    :volume => separate_multi_arg('volume'),
    :volumes_from => separate_multi_arg('volumes-from'),
  }

  newfunction(
    :build_docker_run_options,
    :type => :rvalue,
    :doc => "Build command line options for docker-run."
  ) do |args|
    args = args[0] || {}
    args.reject { |k, v|
      v.nil? || v == :undef || v.empty?
    }.map { |k, v|
      @@processors[k.to_sym].call(v)
    }.join(" \\\n    ")
  end

end
