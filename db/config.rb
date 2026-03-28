require 'yaml'

ENVIRONMENT = 'development'.freeze

DB_YML = YAML.load_file(File.join(__dir__, '../config/database.yml'))

DB_CONFIG = DB_YML[ENVIRONMENT]
DEFAULT_DB_CONFIG = DB_YML['default']
