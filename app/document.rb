require 'article_json'

class Document
  def initialize(google_document)
    @google_document = google_document
  end

  def id
    @google_document.id
  end

  def title
    @google_document.title
  end

  def modified_time
    @google_document.modified_time
  end

  def modified_time_display
    modified_time.strftime('%d %b %Y')
  end

  def last_author_name
    @google_document.last_modifying_user.display_name
  end

  def teaser
    article_json.to_plain_text[0..500]
  end

  def html_body
    article_json.to_html
  end

  def amp_body
    article_json.to_amp
  end

  def amp_libraries
    [
      '<script async="" src="https://cdn.ampproject.org/v0.js"></script>',
      *article_json.amp_exporter.amp_libraries
    ]
  end

  private

  def article_json
    @article_json ||=
      ::ArticleJSON::Article.from_google_doc_html(google_doc_html)
  end

  def google_doc_html
    @google_document.export_as_string('html')
  end
end
