class FileVersion

  def self.find_by_file_uri(file_uri)
    FileVersion[:file_uri => file_uri]
  end

end