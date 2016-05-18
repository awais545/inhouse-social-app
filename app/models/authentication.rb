class Authentication < ActiveRecord::Base
  belongs_to :user

  def self.is_authenticated?(auth)
    find_by(provider: auth.provider, uid: auth.uid)
  end
end
