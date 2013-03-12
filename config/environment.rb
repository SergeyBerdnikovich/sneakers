# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Sneakers::Application.initialize!

Time::DATE_FORMATS[:for_product] = "%Y.%m.%d"