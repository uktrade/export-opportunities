module Rack
  class XRobotsTag
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)
      if Figaro.env.DISALLOW_ALL_WEB_CRAWLERS.present?
        headers["X-Robots-Tag"] = "noindex, nofollow"
      end

      [status, headers, response]
    end
  end
end
