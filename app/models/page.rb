class Page < ActiveRecord::Base
  belongs_to :user

  has_many :authentications, dependent: :destroy do
    def facebook
      @facebook ||= Socialable::Facebook::Provider.new(self.where(provider: 'facebook').first)
    end
  end
end
