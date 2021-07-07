class Beggar < ApplicationRecord
  enum status: [:init, :ok, :forbidden]

  def paged_site(page)
    site.include?("${page}") ? site.sub("${page}", page.to_s) : site
  end
end
