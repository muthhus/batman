QUnit.module 'Batman.HashbangNavigator',
  setup: ->
    @app =
      dispatcher:
        dispatch: @dispatchSpy = createSpy()
    @nav = new Batman.HashbangNavigator(@app)

test "pathFromLocation(window.location) returns the app-relative path", ->
  location =
    
  equal @nav.pathFromLocation(hash: '#!/foo/bar?page=2'), '/foo/bar?page=2'
  equal @nav.pathFromLocation(hash: '#/foo/bar?page=2'), '/'
  equal @nav.pathFromLocation(hash: '#'), '/'
  equal @nav.pathFromLocation(hash: ''), '/'

test "pushState(stateObject, title, path) sets window.location.hash", ->
  @nav.pushState(null, '', '/foo/bar')
  equal window.location.hash, "#!/foo/bar"

unless IN_NODE #jsdom doesn't like window.location.replace
  asyncTest "replaceState(stateObject, title, path) replaces the current history entry", ->
    window.location.hash = '#!/one'
    window.location.hash = '#!/two'
    @nav.replaceState(null, '', '/three')
    equal window.location.hash, "#!/three"
    window.history.back()
    setTimeout ->
      equal window.location.hash, "#!/one"
      QUnit.start()
    , 500 # window.history.back() takes forever...
    
test "handleLocation(window.location) dispatches based on pathFromLocation", ->
  @nav.handleLocation
    pathname: Batman.pathPrefix
    search: ''
    hash: '#!/foo/bar?page=2'
  equal @dispatchSpy.callCount, 1
  deepEqual @dispatchSpy.lastCallArguments, ["/foo/bar?page=2"]


test "handleLocation(window.location) handles the real non-hashbang path if present", ->
  location =
    pathname: @nav.normalizePath(Batman.pathPrefix, '/baz')
    search: '?q=buzz'
    hash: '#!/foo/bar?page=2'
    replace: createSpy()
  @nav.handleLocation(location)
  equal location.replace.callCount, 1
  deepEqual location.replace.lastCallArguments, ["#{Batman.pathPrefix}#!/baz?q=buzz"]
