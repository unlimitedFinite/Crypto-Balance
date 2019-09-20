class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  encrypts :secret_key, :api_key
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :portfolio

  validates :email, uniqueness: true
  validates :first_name, :last_name, presence: true
end
