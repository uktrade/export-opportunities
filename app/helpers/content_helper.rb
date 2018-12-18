module ContentHelper
  
  # Returns content provided by .yml files in app/content folder.
  # Intended use is to keep content separated from the view code.
  # Should make it easier to switch later to CMS-style content editing.
  # Note: Rails may already provide a similar service for multiple
  # language support, so this mechanism might be replaced by that
  # at some point in the furture.
  def get_content(*files)
    @content ||= {}
    files.each do |file|
      @content = @content.merge YAML.load_file('app/content/' + file)
    end
    @content
  end

  # Gets content by either single 'key' value
  # or nested 'key.is.here' value.
  def content(key_path)
    keys = key_path.split('.')
    content = @content
    keys.each do |key|
      break unless content.key? key
      content = content[key]
    end
    content.class == String ? content : ''
  end

  # Injects values into a formatted string.
  # You can includes conditional content by surrounding
  # your inclusion marker labels.
  #
  # [$something] = Inclusion marker
  # $something = Inclusion marker label ('something' can be any word, it is not matched)
  # [some $label content ] = Inclusion marker with conditional content.
  #
  # The conditional content above is 'some ' and ' content ' (spaces included).
  #
  #
  # EXMPLES WITHOUT CONDITIONAL CONTENT in the inclusion markers
  # ------------------------------------------------------------
  #
  # E.g.
  # content = "Hello [$first_name] [$last_name]"
  #
  # Returns string "Hello Darth Vader"
  # when includes = ["Darth", "Vader"]
  #
  # Returns string "Hello Darth"
  # when includes = ["Darth"]
  #
  # Returns string "Hello Vader"
  # when includes = ["", "Vader"]
  #
  #
  # EXAMPLES TO SHOW THE LABEL NAMES ARE IRRELEVANT
  # -----------------------------------------------
  # The inclusion marker label names/wording is irrelevant.
  # first_name and last_name are only helpful in these examples
  # to show what is expected to be injected in the content.
  # The content in this example contains confusing names but
  # would work exactly the same as the other examles, given
  # the same data.
  #
  # E.g.
  # content = "Hello [$building] [$spaceman]"
  #
  # Returns string "Hello Darth Vader"
  # when includes = ["Darth", "Vader"]
  #
  #
  # EXAMPLES WITH CONDITIONAL CONTENT in the inclusion markers
  # ----------------------------------------------------------
  # You can also include conditional content that shows only when a match is found.
  # The conditional content can be put around the target inclusion marker label.
  # Some examples will explain better than words.
  #
  # E.g.
  # content = 'Has [an $foo or ][a $bar and ]a dream'
  #
  # Returns 'Has a dream'
  # when includes = []
  #
  # Returns 'Has an idea or a dream'
  # when includes = ['idea', '']
  #
  # Returns 'Has a plan and a dream'
  # when includes = ['', 'plan']
  #
  # Returns 'Has an idea or a plan and a dream'
  # when includes = ['idea', 'plan']
  #
  def content_with_inclusion(key, includes)
    str = content(key)
    re = /\[([^\[\]]*?)\$[a-z]+[\w_]*([^\[\]]*?)\]/i
    includes.each do |include|
      str.sub(re, '') # TODO: Why does it work with this line but not without?
      # re.match(str)   # This one also makes it work !?!?!
      str = if include.present?
              str.sub(re, "#{Regexp.last_match(1)}#{include}#{Regexp.last_match(2)}")
            else
              str.sub(re, '') # just remove the inclusion marker
            end
    end
    str = str.gsub(re, '') # If includes was empty
    str.gsub(/\s+/, ' ').html_safe
  end

  # Similar to content_with_inclusion but replaces all
  # inclusion markers with blank '' string.
  #
  # e.g. Returns string "Hello  "
  # when
  # str = "Hello [$first_name] [$second_name]"
  #
  def content_without_inclusion(key)
    content_with_inclusion(key, [])
  end
end
