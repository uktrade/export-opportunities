# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SvgHelper do
  describe '#sanitise_svg' do
    it 'removes script tags from untrusted SVG content' do
      svg_with_script = '<svg><script>alert("XSS")</script><circle cx="50" cy="50" r="40" /></svg>'
      sanitised = helper.sanitise_svg(svg_with_script, trusted: false) # Explicitly mark as untrusted

      expect(sanitised).not_to include('<script>')
      expect(sanitised).not_to include('</script>')
      expect(sanitised).not_to include('alert("XSS")')
      expect(sanitised).to include('<circle cx="50" cy="50" r="40"')
      # The circle tag might be self-closing or have a closing tag, so we check for both
      expect(sanitised).to match(%r{<circle[^>]*>.*?</circle>|<circle[^>]*/>})
    end

    it 'removes event handlers from untrusted SVG content' do
      svg_with_event = '<svg><circle cx="50" cy="50" r="40" onclick="alert(\'XSS\')" /></svg>'
      sanitised = helper.sanitise_svg(svg_with_event, trusted: false) # Explicitly mark as untrusted

      expect(sanitised).not_to include('onclick')
      expect(sanitised).to include('<circle cx="50" cy="50" r="40"')
    end

    it 'removes javascript: URLs from untrusted SVG content' do
      svg_with_js_url = '<svg><a xlink:href="javascript:alert(\'XSS\')"><text x="20" y="20">Click me</text></a></svg>'
      sanitised = helper.sanitise_svg(svg_with_js_url, trusted: false) # Explicitly mark as untrusted

      expect(sanitised).not_to include('javascript:')
      expect(sanitised).to include('<a')
      expect(sanitised).to include('<text x="20" y="20">Click me</text>')
    end

    it 'handles script tags with whitespace and attributes in untrusted SVG content' do
      svg_with_complex_script = '<svg><script type="text/javascript" >alert("XSS")</script \n foo="bar"></svg>'
      sanitised = helper.sanitise_svg(svg_with_complex_script, trusted: false) # Explicitly mark as untrusted

      expect(sanitised).not_to include('<script')
      expect(sanitised).not_to include('</script')
      expect(sanitised).to include('<svg></svg>')
    end

    it 'preserves all content in trusted SVG content' do
      svg_with_script = '<svg><script>alert("XSS")</script><circle cx="50" cy="50" r="40" /></svg>'
      sanitised = helper.sanitise_svg(svg_with_script, trusted: true) # Mark as trusted

      # Script tags should be preserved in trusted content
      expect(sanitised).to include('<script>')
      expect(sanitised).to include('</script>')
      expect(sanitised).to include('alert("XSS")')
      expect(sanitised).to include('<circle cx="50" cy="50" r="40" />')
    end
  end

  describe '#inline_svg' do
    let(:svg_content) { '<svg width="100" height="100"><circle cx="50" cy="50" r="40" /></svg>' }

    before do
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:read).and_return(svg_content)
    end

    it 'returns an image tag if the SVG file does not exist' do
      allow(File).to receive(:exist?).and_return(false)

      # We need to stub the image_tag method to return a string
      # since that's what it actually returns in the helper
      result = helper.inline_svg('non_existent.svg')

      expect(result).to include('img')
      expect(result).to include('non_existent.svg')
      expect(result.to_s).to include('img')
      expect(result.to_s).to include('non_existent.svg')
    end

    it 'adds custom attributes to the SVG' do
      result = helper.inline_svg('test.svg', class: 'custom-class', role: 'presentation', aria_label: 'Test SVG')

      expect(result).to include('class="custom-class"')
      expect(result).to include('role="presentation"')
      expect(result).to include('aria-label="Test SVG"')
    end

    it 'changes fill color if specified' do
      svg_with_fill = '<svg width="100" height="100"><circle cx="50" cy="50" r="40" fill="#0B0C0C" /></svg>'
      allow(File).to receive(:read).and_return(svg_with_fill)

      result = helper.inline_svg('test.svg', fill_color: '#FF0000')

      expect(result).to include('fill="#FF0000"')
      expect(result).not_to include('fill="#0B0C0C"')
    end

    it 'treats SVGs from assets directory as trusted' do
      # SVGs from assets directory should be treated as trusted and not sanitized
      svg_with_script = '<svg width="100" height="100"><script>alert("XSS")</script>' \
                        '<circle cx="50" cy="50" r="40" /></svg>'
      allow(File).to receive(:read).and_return(svg_with_script)

      result = helper.inline_svg('test.svg')

      # Script tags should be preserved in trusted content
      expect(result).to include('<script>')
      expect(result).to include('alert("XSS")')
      expect(result).to include('<circle cx="50" cy="50" r="40"')
    end
  end
end
