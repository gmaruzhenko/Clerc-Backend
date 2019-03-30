module Util

  # TODO use native Ruby logger instead
  def log_info(message)
    puts "\nINFO: " + message + "\n\n"
    message
  end

end