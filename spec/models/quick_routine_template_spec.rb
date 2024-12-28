require 'rails_helper'

RSpec.describe QuickRoutineTemplate, type: :model do
  describe 'バリデーション' do
    context '正常な値' do
      it 'QuickRoutineTemplateを作成できる' do
        quick_routine_template = create(:quick_routine_template)
        expect(quick_routine_template).to        be_valid
        expect(quick_routine_template.errors).to be_empty
      end
    end

    context "不正な値" do
      it 'titleは必須' do
        quick_routine_template = build(:quick_routine_template, title: nil)
        expect(quick_routine_template).not_to            be_valid
        expect(quick_routine_template.errors[:title]).to eq ['を入力してください']
      end

      it 'titleは25字以内、説明文は500字以内' do
        quick_routine_template = build(:quick_routine_template, :over_length)
        expect(quick_routine_template).to                      be_invalid
        expect(quick_routine_template.errors[:title]).to       eq ['は25文字以内で入力してください']
        expect(quick_routine_template.errors[:description]).to eq ['は500文字以内で入力してください']
      end
    end
  end

  describe 'アソシエーション' do
    describe 'User:QuickRoutineTemplate = 1:N' do
      let!(:user)                   { create(:user) }
      let!(:quick_routine_template) { create(:quick_routine_template, user: user) }

      it '適切に設定されている' do
        expect(user.quick_routine_template).to eq quick_routine_template
      end
    end
  end

  describe 'DB制約' do
    describe 'デフォルト値' do
      let!(:quick_routine_template) { create(:quick_routine_template) }

      it '適切に設定されている' do
        expect(quick_routine_template.title).to      eq 'new ルーティン'
      end
    end

    describe 'NOT NULL' do
      it 'titleカラム' do
        quick_routine_template = build(:quick_routine_template, title: nil)
        expect{ quick_routine_template.save(validate: false) }.to raise_error ActiveRecord::NotNullViolation
      end
    end
  end

  # describe 'スコープ' do
  # end

  # describe 'インスタンスメソッド' do
  # end

  # describe 'クラスメソッド' do
  # end
end
