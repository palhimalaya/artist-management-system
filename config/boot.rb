def require_all(dir)
  Dir[File.join(__dir__, '../', dir, '**', '*.rb')].each do |file|
    require file
  end
end

require 'dotenv/load'

require_all('app/models')
require_all('app/utils')
require_all('app/services')
require_all('app/helpers')
require_all('app/controllers')

require_relative '../db/connection'
