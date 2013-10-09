module Saaspose
  class Pdf
    class << self
      def convert_page(file_name, local_file, page_number, *folder_path)
        options = folder_path.extract_options!
        options = { format: :png, height: 800, width: 600 } if options.empty?
        options[:folder] = Utils.path folder_path

        path = ["pdf", file_name, "pages", page_number]
        Utils.call_and_save path, options, local_file
      end

      def convert(file_name, local_file, *folder_path)
        options = folder_path.extract_options!
        options = { format: :doc } if options.empty?
        options[:folder] = Utils.path folder_path

        path = ["pdf", file_name]
        Utils.call_and_save path, options, local_file
      end

      def pages(file_name, *folder_path)
        options = folder_path.extract_options!
        options[:folder] = Utils.path folder_path

        path = ["pdf", file_name, "pages"]
        Utils.call_and_parse(path, options)["Pages"]["Links"]
      end

      def pages_count(file_name, *folder_path)
        result = pages(file_name, *folder_path)
        result.size
      end

    end
  end
end
