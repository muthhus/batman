class Batman.RestStorage2 extends Batman.StorageAdapter
  fetch: (options, callback) ->

  fetchAll: (options, callback) ->
    new Batman.Request url: "/#{@model.storageKey}.json", success: (json) =>
      Batman.DataStore.forModel(@model).populate(json)
      callback?()