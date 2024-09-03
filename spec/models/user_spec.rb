require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーションCheck' do
    context 'ユーザーの新規登録' do
      it 'name, email, password, password_confirmationが存在し、passwordが4文字以上であれば有効である + role, completed_routine_countのデフォルト値が設定されているか' do
        user = create(:user)
        expect(user).to be_valid
        expect(user.errors).to be_empty
        expect(user.role).to eq('general')
        expect(user.complete_routines_count).to eq(0)
      end

      it 'name, email, password_confirmationのpresence: true + passwordのlength: {minimum: 4} が機能しているか' do
        user = build(:user, :no_attribute)
        expect(user).to be_invalid
        expect(user.errors[:name]).to eq ['を入力してください']
        expect(user.errors[:email]).to eq ['を入力してください']
        expect(user.errors[:password_confirmation]).to eq ['を入力してください']
        expect(user.errors[:password]).to eq ['は4文字以上で入力してください']
      end

      it 'emailのuniqueness: trueが機能しているか' do
        user1 = create(:user, email: 'test@ex.com')
        user2 = build(:user, email: 'test@ex.com')
        
        expect(user1).to be_valid
        expect(user1.errors).to be_empty
        
        expect(user2).not_to be_valid
        expect(user2.errors[:email]).to eq ['はすでに存在します']
      end

      it 'passwordのconfirmation: trueが機能しているか' do
        user = build(:user, :no_match_password_confirmation)
        expect(user).to be_invalid
        expect(user.errors[:password_confirmation]).to eq ['とパスワードの入力が一致しません']
      end
    end
  end
end