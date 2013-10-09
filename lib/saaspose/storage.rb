require "rest-client"

module Saaspose
  class Storage
    RemoteFile = Struct.new(:name, :folder, :modified, :size)

    class << self
      def upload(local_file_path, remote_folder_path=nil)
        file_name = File.basename(local_file_path)
        signed_url = Utils.sign ["storage", "file", remote_folder_path, file_name]
        RestClient.put(signed_url, File.new(local_file_path, 'rb'), :accept => 'application/json')
      end
      
      def create_folder(name, remote_folder_path=nil)
        signed_url = Utils.sign ["storage", "folder", remote_folder_path, name]
        RestClient.put(signed_url, :accept => 'application/json')
      end

      def files(remote_folder_path=nil)
        result = Utils.call_and_parse ["storage", "folder", remote_folder_path]

        result["Files"].map do |entry|
          seconds_since_epoch = entry["ModifiedDate"].scan(/[0-9]+/)[0].to_i
          date = Time.at((seconds_since_epoch-(21600000 + 18000000))/1000)
          RemoteFile.new(entry["Name"], entry["IsFolder"], date, entry["Size"])
        end
      end

      def delete(file_name, remote_folder_path=nil)
        signed_url = Utils.sign ["storage", "file", remote_folder_path, file_name]
        RestClient.delete(signed_url, :accept => 'application/json')
      end

      def delete_folder(remote_folder_path, recursive=false)
        signed_url = Utils.sign ["storage", "folder", remote_folder_path], recursive: recursive
        RestClient.delete(signed_url, :accept => 'application/json')
      end

    end
  end
end
