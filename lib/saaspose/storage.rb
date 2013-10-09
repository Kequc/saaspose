require "rest-client"

module Saaspose
  class Storage
    RemoteFile = Struct.new(:name, :folder, :modified, :size)

    class << self
      def upload(local_file, *folder_path)
        path = ["storage", "file"] + folder_path + [File.basename(local_file)]
        signed_url = Utils.sign path
        RestClient.put(signed_url, File.new(local_file, 'rb'), :accept => 'application/json')
      end
      
      def create_folder(name, *folder_path)
        path = ["storage", "folder"] + folder_path + [name]
        signed_url = Utils.sign path
        RestClient.put(signed_url, :accept => 'application/json')
      end

      def files(*folder_path)
        path = ["storage", "folder"] + folder_path
        result = Utils.call_and_parse path

        result["Files"].map do |entry|
          seconds_since_epoch = entry["ModifiedDate"].scan(/[0-9]+/)[0].to_i
          date = Time.at((seconds_since_epoch-(21600000 + 18000000))/1000)
          RemoteFile.new(entry["Name"], entry["IsFolder"], date, entry["Size"])
        end
      end

      def delete(file_name, *folder_path)
        path = ["storage", "file"] + folder_path + [file_name]
        signed_url = Utils.sign path
        RestClient.delete(signed_url, :accept => 'application/json')
      end

      def delete_folder(*folder_path)
        path = ["storage", "folder"] + folder_path
        signed_url = Utils.sign path, recursive: true
        RestClient.delete(signed_url, :accept => 'application/json')
      end

    end
  end
end
