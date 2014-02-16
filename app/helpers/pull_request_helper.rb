# Helper methods defined here can be accessed in any controller or view in the application

RubocopGithub::App.helpers do
  def rubocop(file)
    rubocop = Rubocop::CLI.new

    output = read_output do
      rubocop.run(["--format", "json", file])
    end

    offences = []
    json = JSON.parse(output)
    json["files"].each do |file|
      file["offences"].each do |offence|
        offences << {offence["location"]["line"].to_s => offence["message"]}
      end
    end
    offences
  end

  def git_client
    config_path = File.expand_path("../../../config/github.yml", __FILE__)
    if File.exist?(config_path)
      params = YAML.load_file(config_path)

      params = params.inject({}) { |memo, (k,v)|
        memo[k.to_sym] = v; memo
      }
      client = Octokit::Client.new params
    else
      raise "Github configuration file is missing"
    end
  end

  def read_output(&block)
    output = StringIO.new
    stdout_saved = $stdout
    $stdout = output

    yield

    $stdout = stdout_saved
    output.seek 0
    output.read
  end

end
