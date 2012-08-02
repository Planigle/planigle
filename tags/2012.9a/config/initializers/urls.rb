ENV['test_host'] = 'http://test.planigle.com'
ENV['url_after_activate'] = '/'   # The url to redirect to after activation
ActionController::AbstractRequest.relative_url_root = ''