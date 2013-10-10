module Saaspose
  class Pdf

    class << self
      def convert_page(file_name, *folder_path, **options)
        options[:folder] = Utils.path(folder_path) unless folder_path.empty?
        local = options.delete :local
        page = options.delete(:page) || 1
        path = ["pdf", file_name, "pages", page]
        Utils.call_and_save path, options, local
      end

      def convert(file_name, *folder_path, **options)
        options[:folder] = Utils.path(folder_path) unless folder_path.empty?
        local = options.delete :local
        path = ["pdf", file_name]
        Utils.call_and_save path, options, local
      end

      def pages_count(file_name, *folder_path, **options)
        options[:folder] = Utils.path(folder_path) unless folder_path.empty?
        path = ["pdf", file_name, "pages"]
        Utils.call_and_parse(path, options)["Pages"]["List"].length
      end

    end
  end
end
