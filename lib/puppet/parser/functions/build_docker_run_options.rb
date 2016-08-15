
def single_arg(opt)
  lambda { |arg| "--#{opt} #{arg}" }
end

def separate_multi_arg(opt)
  lambda { |args| args.map {|arg| "--#{opt} #{arg}"}.join(' ') }
end

def toggle_arg(opt)
  lambda { |arg| "--#{opt}" if arg == 'true' }
end

module Puppet::Parser::Functions

  @@processors = {
    :entrypoint => single_arg('entrypoint'),
    :env => separate_multi_arg('env'),
    :env_file => separate_multi_arg('env-file'),
    :label => separate_multi_arg('label'),
    :label_file => single_arg('label-file'),
    :link => separate_multi_arg('link'),
    :name => single_arg('name'),
    :privileged => toggle_arg('privileged'),
    :publish => separate_multi_arg('publish'),
    :volume => separate_multi_arg('volume'),
    :volumes_from => separate_multi_arg('volumes-from'),
    :hostname => single_arg('hostname')
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
