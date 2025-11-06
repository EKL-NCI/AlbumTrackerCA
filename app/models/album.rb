class Album < ApplicationRecord
  # Ensure these fields are filled in
  validates :title, presence: true
  validates :artist, presence: true
  validates :genre, presence: true

  # Make sure the year is a number above 1900 and not in the future
  validates :release_year,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1900,
              less_than_or_equal_to: Date.today.year
            }

  # Rating should be between 0 and 5
  validates :rating,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 5
            }

  # Boolean field must be true or false
  validates :availability, inclusion: { in: [ true, false ] }
end