class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  has_many :authentications

  def self.omniauth(auth)
    email = auth.info.email.present? ? auth.info.email : "#{auth.uid}@#{auth.provider}.com"
    
    where(email: email).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.password = Devise.friendly_token[0, 20]
      user.save!
    end
  end

  def set_authentications(auth)
    authentication = authentications.find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    authentication.auth_token = auth.credentials.token
    authentication.secret = auth.credentials.secret
    authentication.save!
  end
end
