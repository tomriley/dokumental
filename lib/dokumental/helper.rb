module Dokumental
module Helper
  
  def render_li_hierarchy(doc, skip_root = false)
    html = ''
    html << "<li>#{link_to h(doc.title), doc, :class => ('current' if @doc == doc)}\n" unless skip_root
    if doc.children
      html << "<ol>"
      doc.children.each do |child|
        html << render_li_hierarchy(child)
      end
      html << "</ol>\n"
    end
    html << "\n</li>" unless skip_root
    html
  end
  
  def link_to_doc(label, permalink, link_opts = {})
    doc = Doc.find_by_permalink(permalink)
    if !doc && current_user_can_edit_doc?(doc)
      link_to label, new_doc_path(:permalink => permalink), link_opts
    else
      link_to label, "/docs/#{permalink}", link_opts
    end
  end
  
  def current_user_can_edit_doc?(doc)
    raise "please implement the helper method 'current_user_can_edit_doc?'"
  end
  
  def current_user_can_create_doc?
    raise "please implement the helper method 'current_user_can_create_doc?'"
  end
  
end
end