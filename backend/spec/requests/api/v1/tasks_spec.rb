require 'rails_helper'

RSpec.describe 'Api::V1::Tasks', type: :request do
  before do
    @current_user = create(:user)
    10.times { |n| @current_user.tasks.create(name: "task-#{n}") }
  end

  describe 'GET /create' do
    it 'ログイン状態ですべてのタスクを取得する' do
      # ログイン状態であることを証明するために必要なリクエストヘッダーの要素を取得
      # access-token, client, uid
      auth_token = login(@current_user)

      get '/api/v1/tasks', headers: auth_token
      json = JSON.parse(response.body)

      expect(response.status).to eq(200)

      expect(json['data'].length).to eq(10)
    end

    it 'ログイン状態で特定のタスクを取得' do
      task_name = 'スクワット100回'
      task = @current_user.tasks.create(name: task_name)

      auth_token = login(@current_user)

      get "/api/v1/tasks/#{task.id}", headers: auth_token

      # json から hash形式に変換
      json = JSON.parse(response.body)

      # data は array で返ってくることに注意
      data = json['data']

      expect(response.status).to eq(200)
      expect(data['name']).to eq(task_name)
    end

    it 'ログイン状態でタスクを作成' do
      task_name = 'create_task'
      auth_token = login(@current_user)
      params = { task: { name: task_name } }
      expect {
        post '/api/v1/tasks', params: params, headers: auth_token
      }.to change(Task, :count).by(+1)

      json = JSON.parse(response.body)
      data = json['data']

      expect(response.status).to eq(200)
      expect(data['name']).to eq(task_name)
    end

    it 'ログイン状態でタスクを編集' do
      task_name = 'update_task'
      auth_token = login(@current_user)
      task = @current_user.tasks.create(name: 'task')
      params = { task: { name: task_name } }

      put "/api/v1/tasks/#{task.id}", params: params, headers: auth_token

      json = JSON.parse(response.body)
      data = json['data']

      expect(response.status).to eq(200)
      expect(data['name']).to eq(task_name)
    end

    it 'ログイン状態でタスクを削除' do
      task_name = 'tasks to be deleted'
      task = @current_user.tasks.create!(name: task_name)
      auth_token = login(@current_user)

      expect {
        delete "/api/v1/tasks/#{task.id}", headers: auth_token
      }.to change(Task, :count).by(-1)

      json = JSON.parse(response.body)
      data = json['data']

      expect(response.status).to eq(200)
      expect(data['name']).to eq(task_name)
    end
  end
end