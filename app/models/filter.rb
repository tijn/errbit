class Filter
  include Mongoid::Document

  FIELDS = [:message, :error_class, :url, :where]

  field :description
  field :message
  field :error_class
  field :url
  field :where
  field :count, default: 0

  scope :global, -> { where(:app_id.in => [nil, '']) }

  belongs_to :app
  delegate :name, to: :app, prefix: true

  validates :description, presence: true
  validate :at_least_one_criteria_present

  def matches(notice)
    FIELDS.map { |sym| match?(sym, notice) if self[sym].present? }
  end

  def pass?(notice)
    fail 'Abstract Method'
  end

  def global?
    app.nil?
  end

  def up_count_for_match
    self.count += 1
    self.save!
  end

  private

  def match?(attribute, notice)
    criteria = Regexp.new self[attribute]
    criteria === notice.send(attribute)
  end

  def at_least_one_criteria_present
    all_empty = FIELDS.map { |sym| self[sym].present? }.none?
    errors.add(:base, 'At least one criteria must be present.') if all_empty
  end
end
