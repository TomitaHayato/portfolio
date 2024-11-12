require 'rails_helper'

RSpec.describe Reward, type: :model do
  describe 'バリデーション' do
    context '正常な値' do
      it '作成できる' do
        reward = create(:reward)
        expect(reward).to        be_valid
        expect(reward.errors).to be_empty
      end
    end

    context '不正な値' do
      it 'nameがnil' do
        reward = build(:reward, name: nil)
        expect(reward).not_to           be_valid
        expect(reward.errors[:name]).to eq ['を入力してください']
      end

      it 'conditionがnil' do
        reward = build(:reward, condition: nil)
        expect(reward).not_to           be_valid
        expect(reward.errors[:condition]).to eq ['を入力してください']
      end
    end
  end

  describe 'アソシエーション' do
    describe 'Reward:User' do
      context 'N:M(user_reward)' do
        let!(:user)        { create(:user) }
        let!(:reward)      { create(:reward) }
        let!(:user_reward) { create(:user_reward, user: user, reward: reward) }
        
        it 'アソシエーションが適切' do
          expect(reward.users).to        include user
          expect(reward.user_rewards).to include user_reward
        end

        it '中間テーブルdependent: :destroy' do
          user_reward_id = user_reward.id
          user_id        = user.id
          reward.destroy!
          sleep 0.1
          expect(UserReward.find_by(id: user_reward_id)).to eq nil
          expect(User.find_by(id: user_id)).to              eq user
        end
      end
    end
  end

  describe 'DB制約' do
    describe 'NOT_NULL' do
      it 'name' do
        reward = build(:reward, name: nil)
        expect{ reward.save(validate: false) }.to raise_error ActiveRecord::NotNullViolation
      end

      it 'condition' do
        reward = build(:reward, condition: nil)
        expect{ reward.save(validate: false) }.to raise_error ActiveRecord::NotNullViolation
      end
    end
  end

  describe 'scope' do
    let!(:user)        { create(:user)   }
    let!(:reward1)      { create(:reward) }
    let!(:reward2)      { create(:reward) }
    let!(:user_reward1) { create(:user_reward, user: user, reward: reward1) }

    it 'for_user(user_id)' do
      expect_val = Reward.joins(:user_rewards).where(user_rewards: { user_id: user.id })
      actual_val = Reward.for_user(user.id)

      expect(expect_val).to     match_array actual_val
      expect(actual_val).to     include reward1
      expect(actual_val).not_to include reward2
    end

    it 'not_for_user(user)' do
      expect_val = Reward.where.not(id: user.reward_ids)
      actual_val = Reward.not_for_user(user)

      expect(expect_val).to     match_array actual_val
      expect(actual_val).not_to include reward1
      expect(actual_val).to     include reward2
    end
  end
end