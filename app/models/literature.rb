# == Schema Information
#
# Table name: literatures
#
#  id                :integer          not null, primary key
#  title             :string           not null
#  short_description :text
#  content           :text             not null
#  published_at      :date             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  metaphor          :text
#  type              :string
#  author_id         :integer
#
# Indexes
#
#  index_literatures_on_author_id  (author_id)
#

class Literature < ActiveRecord::Base
  include Taggable
  belongs_to :author

  validates :title, :content, :author, :published_at, presence: true
  validate :published_in_the_past

  after_save :tag_content, if: :content_changed?

  delegate :name, to: :author, prefix: true

  private
    def published_in_the_past
      if published_at && published_at > Date.today
        errors.add(:published_at, "can't be in the future")
      end
    end

    def tag_content
      words = content.strip.downcase.split(/\W+/)
      TaggingService.new(self).tag(words)
    end
end
