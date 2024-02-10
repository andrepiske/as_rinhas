# frozen_string_literal: true

module RinhaDB
  class RinhaError < StandardError
  end
  class WouldLimitOverflow < RinhaError
  end
  class CustomerNotFound < RinhaError
  end
end

# require_relative './memory_db.rb'
# module RinhaDB
#   DB = MemoryDB
# end

require_relative './mongo_backed.rb'
module RinhaDB
  DB = MongoBackedDB
end
