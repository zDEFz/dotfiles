require 'fritzbox/smarthome'

Fritzbox::Smarthome.configure do |config|
  config.endpoint   = 'https://fritz.box'
#  config.endpoint   = '192.168.178.1'
  config.username   = 'smarthome'
  config.password   = 'da+wepN+zSa9jRQXV[+TA/eh'
  config.verify_ssl = false
end

# Get all actors of any type
actors = Fritzbox::Smarthome::Actor.all

# Get all actors of type Heater
#heaters = Fritzbox::Smarthome::Heater.all
#heaters.last.update_hkr_temp_set(BigDecimal('21.5'))

# Get a specific actor via it's AIN
#actor = Fritzbox::Smarthome::Actor.find_by!(ain: '0815 4711')

# Reload the data of an already fetched actor
actor.reload
