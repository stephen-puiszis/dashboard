require 'yaml'

class Secrets

  @@secrets = YAML.load_file('config/secrets.yml')

  def self.method_missing(method, *args, &block)
    @@secrets[method.to_s]
  end

end
