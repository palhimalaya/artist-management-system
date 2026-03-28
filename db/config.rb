require 'yaml'
require 'erb'

ENVIRONMENT = ENV['APP_ENV'] || 'development'

file = File.read(File.join(__dir__, '../config/database.yml'))
erb = ERB.new(file).result

DB_YML = YAML.safe_load(erb)

DEFAULT_DB_CONFIG = DB_YML['default']
DB_CONFIG = DEFAULT_DB_CONFIG.merge(DB_YML[ENVIRONMENT])
