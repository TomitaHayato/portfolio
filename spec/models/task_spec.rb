require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'バリデーションチェック' do
    describe 'タスク新規作成' do
      it 'タスクを新規作成できる' do
        task = build(:task)
        expect(task.estimated_time_in_second).to eq 60
        expect(task).to be_valid
        expect(task.errors).to be_empty
      end

      it 'DB保存時にposition属性の値が追加される' do
        task = build(:task)
        expect(task.position).to be_nil
        task.save
        expect(task.position).not_to be_nil
      end

      it 'titleまたはestimated_time_in_second属性がnilの場合、バリデーションエラー' do
        task = build(:task, :nil_title_estimated_time)
        expect(task).to be_invalid
        expect(task.errors[:title]).to eq ['を入力してください']
        expect(task.errors[:estimated_time_in_second]).to eq ['を入力してください', 'は1以上の整数を入力してください']
      end

      it 'titleの文字数が25文字より多い場合、バリデーションエラー' do
        task = build(:task, :over_title)
        expect(task).to be_invalid
        expect(task.errors[:title]).to eq ['は25文字以内で入力してください']
      end

      it 'estimated_time_in_secondの値が0以下の場合、バリデーションエラー' do
        task = build(:task, :zero_estimated_time)
        expect(task).to be_invalid
        expect(task.errors[:estimated_time_in_second]).to eq ['は1以上の整数を入力してください']
      end
    end
  end

  describe 'Taskモデルのインスタンスメソッドの動作テスト' do
    describe 'estimated_timeメソッドの処理' do
      context '時間数・分数・秒数がそれぞれ１桁になる場合' do
        it 'estimated_timeメソッドの返り値が、estimated_time_in_secondをHH:MM:SS表記に直したハッシュになる' do
          task = build(:task, estimated_time_in_second: 3661)
          return_estimated_time = task.estimated_time
          expect(return_estimated_time[:hour]).to eq '01'
          expect(return_estimated_time[:hour]).to eq '01'
          expect(return_estimated_time[:hour]).to eq '01'
        end
      end
      context '時間数・分数・秒数が2桁の場合' do
        it 'estimated_timeメソッドの返り値が、estimated_time_in_secondをHH:MM:SS表記に直したハッシュになる' do
          task = build(:task, estimated_time_in_second: 36610)
          return_estimated_time = task.estimated_time
          expect(return_estimated_time[:hour]).to eq 10
          expect(return_estimated_time[:hour]).to eq 10
          expect(return_estimated_time[:hour]).to eq 10
        end
      end
    end
  end
end
