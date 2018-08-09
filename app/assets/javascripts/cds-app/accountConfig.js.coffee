Cds.accountConfig = do ->
  ###*
  # Matches up parameters from feed: /api/locomotives/:locomotive_id/locomotive_data
  # Feed of locomotive data.
  # Most params have qes_variables, a few had to be added to the feed manually:
  # fp = Fuel Percentage
  # fl = Fuel Level
  # Params come from LIIS and are matched up with CMS entries.
  # CMS adds title and units.
  # Views retrievied via account id
  ###
  locoDataViews =
    # GO
    4: (locomotive) ->
      mi5:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: false
      ai10:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: true
      fl:
        view: Cds.Views.FeaturedGalSum
        config:
          columns: 1
          type: "gal-sum"
          show_sub_title: true
          sub_title: "GAL TO EMPTY"
      fp:
        view: Cds.Views.FeaturedPercentage
        config:
          columns: 2
          type: "percentage"
          show_title: true
          title: "Fuel Level"
    # CFCLA, MP, etc.
    default: (locomotive) ->
      mi5:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: false
      ai44:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: true
      lkwh:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: true
          custom_class: "lkwh"
      # fuel level
      fl:
        view: Cds.Views.FeaturedGalSum
        config:
          columns: 1
          type: "gal_sum"
          show_sub_title: true
          sub_title: "GAL TO EMPTY"
      # fuel percentage
      fp:
        view: Cds.Views.FeaturedPercentage
        config:
          columns: 2
          type: "percentage"
          show_title: true
          title: "Fuel Level"

  ###*
  # Matches up parameters from feed: /api/locomotives/:locomotive_id/engine_data
  # Feed is array of engine data - one per engine. Amount varies per account.
  # Most params have qes_variables, a few had to be added to the feed manually:
  # lh1, lh2, etc. = engine hours
  # lo1 = Odometer
  # Params come from LIIS and are matched up with CMS entries.
  # CMS adds title and units.
  # Views retrievied via account id
  ###
  engineDataViews =
    # GO
    4: ->
      row_titles: ["PRIME MOVER 1", "PRIME MOVER 2"]
      ai34:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: false
      ai2:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: true
      lh1:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: true
      ai36:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: true
      ai138:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: true
      ai144:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: true
      ai82:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: false
      ai7:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: true
      lh2:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: true
      ai84:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: true
      ai139:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: true
      ai145:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: true

    # CFCLA, MPI
    default: ->
      row_titles: ["Prime Mover"]
      ai35:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: false
      ai34:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: true
      # engine hours
      lh1:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: true
      ai73:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 1
          type: "basic"
          show_title: true
      # Odometer
      lo1:
        view: Cds.Views.FeaturedBasic
        config:
          columns: 2
          type: "basic"
          show_title: true

  return {
    getLocoDataViewsConfig: (liisAccountID, locomotive) ->
      if locoDataViews[liisAccountID]?
        views = locoDataViews[liisAccountID](locomotive)
      else
        views = locoDataViews["default"](locomotive)
      return views

    getEngineDataViewsConfig: (liisAccountID) ->
      if engineDataViews[liisAccountID]?
        views = engineDataViews[liisAccountID]()
      else
        views = engineDataViews["default"]()
      return views
  }
