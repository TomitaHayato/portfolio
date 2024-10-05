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

  describe 'モデルインスタンスメソッドの処理確認' do
    describe 'reset_statusメソッド' do
      it 'reset_statusメソッドを使用すると、is_active, is_posted, completed_count, copied_countカラムの値が初期化される' do
        routine = build(:routine, :active_posted_counted)
        routine_reseted = routine.reset_status
        expect(routine_reseted).to have_attributes(is_active: false, is_posted: false, completed_count: 0, copied_count: 0)
      end
    end

    describe 'total_estimated_timeメソッド' do
      context 'タスクが存在しない場合' do
        it 'total_estimated_timeメソッドの返り値が"00"になる' do
          routine = create(:routine)
          total_estimated_time_result = routine.total_estimated_time
          expect(total_estimated_time_result[:hour]).to eq '00'
          expect(total_estimated_time_result[:minute]).to eq '00'
          expect(total_estimated_time_result[:second]).to eq '00'
        end
      end
      
      context 'HH:MM:SSの各値が1桁の場合' do
        it 'total_estimated_timeメソッドの返り値が、Routineモデルインスタンスに属する全Taskの目安時間の合計になる' do
          routine = create(:routine)
          task1 = create(:task, routine: routine, estimated_time_in_second: 3661)
          task2 = create(:task, routine: routine, estimated_time_in_second: 3661)
          task_of_another_routine = create(:task, estimated_time_in_second: 3661)
          
          total_estimated_time_result = routine.total_estimated_time
          expect(total_estimated_time_result[:hour]).to eq '02'
          expect(total_estimated_time_result[:minute]).to eq '02'
          expect(total_estimated_time_result[:second]).to eq '02'
        end
      end

      context 'HH:MM:SSの各値が2桁の場合' do
        it 'total_estimated_timeメソッドの返り値が、Routineモデルインスタンスに属する全Taskの目安時間の合計になる' do
          routine = create(:routine)
          task1 = create(:task, routine: routine, estimated_time_in_second: 36610)
          task2 = create(:task, routine: routine, estimated_time_in_second: 36610)
          task_of_another_routine = create(:task, estimated_time_in_second: 36610)
          
          total_estimated_time_result = routine.total_estimated_time
          expect(total_estimated_time_result[:hour]).to eq 20
          expect(total_estimated_time_result[:minute]).to eq 20
          expect(total_estimated_time_result[:second]).to eq 20
        end
      end
    end
  end
end
