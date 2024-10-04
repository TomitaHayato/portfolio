require 'rails_helper'

RSpec.describe Routine, type: :model do
  describe 'バリデーションチェック' do
    describe 'ルーティン新規登録' do
      it 'ルーティンを新規作成できる' do
        routine = create(:routine)
        expect(routine).to be_valid
        expect(routine.errors).to be_empty
        expect(routine.is_posted).to be_falsey
        expect(routine.is_active).to be_falsey
      end

      it 'タイトルが存在しない場合、バリデーションエラーになる' do
        routine = build(:routine, :nil_title)
        expect(routine).to be_invalid
        expect(routine.errors[:title]).to eq ['を入力してください']
      end

      it 'タイトルが50字より多いまたは説明文が500字より多い => バリデーションエラー' do
        routine = build(:routine, :over_length)
        expect(routine).to be_invalid
        expect(routine.errors[:title]).to eq ['は50文字以内で入力してください']
        expect(routine.errors[:description]).to eq ['は500文字以内で入力してください']
      end
    end
  end

  describe 'スコープの機能を確認' do
    it 'posted スコープで投稿されたルーティン一覧が取得できる' do
      create(:routine, is_posted: true)
      create(:routine, is_posted: true)
      create(:routine, is_posted: false)
      posted_routines = Routine.where(is_posted: true)

      expect(Routine.posted).to match_array(posted_routines)
    end
  end
end
