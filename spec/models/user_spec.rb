require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    context '正常な値' do
      let!(:user) { create(:user) }

      it 'ユーザーが作成できる' do
        expect(user).to        be_valid
        expect(user.errors).to be_empty
      end
    end

    context '不正な値' do
      it 'name, email, password_confirmationは必須' do
        user = build(:user, :no_attribute)
        expect(user).to                                be_invalid
        expect(user.errors[:name]).to                  eq ['を入力してください']
        expect(user.errors[:email]).to                 eq ['を入力してください']
        expect(user.errors[:password_confirmation]).to eq ['を入力してください']
      end

      it 'nameは25文字以内' do
        user = build(:user, :over_name)
        expect(user).not_to           be_valid
        expect(user.errors[:name]).to eq ['は25文字以内で入力してください']
      end

      it 'passwordは8文字以上' do
        user = build(:user, password: '1234567')
        expect(user).not_to               be_valid
        expect(user.errors[:password]).to eq ['は8文字以上で入力してください']
      end

      it 'emailは一意である' do
        user1 = create(:user, email: 'test@ex.com')
        user2 = build( :user, email: 'test@ex.com')
        # user1は正常に作成されている
        expect(user1).to        be_valid
        expect(user1.errors).to be_empty
        # user2でエラー
        expect(user2).not_to            be_valid
        expect(user2.errors[:email]).to eq ['はすでに存在します']
      end

      it 'passwordとpassword_confirmationは一致する' do
        user = build(:user, :no_match_password_confirmation)
        expect(user).not_to                            be_valid
        expect(user.errors[:password_confirmation]).to eq ['とパスワードの入力が一致しません']
      end
    end
  end

  describe 'アソシエーション' do
    let!(:user1)    { create(:user) }
    let!(:user2)    { create(:user) }

    describe 'User:Routine' do
      let!(:routine1) { create(:routine, user: user1) }
      let!(:routine2) { create(:routine, user: user2) }

      context '1:N' do
        it 'user.routines' do
          expect(user1.routines).to     include routine1
          expect(user1.routines).not_to include routine2
        end

        it 'dependent: :destroy' do
          routine2_id = routine2.id
          user2.destroy!
          sleep 0.1
          expect(Routine.find_by(id: routine2_id)).to eq nil
        end
      end

      context 'N:M(中間: Likesテーブル)' do
        let!(:like) { create(:like, user: user1, routine: routine2) }

        it 'user.liked_routines' do
          expect(user1.liked_routines).not_to include routine1
          expect(user1.liked_routines).to     include routine2
          expect(user1.likes).to              include like
        end

        it 'dependent: :destroy' do
          like_id = like.id
          user1.destroy!
          sleep 0.1
          expect(Like.find_by(id: like_id)).to eq nil
        end
      end
    end

    describe 'User:Tag' do
      let!(:tag) { create(:tag) }

      context 'N:M' do
        let!(:user_tag_experience) { create(:user_tag_experience, user: user1, tag: tag) }
        
        it 'アソシエーションが適切' do
          expect(user1.tags).to                 include tag
          expect(user1.user_tag_experiences).to include user_tag_experience
        end

        it 'dependent: :destroy' do
          user_tag_experience_id = user_tag_experience.id
          tag_id                 = tag.id
          user1.destroy!
          sleep 0.1
          expect(Tag.find_by(id: tag_id)).not_to                           eq nil
          expect(UserTagExperience.find_by(id: user_tag_experience_id)).to eq nil
        end
      end
    end

    describe 'User:Reward' do
      let!(:reward) { create(:reward, :hajimarinoippo) }

      context 'N:M' do
        let!(:user_reward) { create(:user_reward, user: user1, reward: reward) }
        
        it 'アソシエーションが適切' do
          expect(user1.rewards).to      include reward
          expect(user1.user_rewards).to include user_reward
        end

        it 'dependent: :destroy' do
          user_reward_id = user_reward.id
          reward_id      = reward.id
          user1.destroy!
          sleep 0.1
          expect(UserReward.find_by(id: user_reward_id)).to eq nil
          expect(Reward.find_by(id: reward_id)).not_to      eq nil
        end
      end
    end
  end

  describe 'DB制約' do
    describe 'NOT NULL' do
      it 'name' do
        user = build(:user, name: nil)
        expect{ user.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
      end

      it 'email' do
        user = build(:user, email: nil)
        expect{ user.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
      end

      it 'role' do
        user = build(:user, role: nil)
        expect{ user.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
      end

      it 'level' do
        user = build(:user, level: nil)
        expect{ user.save(validate: false) }.to raise_error(ActiveRecord::NotNullViolation)
      end
    end

    describe 'デフォルト値' do
      it 'roleカラム default: 1' do
        user = create(:user)
        expect(user.role_before_type_cast).to eq 1
      end

      it 'levelカラム default: 1' do
        user = create(:user)
        expect(user.level).to eq 1
      end

      it 'completed_routine_countカラム default: 0' do
        user = create(:user)
        expect(user.complete_routines_count).to eq 0
      end

      it 'notificationカラム default:0' do
        user = create(:user)
        expect(user.notification_before_type_cast).to eq 0
      end
    end

    describe 'ユニーク' do
      it 'email' do
        create(:user, email: 'y@y')
        user_new = build(:user, email: 'y@y')
        expect{ user_new.save(validate: false) }.to raise_error ActiveRecord::RecordNotUnique
      end
    end
  end

  describe 'インスタンスメソッド' do
    let!(:user)    { create(:user) }
    let!(:reward1) { create(:reward, :hajimarinoippo) }
    let!(:reward2) { create(:reward, :wakamenoseichou) }
    let!(:reward3) { create(:reward, :chiisanatasseisha) }
    let!(:reward4) { create(:reward, :asanomorinoannnaininn) }

    describe 'add_complete_routines_count' do
      it 'complete_routines_countが1加算される' do
        count_prev = user.complete_routines_count
        user.add_complete_routines_count
        sleep 0.1
        expect(user.complete_routines_count).to eq count_prev + 1
      end
    end

    describe 'reward_get_check' do
      it '初期状態では称号を未獲得' do
        expect(user.rewards.size).to eq 0
      end

      it 'ルーティンの達成数で称号獲得し、trueを返す' do
        user.complete_routines_count = 3
        user.save!
        is_reward_get = user.reward_get_check
        expect(user.rewards).to     include reward1
        expect(user.rewards).not_to include reward2
        expect(user.rewards).to     include reward3
        expect(user.rewards).not_to include reward4
        expect(is_reward_get).to      eq      true
      end

      it '獲得経験値で称号獲得し、trueを返す' do
        tag                 = create(:tag)
        user_tag_experience = create(:user_tag_experience, user: user, tag: tag, experience_point: 10)
        is_reward_get = user.reward_get_check
        expect(user.rewards).not_to include reward1
        expect(user.rewards).to     include reward2
        expect(user.rewards).not_to include reward3
        expect(user.rewards).not_to include reward4
        expect(is_reward_get).to      eq true
      end

      it 'ルーティン投稿で称号獲得し、trueを返す' do
        routine = create(:routine, user: user, is_posted: true)
        is_reward_get = user.reward_get_check
        expect(user.rewards).not_to include reward1
        expect(user.rewards).not_to include reward2
        expect(user.rewards).not_to include reward3
        expect(user.rewards).to     include reward4
        expect(is_reward_get).to      eq true
      end
    end

    describe 'level_up_check' do
      let!(:tag) { create(:tag) }

      it '経験値が足りない場合、レベルは変わらない' do
        user_level_prev = user.level
        is_level_up     = user.level_up_check
        sleep 0.25
        expect(is_level_up).to eq false
        expect(user.level).to  eq user_level_prev
      end

      it '経験値によってレベルアップする' do
        user_tag_experience = create(:user_tag_experience, user: user, tag: tag, experience_point: 15)
        sleep 0.1
        user_level_prev = user.level
        is_level_up     = user.level_up_check
        sleep 0.1
        expect(is_level_up).to    eq true
        expect(user.level).not_to eq user_level_prev
        expect(user.level).to     eq 3
      end
    end

    describe 'exp_to_next_level' do
      let!(:tag)                 { create(:tag) }
      let!(:user_tag_experience) { create(:user_tag_experience, user: user, tag: tag, experience_point: 30) }

      before do
        user.level_up_check
      end

      it '次のレベルまでに必要な経験値が出力される' do
        # レベルが適切かどうか
        expect(user.level).to eq 4
        # 出力のテスト
        expect_val = 20
        actual_val = user.exp_to_next_level
        expect(actual_val).to eq expect_val
        # 経験値を10追加
        create(:user_tag_experience, user: user, tag: tag, experience_point: 10)
        sleep 0.1
        # 出力のテスト2
        expect_val = 10
        actual_val = user.exp_to_next_level
        expect(actual_val).to eq expect_val
      end

    end
  end

  describe 'enum' do
    describe 'roleカラム' do
      it 'admin: 0 が定義されている' do
        user = create(:user, role: 0)
        expect(user.role).to eq 'admin'
      end

      it 'general: 1 が定義されている' do
        user = create(:user, role: 1)
        expect(user.role).to eq 'general'
      end

      it 'guest: 2 が定義されている' do
        user = create(:user, role: 2)
        expect(user.role).to eq 'guest'
      end

      it '定義してない値を設定できない' do
        expect{ create(:user, role: 3) }.to raise_error ArgumentError
      end
    end

    describe 'notificationカラム' do
      it 'off: 0' do
        user = create(:user)
        expect(user.notification).to eq 'off'
      end

      it 'line: 1' do
        user = create(:user, notification: 1)
        expect(user.notification).to eq 'line'
      end

      it 'email: 2' do
        user = create(:user, notification: 2)
        expect(user.notification).to eq 'email'
      end

      it '定義してない値を設定できない' do
        expect{ create(:user, notification: 3) }.to raise_error ArgumentError
      end
    end
  end
end