class Beggar < ApplicationRecord
  enum status: [:init, :prepared, :running, :stopped]

  def paged_site(page)
    site.include?("${page}") ? site.sub("${page}", page.to_s) : site
  end
end
