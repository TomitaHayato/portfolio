require 'rails_helper'

RSpec.describe UserTagExperience, type: :model do
  let!(:user) { create(:user) }
  let!(:tag)  { create(:tag)  }

  describe 'バリデーション' do
    context '正常値' do
      let!(:user_tag_experience) { create(:user_tag_experience, user: user, tag: tag) }
      
      it '作成できる' do
        expect(user_tag_experience).to         be_valid
        expect(user_tag_experience.errors).to be_empty
      end
    end

    context '不正値' do
      it 'experience_pointがnil' do
        user_tag_experience = build(:user_tag_experience, user: user, tag: tag, experience_point: nil)
        expect(user_tag_experience).not_to                       be_valid
        expect(user_tag_experience.errors[:experience_point]).to eq ['を入力してください']
      end
    end
  end

  describe 'DB制約' do
    describe 'NOT_NULL' do
      it 'experience_point' do
        user_tag_experience = build(:user_tag_experience, user: user, tag: tag, experience_point: nil)
        expect{ user_tag_experience.save(validate: false) }.to raise_error ActiveRecord::NotNullViolation
      end
    end
  end

  describe 'scope' do
    it 'recent_one_month' do
      exp_1day_ago   = create(:user_tag_experience, user: user, tag: tag, created_at: 1.day.ago)
      exp_2weeks_ago = create(:user_tag_experience, user: user, tag: tag, created_at: 2.weeks.ago)
      exp_1year_ago  = create(:user_tag_experience, user: user, tag: tag, created_at: 1.year.ago)

      expect_val = UserTagExperience.where("created_at >= ?", 1.month.ago)
      actual_val = UserTagExperience.recent_one_month

      expect(expect_val).to     match_array actual_val
      expect(expect_val).to     include     exp_1day_ago
      expect(expect_val).to     include     exp_2weeks_ago
      expect(expect_val).not_to include     exp_1year_ago
    end

    it 'recent_one_week' do
      exp_1day_ago    = create(:user_tag_experience, user: user, tag: tag, created_at: 1.day.ago)
      exp_2weeks_ago  = create(:user_tag_experience, user: user, tag: tag, created_at: 2.weeks.ago)
      exp_1year_ago   = create(:user_tag_experience, user: user, tag: tag, created_at: 1.year.ago)

      expect_val = UserTagExperience.where("created_at >= ?", 1.week.ago)
      actual_val = UserTagExperience.recent_one_week

      expect(expect_val).to     match_array actual_val
      expect(expect_val).to     include     exp_1day_ago
      expect(expect_val).not_to include     exp_2weeks_ago
      expect(expect_val).not_to include     exp_1year_ago
    end
  end

  describe 'クラスメソッド' do
    it 'self.total_experience_points' do
      exp1 = create(:user_tag_experience, user: user, tag: tag)
      exp2 = create(:user_tag_experience, user: user, tag: tag)
      exp3 = create(:user_tag_experience, user: user, tag: tag)
      
      expect_val = 3
      actual_val = user.user_tag_experiences.total_experience_points
      expect(actual_val).to eq expect_val
    end
  end
end
