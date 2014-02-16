require 'json'

RubocopGithub::App.controllers :pull_request do

  get :index, :provides => [:json], :map => '/pull_request/:user/:repo/:pull' do
    response = ""
    client = git_client
    client.pull_request_files("#{params[:user]}/#{params[:repo]}", params[:pull]).each do |file|
      if file.filename =~ /\.rb/
        tmp_file = Tempfile.new("/tmp")
        tmp_file << Base64.decode64(client.blob("#{params[:user]}/#{params[:repo]}", file.sha).content)
        tmp_file.close

        response << file.filename
        response << "\n"
        rubocop(tmp_file.path).each do |entry|
          entry.each_key do |key|
            response << "  #{key}: #{entry[key]}\n"
          end
        end
        response << "\n\n"
      end
    end
    response
  end

end
