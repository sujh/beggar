class Beggar < ApplicationRecord
  enum status: [:init, :ok, :forbidden]
end
