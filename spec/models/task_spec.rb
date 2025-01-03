require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'バリデーション' do
    context '正常な値' do
      it 'タスクが生成できる' do
        task = create(:task)
        expect(task).to        be_valid
        expect(task.errors).to be_empty
      end
    end

    context '不正な値' do
      it 'title、estimated_time_in_secondは必須' do
        task = build(:task, :nil_title_estimated_time)
        expect(task).to be_invalid
        expect(task.errors[:title]).to                    eq ['を入力してください']
        expect(task.errors[:estimated_time_in_second]).to eq ['を入力してください', 'は1秒以上で設定してください']
      end

      it 'titleは25文字以内' do
        task = build(:task, :over_title)
        expect(task).to                be_invalid
        expect(task.errors[:title]).to eq ['は25文字以内で入力してください']
      end

      it 'estimated_time_in_secondは1以上の整数' do
        task = build(:task, :zero_estimated_time)
        expect(task).to be_invalid
        expect(task.errors[:estimated_time_in_second]).to eq ['は1秒以上で設定してください']
      end
    end
  end

  describe 'アソシエーション' do
    describe 'Task:Routine' do
      context 'N:1' do
        let!(:routine) { create(:routine) }
        let!(:task)    { create(:task   , routine: routine) }

        it 'アソシエーションが適切' do
          expect(task.routine).to eq routine
        end
      end
    end

    describe 'Task:Tag' do
      context 'N:M' do
        let!(:task)     { create(:task) }
        let!(:tag)      { create(:tag) }
        let!(:task_tag) { create(:task_tag, task: task, tag: tag) }

        it 'アソシエーションが適切' do
          expect(task.tags).to      include tag
          expect(task.task_tags).to include task_tag
        end

        it '中間テーブル dependent: :destroy' do
          task_tag_id = task_tag.id
          tag_id      = tag.id
          task.destroy!
          sleep 0.1
          expect(Tag.find_by(id: tag_id)).to          eq tag
          expect(TaskTag.find_by(id: task_tag_id)).to eq nil
        end
      end
    end
  end

  describe 'DB制約' do
    describe 'NOT_NULL' do
      it 'title' do
        task = build(:task, title: nil)
        expect{ task.save(validate: false) }.to raise_error ActiveRecord::NotNullViolation
      end

      it 'estimated_time_in_second' do
        task = build(:task, estimated_time_in_second: nil)
        expect{ task.save(validate: false) }.to raise_error ActiveRecord::NotNullViolation
      end
    end

    describe 'LIMIT' do
      it 'title 25文字以内' do
        task = build(:task, :over_title)
        expect{ task.save(validate: false) }.to raise_error ActiveRecord::ValueTooLong
      end
    end

    describe 'デフォルト値' do
      it 'estimated_time_in_second 60' do
        task = create(:task)
        expect(task.estimated_time_in_second).to eq 60
      end
    end
  end

  describe 'インスタンスメソッド' do
    let(:task1) { create(:task) }
    let(:task2) { create(:task) }
    let(:tag1)  { create(:tag) }
    let(:tag2)  { create(:tag) }

    describe 'estimated_time' do
      context '時間数・分数・秒数が１桁' do
        it '返り値が、HH:MM:SS表記のハッシュ' do
          task = build(:task, estimated_time_in_second: 3661)
          return_estimated_time = task.estimated_time

          expect(return_estimated_time[:hour]).to   eq '01'
          expect(return_estimated_time[:minute]).to eq '01'
          expect(return_estimated_time[:second]).to eq '01'
        end
      end

      context '時間数・分数・秒数が2桁' do
        it '返り値が、HH:MM:SS表記のハッシュ' do
          task = build(:task, estimated_time_in_second: 36610)
          return_estimated_time = task.estimated_time

          expect(return_estimated_time[:hour]).to   eq 10
          expect(return_estimated_time[:minute]).to eq 10
          expect(return_estimated_time[:second]).to eq 10
        end
      end
    end

    describe 'copy_tags' do
      it 'タスクに紐づいたTagをコピーできる' do
        task1.tags << tag1
        task1.tags << tag2

        task1.copy_tags(task2)
        expect(task2.tags).to include tag1
        expect(task2.tags).to include tag2
      end
    end

    describe 'delete_tags_from_task' do
      before do
        task1.tags << tag1
        task1.tags << tag2
      end

      it '指定されたidを持つTagをTaskから切り離す' do
        expect(task1.tags).to include tag1
        expect(task1.tags).to include tag2

        tag_ids_params = [tag1.id, tag2.id]
        task1.delete_tags_from_task(tag_ids_params)

        expect(task1.tags).not_to include tag1
        expect(task1.tags).not_to include tag2
      end
    end

    describe 'put_tags_on_task' do
      it '指定されたidを持つTagをTaskに紐づける' do
        expect(task1.tags).not_to include tag1
        expect(task1.tags).not_to include tag2

        tag_ids_params = [tag1.id, tag2.id]
        task1.put_tags_on_task(tag_ids_params)

        expect(task1.tags).to include tag1
        expect(task1.tags).to include tag2
      end
    end
  end

  describe 'Gem acts_as_listの設定' do
    it 'positonカラムが自動で作成される' do
      routine = create(:routine)
      task1 = create(:task, routine: routine)
      task2 = create(:task, routine: routine)
      task3 = create(:task, routine: routine)
      sleep 0.1
      expect(task1.position).to eq 1
      expect(task2.position).to eq 2
      expect(task3.position).to eq 3
    end

    it 'positionカラムの値はroutineごとに作成' do
      routineA = create(:routine)
      taskA1   = create(:task, routine: routineA)
      taskA2   = create(:task, routine: routineA)
      routineB = create(:routine)
      taskB1   = create(:task, routine: routineB)
      taskB2   = create(:task, routine: routineB)
      sleep 0.1
      expect(taskA1.position).to eq 1
      expect(taskA2.position).to eq 2
      expect(taskB1.position).to eq 1
      expect(taskB2.position).to eq 2
    end
  end
end
