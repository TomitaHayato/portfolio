class Contact < ApplicationRecord
  validates :name   , presence: true
  validates :email  , presence: true
  validates :subject, presence: true
  validates :message, presence: true

  enum subject:          { bug: 0, request: 1, others: 2 }
  enum is_need_response: {  no: 0,     yes: 1 }
end
