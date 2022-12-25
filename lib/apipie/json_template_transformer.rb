class Apipie::JsonTemplateTransformer
  def self.transform(document:, language:, resource_name:)
     if resource_name.blank?
      # {
      #   'exte' => {
      #     :doc_url=>"../apidoc/extended",
      #       :id=>"extended"
      #   }
      # }
      document[:docs][:resources] = document[:docs][:resources].
        transform_values { |resource| resource.for_json(lang: language) }
     else
      document[:docs][:resources] = document[:docs][:resources].
        values.
        map { |resource| resource.for_json(lang: language) }
     end

     document
  end
end
