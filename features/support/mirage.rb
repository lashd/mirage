module Mirage
  def start_mirage_in_scratch_dir
    Dir.chdir SCRATCH do
      Mirage.start
    end
  end
end
World Mirage