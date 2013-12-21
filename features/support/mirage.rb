module Mirage
  def start_mirage_in_scratch_dir
    Dir.chdir SCRATCH do
      Mirage.start
    end
  end

  def mirage
    @mirage ||= Mirage.running? ? Mirage::Client.new : start_mirage_in_scratch_dir
  end
end
World Mirage