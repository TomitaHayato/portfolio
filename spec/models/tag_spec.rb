require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'バリデーション' do
    context '正常値' do
      let!(:tag) { create(:tag) }

      it 'タグを作成できる' do
        expect(tag).to        be_valid
        expect(tag.errors).to be_empty
      end
    end

    context '不正値' do
      it 'nameがnil' do
        tag = build(:tag, name: nil)
        expect(tag).not_to           be_valid
        expect(tag.errors[:name]).to eq ['を入力してください']
      end
    end
  end

  describe 'アソシエーション' do
    describe 'Tag:Task' do
      context 'N:M(task_tag)' do
        let!(:task)     { create(:task) }
        let!(:tag)      { create(:tag)  }
        let!(:task_tag) { create(:task_tag, task: task, tag: tag) }

        it 'アソシエーションが適切' do
          expect(tag.tasks).to     include task
          expect(tag.task_tags).to include task_tag
        end

        it '中間テーブルdependent: :destroy' do
          task_tag_id = task_tag.id
          task_id     = task.id
          tag.destroy!
          sleep 0.1
          expect(TaskTag.find_by(id: task_tag_id)).to eq nil
          expect(Task.find_by(id: task_id)).to        eq task
        end
      end
    end
  end

  describe 'DB制約' do
    describe 'NOT_NULL' do
      it 'name' do
        tag = build(:tag, name: nil)
        expect{ tag.save(validate: false) }.to raise_error ActiveRecord::NotNullViolation
      end
    end
  end

  describe 'インスタンスメソッド' do
    it 'is_on_task?(task)' do
      task1 = create(:task)
      task2 = create(:task)
      tag   = create(:tag)
      
      tag.tasks << task1
      sleep 0.1

      expect(tag.is_on_task?(task1)).to eq true
      expect(tag.is_on_task?(task2)).to eq false
    end
  end
end
