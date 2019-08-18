class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  encrypts :secret_key
  encrypts :api_key
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :portfolio

  validates :email, uniqueness: true
  # validates :api_key, presence: true
end
