# frozen_string_literal: true

require 'sanitize'

# Helper module for SVG-related functionality
module SvgHelper
  # Sanitises SVG content by removing potentially dangerous elements and attributes
  def sanitise_svg(content, trusted: false)
    # Skip sanitization for trusted SVGs (from our own assets directory)
    return content if trusted

    # Use the Sanitize gem for untrusted SVGs
    Sanitize.fragment(
      content,
      elements: %w[svg g path circle rect line polyline polygon
                   ellipse title desc defs clipPath a text tspan],
      attributes: {
        all: %w[id class style width height fill fill-opacity
                stroke stroke-width stroke-opacity opacity transform
                viewBox preserveAspectRatio xmlns xmlns:xlink version],
        'svg' => %w[role aria-label],
        'a' => %w[xlink:href href],
        'path' => ['d'],
        'circle' => %w[cx cy r],
        'rect' => %w[x y rx ry],
        'line' => %w[x1 y1 x2 y2],
        'polyline' => ['points'],
        'polygon' => ['points'],
        'ellipse' => %w[cx cy rx ry],
        'text' => %w[x y text-anchor font-family font-size font-weight],
      },
      protocols: {
        'a' => { 'href' => %w[http https #] },
      }
    )
  end

  # Inlines an SVG file with custom attributes and security measures
  def inline_svg(path, options = {})
    file_path = Rails.root.join('app', 'assets', 'images', path)
    return image_tag(path, options) unless File.exist?(file_path)

    process_svg_file(file_path, options)
  end

  private

    def process_svg_file(file_path, options)
      svg_content = File.read(file_path)
      svg_content = add_custom_attributes(svg_content, options)
      svg_content = svg_content.gsub('fill="#0B0C0C"', "fill=\"#{options[:fill_color]}\"") if options[:fill_color]

      # SVGs from our assets directory are trusted
      sanitise_svg(svg_content, trusted: true).html_safe
    end

    def add_custom_attributes(svg_content, options)
      # Extract the SVG tag attributes
      svg_tag_match = svg_content.match(/<svg([^>]*)>/)
      svg_attributes = svg_tag_match ? svg_tag_match[1] : ''

      # Create a new SVG tag with our custom attributes
      css_class = options[:class] || ''
      role = options[:role] || 'img'
      aria_label = options[:aria_label] || ''

      new_svg_opening = "<svg#{svg_attributes} class=\"#{css_class}\" role=\"#{role}\" aria-label=\"#{aria_label}\""

      # Replace the original SVG opening tag with our new one
      svg_content.sub(/<svg[^>]*>/, "#{new_svg_opening}>")
    end
end
