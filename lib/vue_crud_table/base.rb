class VueCrudTable::Base

  attr_accessor :model_klass, :attributes, :options, :headers

  REGEX = /\/app\/controllers\/(.*)_controller.rb/

  def initialize(options = {})
    @options = VueCrudTable::Settings.new(options)
    called_from = caller.first
    regex_scan = called_from.scan(REGEX)
    raise 'VueCrudTable not called from a controller' unless regex_scan.any?

    namespace_parts = regex_scan.flatten.first.split('/')

  begin
    @model_klass_name = namespace_parts.map { |part|
      part.singularize.capitalize
    }.join('::')
    @model_klass = @model_klass_name.constantize
  rescue NameError => exception
    raise "VueCrudTable could not identify model class `#{@model_klass_name}`"
  end

    @attributes = @model_klass.column_names
    headers_for_vue
  end

  def attribute_type(attribute)
    model_klass.columns_hash[attribute].type
  end

  def headers_for_vue
    @headers = model_klass.column_names.map do |attribute|
      # TODO: Load i18n if set! second: load custom label if set in options
      {
        text: attribute,
        align: 'left',
        value: attribute,
        type: attribute_type(attribute)
      }
    end
    headers << actions
  end

  def actions
    # detect if routes/actions are set, restrict actions automatically
    # For now:
    { text: "Aktionen", value: "action", sortable: false }
  end
end