require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:password) }
  end

  describe 'roles' do
    it 'can be created as default user' do
      user = User.create(email: 'user@email.com', password: 'password', first_name: 'Jim', role: 0)

      expect(user.role).to eq('default')
      expect(user.default?).to be_truthy
    end

    it 'can be created as an Admin user' do
      admin = User.create(email: 'admin@email.com', password: 'admin', first_name: 'Bob', role: 1)

      expect(admin.role).to eq('admin')
      expect(admin.admin?).to be_truthy
    end
  end

  describe 'model method tests', :vcr do
    before :each do
      @user = User.create!(
        email: 'cg@mail.com',
        first_name: 'Childish',
        last_name: 'Gambino',
        password: 'none',
        role: :default,
        activated: 1,
        confirm_token: Faker::Crypto.md5,
        github_token: Figaro.env.github_personal_token.to_s,
        github_url: 'https://github.com/iEv0lv3'
      )

      @user2 = User.create!(
        first_name: 'Pierce',
        last_name: 'Alworth',
        email: 'pierce@mail.com',
        password: 'none',
        github_url: 'https://github.com/palworth',
        github_token: Figaro.env.github_personal_token2.to_s
      )
    end

    it 'my repos' do
      expect(@user.my_repos).to include(Repo)
    end

    it 'my followers' do
      expect(@user.my_followers).to include(Follower)
    end

    it 'following' do
      expect(@user.following).to include(Follower)
    end

    it 'my friend?' do
      follower = @user.my_followers[16]
      expect(@user.my_friend?(follower)).to eq(false)
    end

    it 'add friend?' do
      follower = @user.my_followers[16]
      expect(@user.add_friend?(follower)).to eq(true)
    end

    it 'create friendship' do
      expect(@user.create_friendship(@user2.id)).to eq('success')
    end

    it 'my bookmarks' do
      videos = create_list(:video, 3)
      create(:user_video, user_id: @user.id, video_id: videos[0].id)
      create(:user_video, user_id: @user.id, video_id: videos[1].id)
      create(:user_video, user_id: @user.id, video_id: videos[2].id)

      expect(@user.my_bookmarks).to eq([videos[0], videos[1], videos[2]])
    end
  end
end
