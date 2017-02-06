require 'builder'

module POEditor
  module AndroidFormatter

    # Write the strings.xml output file
    #
    # @param [Hash] terms
    #        The json parsed terms exported by POEditor and sorted alphabetically
    # @param [String] file
    #        The path to the file to write the content to
    #
    def self.write_strings_xml(terms, file)
      Log::info(" - Save to file: #{file}")
      fh = File.open(file, "w")
      begin
        xml_builder = Builder::XmlMarkup.new(:target => fh, :indent => 4)
        xml_builder.instruct!
        xml_builder.comment!("Exported from POEditor\n    #{Time.now}\n    see https://poeditor.com")
        xml_builder.resources do |resources_node|
          terms.each do |term|
            (term, definition, plurals, comment, context) = ['term', 'definition', 'term_plural', 'comment', 'context'].map { |k| term[k] }
            # Skip ugly cases if POEditor is buggy for some entries
            next if term.nil? || term.empty? || definition.nil?
            next if term =~ /_ios$/
            xml_builder.comment!(context) unless context.empty?
            if plurals.empty?
              definition = definition.gsub('"', '\\"')
              resources_node.string("\"#{definition}\"", :name => term)
            else
              resources_node.plurals(:name => plurals) do |plurals_node|
                definition.each do |plural_quantity, plural_value|
                  plural_value = plural_value.gsub('"', '\\"')
                  plurals_node.item("\"#{plural_value}\"", :quantity => plural_quantity)
                end
              end
            end
          end
        end
      ensure
        fh.close
      end
    end
  end
end
