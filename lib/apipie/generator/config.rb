module Apipie
  module Generator
    class Config
      include Singleton

      def swagger
        Apipie::Generator::Swagger::Config.instance
      end
    end
  end
end
