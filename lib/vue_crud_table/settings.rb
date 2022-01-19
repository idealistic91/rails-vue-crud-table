class VueCrudTable::Settings
  attr_accessor :settings

  def initialize(settings)
    # Set custom labels; restrict actions (only index, no edit, update...), etc. 
    @settings = settings
  end
end