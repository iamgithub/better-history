Router = Backbone.Router.extend({
  routes: {
    'settings': 'settings',
    'filter/:type': 'filter',
    'filter/:type/:time': 'filter',
    'search/*query': 'search'
  },

  initialize: function() {
    var self = this;
    this.bind('route:filter', function(type, time) {
      var url = 'filter/' + type;
      if(time) url += '/' + time;
      self.setLastRoute(url);
    });
    this.bind('route:settings', function(page) { self.setLastRoute('settings'); });
    this.bind('route:search', function(page) { self.setLastRoute('search/' + page); });
  },

  settings: function() {
    var settingsView = new SettingsView({model: settings});
    $('.mainview', appView.el).html(settingsView.render().el);
  },

  filter: function(type, time) {
    var filter = filters.getByHash(this.checkType(type)),
        filterView = new FilterView({model: filter});

    $('.mainview', appView.el).html(filterView.render().el);

    filterView.startTime = time;
    filter.fetch();
  },

  search: function(query) {
    var filter = new Filter({
      text: query,
      hash: 'search',
      endTime: new Date().getTime(),
      startTime: DateRanger.borders(60).start.getTime()
    });

    var searchView = new SearchView({model: filter});
    $('.mainview', appView.el).html(searchView.render().el);

    filter.fetch();
  },

  checkType: function(type) {
    return type === undefined || type === 'undefined' ? '0_days_ago' : type;
  },

  setLastRoute: function(route) {
    localStorage.lastRoute = route;
  },

  getLastRoute: function() {
    return localStorage.lastRoute;
  }
});
