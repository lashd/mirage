World(Module.new do
  def escape_double_quotes(text)
    text.gsub("\"", "\\\\\"")
  end

  def normalise text
    text.gsub(/[\n]/, ' ').gsub(/\s+/, ' ').strip
  end
end)