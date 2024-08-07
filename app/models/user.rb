class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :email, presence: true, uniqueness: true
  # after_create :send_welcome_email

  has_many :posts, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post
  has_many :comments, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
       
  def follow(other_user)
    following << other_user unless self == other_user || following?(other_user)
  end

  def unfollow(other_user)
    following.delete(other_user) if following?(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

  private

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_now
  end
end
