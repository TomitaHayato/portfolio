require 'rails_helper'

RSpec.describe Routine, type: :model do
  describe 'バリデーション' do
    context '正常な値' do
      it 'ルーティンを作成できる' do
        routine = create(:routine)
        expect(routine).to           be_valid
        expect(routine.errors).to    be_empty
      end
    end

    context '不正な値' do
      it 'タイトルは必須' do
        routine = build(:routine, :nil_title)
        expect(routine).not_to            be_valid
        expect(routine.errors[:title]).to eq ['を入力してください']
      end

      it 'タイトルは25字以内、説明文は500字以内' do
        routine = build(:routine, :over_length)
        expect(routine).to                      be_invalid
        expect(routine.errors[:title]).to       eq ['は25文字以内で入力してください']
        expect(routine.errors[:description]).to eq ['は500文字以内で入力してください']
      end
    end
  end

  describe 'アソシエーション' do
    describe 'Routine:User' do
      let!(:user)       { create(:user) }
      let!(:user_other) { create(:user) }

      context 'N:1' do
        let!(:routine) { create(:routine, user: user) }

        it 'routine.user' do
          expect(routine.user).to eq user
        end
      end

      context 'N:M/お気に入り' do
        let!(:routine) { create(:routine, user: user_other) }
        let!(:like)    { create(:like   , user: user      , routine: routine) }

        it 'アソシエーションが適切' do
          expect(user.liked_routines).to include routine
          expect(user.likes).to          include like
        end

        it 'dependent: :destroy' do
          like_id = like.id
          routine.destroy!
          sleep 0.1
          expect(Like.find_by(id: like_id)).to eq nil
        end
      end
    end

    describe 'Routine:Task' do
      context '1:N' do
        let!(:routine) { create(:routine) }
        let!(:task)    { create(:task, routine: routine) }

        it 'アソシエーションが適切' do
          expect(routine.tasks).to include task
        end

        it 'dependent: :destroy' do
          task_id = task.id
          routine.destroy!
          sleep 0.1
          expect(Task.find_by(id: task_id)).to eq nil
        end
      end
    end
  end

  describe 'DB制約' do
    describe 'NOT_NULL' do
      it 'title' do
        routine = build(:routine, title: nil)
        expect{ routine.save(validate: false) }.to raise_error ActiveRecord::NotNullViolation
      end
    end

    describe 'デフォルト値' do
      let!(:routine) { create(:routine) }

      it 'is_activeがfalse' do
        expect(routine.is_active).to eq false
      end

      it 'is_postedがfalse' do
        expect(routine.is_posted).to eq false
      end

      it 'completed_countが0' do
        expect(routine.completed_count).to eq 0
      end

      it 'copied_countが0' do
        expect(routine.copied_count).to eq 0
      end
    end
  end

  describe 'スコープ' do
    it 'posted' do
      create(:routine, is_posted: true)
      create(:routine, is_posted: true)
      create(:routine, is_posted: false)

      posted_routines = Routine.where(is_posted: true)
      expect(Routine.posted).to match_array(posted_routines)
    end

    it 'unposted' do
      create(:routine, is_posted: true)
      create(:routine, is_posted: true)
      create(:routine, is_posted: false)

      unposted_routines = Routine.where(is_posted: false)
      expect(Routine.unposted).to match_array(unposted_routines)
    end

    it 'my_post' do
      user     = create(:user)
      routine1 = create(:routine, user: user)
      routine2 = create(:routine, user: user)
      routine3 = create(:routine)

      expect_routines = Routine.where(user_id: user.id)
      actual_routines = Routine.my_post(user.id)
      expect(actual_routines).to match_array expect_routines
    end

    it 'official' do
      user_general = create(:user, role: 'general')
      user_admin   = create(:user, role: 'admin'  )
      routine_g    = create(:routine, user: user_general)
      routine_a    = create(:routine, user: user_admin  )

      expect_routines = Routine.joins(:user).where(users: { role: 'admin' })
      actual_routines = Routine.official
      expect(expect_routines).to match_array actual_routines
    end

    it 'general' do
      user_general = create(:user, role: 'general')
      user_admin   = create(:user, role: 'admin'  )
      routine_g    = create(:routine, user: user_general)
      routine_a    = create(:routine, user: user_admin  )

      expect_routines = Routine.joins(:user).where(users: { role: 'general' })
      actual_routines = Routine.general
      expect(expect_routines).to match_array actual_routines
    end

    it 'liked' do
      user     = create(:user)
      routine1 = create(:routine)
      routine2 = create(:routine)
      routine3 = create(:routine)

      user.liked_routines << routine1
      user.liked_routines << routine2

      expect_routines = Routine.joins(:likes).where(likes: { user_id: user.id }) 
      actual_routines = Routine.liked(user.id)
      expect(expect_routines).to match_array actual_routines
    end
  end

  describe 'インスタンスメソッド' do
    describe 'reset_status' do
      it 'is_active, is_posted, completed_count, copied_countの値が初期化される' do
        routine         = build(:routine, :active_posted_counted)
        routine_reseted = routine.reset_status
        expect(routine_reseted).to have_attributes(is_active: false, is_posted: false, completed_count: 0, copied_count: 0)
      end
    end

    describe 'total_estimated_time' do
      context 'タスクが存在しない場合' do
        it 'total_estimated_timeメソッドの返り値が"00"になる' do
          routine                     = create(:routine)
          total_estimated_time_result = routine.total_estimated_time

          expect(total_estimated_time_result[:hour]).to   eq '00'
          expect(total_estimated_time_result[:minute]).to eq '00'
          expect(total_estimated_time_result[:second]).to eq '00'
        end
      end

      context 'HH:MM:SSの各値が1桁の場合' do
        it '全Taskの目安時間の合計を返す' do
          routine                 = create(:routine)
          task1                   = create(:task, routine: routine, estimated_time_in_second: 3661)
          task2                   = create(:task, routine: routine, estimated_time_in_second: 3661)
          task_of_another_routine = create(:task                  , estimated_time_in_second: 3661)
          
          total_estimated_time_result = routine.total_estimated_time
          expect(total_estimated_time_result[:hour]).to   eq '02'
          expect(total_estimated_time_result[:minute]).to eq '02'
          expect(total_estimated_time_result[:second]).to eq '02'
        end
      end

      context 'HH:MM:SSの各値が2桁の場合' do
        it '全Taskの目安時間の合計を返す' do
          routine                 = create(:routine)
          task1                   = create(:task   , routine: routine, estimated_time_in_second: 36610)
          task2                   = create(:task   , routine: routine, estimated_time_in_second: 36610)
          task_of_another_routine = create(:task                     , estimated_time_in_second: 36610)
          
          total_estimated_time_result = routine.total_estimated_time
          expect(total_estimated_time_result[:hour]).to   eq 20
          expect(total_estimated_time_result[:minute]).to eq 20
          expect(total_estimated_time_result[:second]).to eq 20
        end
      end
    end

    describe 'complete_count' do
      it 'completed_countカラムが+1される' do
        routine    = create(:routine)
        count_prev = routine.completed_count

        routine.complete_count
        routine.reload

        expect(routine.completed_count).to eq count_prev + 1
      end
    end

    describe 'copy' do
      let!(:user1)    { create(:user) }
      let!(:user2)    { create(:user) }
      let!(:routine1) { create(:routine, :active_posted_counted, user: user1) }
      let!(:task1)    { create(:task   , routine: routine1) }
      let!(:task2)    { create(:task   , routine: routine1) }
      let!(:tag1)     { create(:tag) }
      let!(:tag2)     { create(:tag) }

      before do
        task1.tags << tag1
        task2.tags << tag2
      end

      it 'Routine, Task, TaskTagレコードがコピーされる' do
        prev_count         = routine1.copied_count
        prev_routines_size = user2.routines.size

        routine1.copy(user2)

        expect(user2.routines.size).to   eq prev_routines_size + 1
        expect(routine1.copied_count).to eq prev_count + 1

        routine2 = user2.routines.last
        # status_resetされているか
        expect(routine2).to have_attributes(
          is_active:   false,
          is_posted:   false,
          completed_count: 0,
          copied_count:    0
        )
        # カラムがコピーされているか
        expect(routine2).to have_attributes(
          title:       routine1.title,
          description: routine1.description,
          start_time:  routine1.start_time
        )
        # Taskがコピーされているか
        expect(routine2.tasks.size).to eq routine1.tasks.size
        task1_dup = routine2.tasks.first
        task2_dup = routine2.tasks.last

        expect(task1_dup).to have_attributes(
          title:                    task1.title,
          position:                 task1.position,
          estimated_time_in_second: task1.estimated_time_in_second,
        )
        # 紐づいたTagをコピーできているか
        expect(task1_dup.tags).to include tag1
        expect(task2_dup.tags).to include tag2
      end
    end
  end

  describe 'クラスメソッド' do
    describe 'self.search(user_word)' do
      let!(:user)      { create(:user) }
      let!(:routineA1) { create(:routine, title: 'ルーティンA' , description: '説明文A') }
      let!(:routineA2) { create(:routine, title: 'ルーティンAA', description: '説明文A2') }
      let!(:routineB1) { create(:routine, title: 'ルーティンB' , description: '説明文B') }
      let!(:routineB2) { create(:routine, title: 'ルーティンBB', description: '説明文B2') }

      context 'user_wordがnil' do
        it 'すべてのルーティンを取得' do
          expect_val = Routine.all
          actual_val = Routine.search(nil)
          expect(expect_val).to match_array actual_val
        end
      end

      context 'user_wordが存在' do
        it 'titleで検索できる' do
          user_word = 'ルーティンA'
          actual_val = Routine.search(user_word)
          expect_val = Routine.where('routines.title LIKE ? OR routines.description LIKE ?', "%#{user_word}%", "%#{user_word}%")
          expect(expect_val).to match_array actual_val
        end

        it 'descriptionで検索できる' do
          user_word = '説明文A'
          actual_val = Routine.search(user_word)
          expect_val = Routine.where('routines.title LIKE ? OR routines.description LIKE ?', "%#{user_word}%", "%#{user_word}%")
          expect(expect_val).to match_array actual_val
        end

        it 'user_wordは空白で区切ってAND検索できる' do
          user_word = 'ルーティン B'
          user_words = user_word.split(' ')
          actual_val = Routine.search(user_word)
          expect_val = Routine.where('(routines.title LIKE ? OR routines.description LIKE ?) AND (routines.title LIKE ? OR routines.description LIKE ?)', "%#{user_words[0]}%", "%#{user_words[0]}%", "%#{user_words[1]}%", "%#{user_words[1]}%")
          expect(expect_val).to match_array actual_val
        end
      end
    end

    describe 'self.custom_filter(filter_target, login_user_id)' do
      let!(:user)   { create(:user) }
      let!(:user_a) { create(:user, role: 'admin') }

      before do
        create(:routine, user: user_a)
        create(:routine, user: user_a)
        create(:routine, user: user)
        create(:routine, user: user)
      end

      it '公式アカウントのルーティンで絞り込み' do
        filter_target = 'official'
        login_user_id = user.id
        expect_val    = Routine.joins(:user).where(users: { role: 'admin' })
        actual_val    = Routine.custom_filter(filter_target, login_user_id)
        expect(expect_val).to match_array actual_val
      end
    end

    describe 'self.sort_posted(column, direction)' do
      let!(:routine1) { create(:routine, is_active: true, posted_at: 10.days.ago, copied_count:  4) }
      let!(:routine2) { create(:routine, is_active: true, posted_at:  2.days.ago, copied_count:  3) }
      let!(:routine3) { create(:routine, is_active: true, posted_at:  3.days.ago, copied_count:  2) }
      let!(:routine4) { create(:routine, is_active: true, posted_at:  4.days.ago, copied_count: 10) }

      it 'デフォルト: 投稿日の降順でソート' do
        column    = nil
        direction = nil
        expect_val = Routine.order(posted_at: :desc)
        actual_val = Routine.sort_routine(column, direction)
        expect(expect_val).to match_array actual_val
      end

      it 'コピー数の昇順でソート' do
        column    = 'copied_count'
        direction = 'asc'
        expect_val = Routine.order(copied_count: :asc)
        actual_val = Routine.sort_routine(column, direction)
        expect(expect_val).to match_array actual_val
      end
    end

    describe 'self.sort_routine(column, direction)' do
      let!(:routine1) { create(:routine) }
      let!(:routine2) { create(:routine, completed_count: 200) }
      let!(:routine3) { create(:routine, completed_count:  30) }
      let!(:routine4) { create(:routine, completed_count:   4) }

      it 'デフォルト: 作成日の降順で取得' do
        column    = nil
        direction = nil
        expect_val = Routine.order(created_at: :desc)
        actual_val = Routine.sort_routine(column, direction)
        expect(expect_val).to match_array actual_val
      end

      it '達成数の昇順で取得' do
        column    = 'completed_count'
        direction = 'asc'
        expect_val = Routine.order(completed_count: :asc)
        actual_val = Routine.sort_routine(column, direction)
        expect(expect_val).to match_array actual_val
      end
    end
  end
end
