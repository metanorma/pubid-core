module Pubid::Core
  config = Configuration.new
  # stages = { "abbreviations" => { "WD" => %w[20.20 20.60] },
  #            "codes_description" => { "20.20" => "Working draft (WD) study initiated",
  #                                     "20.60" => "Close of comment period",
  #                                     "40.00" => "DIS registered" },
  #            "stage_codes" => { reparatory: "20" },
  #            "substage_codes" => { start_of_main_action: "20" } }
  config.stages = {}
  # config.type_class = Type
  config.default_type = DummyInternationalStandardType
  config.types = [DummyInternationalStandardType, DummyTechnicalReportType]


  config.stages["abbreviations"] = {
    "WD" => %w[20.20 20.60 20.98 20.99],
  }
  config.stages["codes_description"] = {
    "10.98" => "New project rejected",
    "20.00" => "New project registered in TC/SC work programme",
    "20.20" => "Working draft (WD) study initiated",
    "20.60" => "Close of comment period",
    "20.98" => "Project deleted",
    "20.99" => "WD approved for registration as CD",
    "60.00" => "International Standard under publication",
    "60.60" => "International Standard published",
  }
  config.stages["stage_codes"] = {
    "preparatory" => "20",
  }
  config.stages["substage_codes"] = {
    "start_of_main_action" => "20",
  }
  config.stages["draft_codes"] = %w[20.00 20.20 20.60]
  config.stages["canceled_codes"] = %w[00.98 10.98 20.98]
  config.stages["published_codes"] = %w[60.00 60.60]


  config.type_names = { tr: { long: "Technical Report",
                              short: "TR" } }
  config

  DummyTestIdentifier.set_config(config)
end
