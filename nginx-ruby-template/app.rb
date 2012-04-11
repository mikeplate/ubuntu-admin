get '/' do
    data = {}
    data['Nginx version'] = env['SERVER_SOFTWARE'][/\/(.+)/, 1]
    data['Ruby version'] = "#{RUBY_VERSION}-#{RUBY_PATCHLEVEL}"
    data['Ruby platform'] = "#{RUBY_PLATFORM}"
    data['Sinatra version'] = Gem.loaded_specs['sinatra'].version
    data['Passenger version'] = `gem query`[/passenger \((.+)\)/, 1]
    data['System'] = `uname -a`
    data['Memory'] = `free`.gsub("\n", '<br />')
    data['Disk'] = `df -Ph`.gsub("\n", '<br />')
    erb :index, :locals => { title: env['SITE_NAME'], properties: data }
end

