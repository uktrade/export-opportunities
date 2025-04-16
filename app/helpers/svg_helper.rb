module SvgHelper
  def inline_svg(path, options = {})
    file_path = Rails.root.join('app', 'assets', 'images', path)
    
    if File.exist?(file_path)
      svg_content = File.read(file_path)
      
      # Extract the SVG tag attributes
      svg_tag_match = svg_content.match(/<svg([^>]*)>/)
      svg_attributes = svg_tag_match ? svg_tag_match[1] : ""
      
      # Create a new SVG tag with our custom attributes
      css_class = options[:class] || ""
      role = options[:role] || "img"
      aria_label = options[:aria_label] || ""
      
      new_svg_opening = "<svg#{svg_attributes} class=\"#{css_class}\" role=\"#{role}\" aria-label=\"#{aria_label}\""
      
      # Replace the original SVG opening tag with our new one
      svg_content = svg_content.sub(/<svg[^>]*>/, new_svg_opening + ">")
      
      # Change fill color if specified
      if options[:fill_color]
        svg_content = svg_content.gsub(/fill="#0B0C0C"/, "fill=\"#{options[:fill_color]}\"")
      end
      
      svg_content.html_safe
    else
      # Fallback to image tag if SVG file doesn't exist
      image_tag(path, options)
    end
  end
end
