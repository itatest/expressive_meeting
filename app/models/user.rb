class User < ActiveRecord::Base
  authenticates_with_sorcery!
  
  validates :name, presence: true, length: {maximum: 255}
  # email is validated by 'validates_email_format_of' gem
  validates :email, allow_blank: true, length: {maximum: 255}, :email_format => {:message => 'not email format'}
  validates :password, presence: true, length: { minimum: 6, maximum: 255 }, format: { with: /\A(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])[\S]+\z/}, on: :create
  validates :password, allow_blank: true, length: {minimum: 6, maximum: 255 }, format: { with: /\A(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])[\S]+\z/}, on: :update
  validates :password, confirmation: true
  validates :password_confirmation, presence: true, on: :create
end
